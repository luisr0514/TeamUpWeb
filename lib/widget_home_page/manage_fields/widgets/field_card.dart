import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'field_form_dialog.dart';

class FieldCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> fieldData;

  const FieldCard({
    Key? key,
    required this.docId,
    required this.fieldData,
  }) : super(key: key);

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => FieldFormDialog(
        docId: docId,
        initialData: fieldData,
      ),
    );
  }

  Future<void> _deleteField(BuildContext context) async {
    // Es buena práctica pedir confirmación
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar la cancha "${fieldData['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('fields').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        leading: _buildFieldImage(fieldData['photoUrl']),
        title: Text(
          fieldData['name'] ?? 'Sin nombre',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        children: [_buildFieldDetails(context)],
      ),
    );
  }

  Widget _buildFieldImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl ?? '',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 60,
          height: 60,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildFieldDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Zona: ${fieldData['zone'] ?? 'Sin zona'}'),
          Text('Tipo de cancha: ${fieldData['type'] ?? 'Sin tipo'}'),
          Text('Tipo de superficie: ${fieldData['surfaceType'] ?? 'Sin tipo'}'),
          Text('Precio por hora: \$${(fieldData['pricePerHour'] ?? 0).toStringAsFixed(2)}'),
          Text('Verificada: ${(fieldData['isVerified'] ?? false) ? "Sí" : "No"}'),
          Text('Activa: ${(fieldData['isActive'] ?? false) ? "Sí" : "No"}'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showEditDialog(context),
                child: const Text('EDITAR'),
              ),
              TextButton(
                onPressed: () => _deleteField(context),
                child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}