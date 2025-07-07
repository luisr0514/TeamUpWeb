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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
            '¿Eliminar la cancha "${fieldData['name']}"? Esta acción es irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
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
        leading: _buildImage(fieldData['imageUrls']?.first),
        title: Text(
          fieldData['name'] ?? '—',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ciudad: ${fieldData['city'] ?? '—'}'),
                Text('Tipo: ${fieldData['surfaceType'] ?? '—'}'),
                Text(
                    'Precio/hora: \$${(fieldData['pricePerHour'] ?? 0).toStringAsFixed(2)}'),
                Text('Activa: ${(fieldData['isActive'] ?? false) ? "Sí" : "No"}'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => _showEditDialog(context),
                        child: const Text('EDITAR')),
                    TextButton(
                      onPressed: () => _deleteField(context),
                      child: const Text('ELIMINAR',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImage(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url != null && url.isNotEmpty
          ? Image.network(url, width: 60, height: 60, fit: BoxFit.cover)
          : Container(
        width: 60,
        height: 60,
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.white54),
      ),
    );
  }
}
