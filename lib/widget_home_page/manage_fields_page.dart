import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageFieldsPage extends StatelessWidget {
  const ManageFieldsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canchas del sistema'),
        backgroundColor: const Color.fromARGB(255, 42, 121, 218),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddFieldDialog(context);
            },
            tooltip: 'Agregar nueva cancha',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('fields').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar canchas'));
          }

          final fields = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final fieldData = fields[index].data() as Map<String, dynamic>;

              final name = fieldData['name'] ?? 'Sin nombre';
              final zone = fieldData['zone'] ?? 'Sin zona';
              final type = fieldData['type'] ?? 'Sin tipo';
              final surfaceType = fieldData['surfaceType'] ?? 'Sin tipo superficie';
              final pricePerHour = fieldData['pricePerHour']?.toDouble() ?? 0.0;
              final imageUrl = fieldData['photoUrl'] ?? '';
              final isVerified = fieldData['isVerified'] ?? false;
              final isActive = fieldData['isActive'] ?? false;
              final lat = (fieldData['lat'] != null) ? (fieldData['lat'] as num).toDouble() : 0.0;
              final lng = (fieldData['lng'] != null) ? (fieldData['lng'] as num).toDouble() : 0.0;

              final availabilityMap = fieldData['availability'] as Map<String, dynamic>? ?? {};
              // Convert availability from dynamic map to Map<String, List<String>>
              final availability = availabilityMap.map(
                (key, value) => MapEntry(
                  key,
                  List<String>.from(value ?? []),
                ),
              );

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ExpansionTile(
                  leading: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
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
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    Text('Zona: $zone'),
                    Text('Tipo de cancha: $type'),
                    Text('Tipo de superficie: $surfaceType'),
                    Text('Precio por hora: \$${pricePerHour.toStringAsFixed(2)}'),
                    Text('Verificada: ${isVerified ? "Sí" : "No"}'),
                    Text('Activa: ${isActive ? "Sí" : "No"}'),
                    Text('Latitud: $lat'),
                    Text('Longitud: $lng'),
                    const SizedBox(height: 8),
                    const Text('Disponibilidad:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...availability.entries.map(
                      (entry) => Text('${entry.key}: ${entry.value.join(", ")}'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddFieldDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    final TextEditingController ownerIdController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController zoneController = TextEditingController();
    final TextEditingController latController = TextEditingController();
    final TextEditingController lngController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    final TextEditingController surfaceTypeController = TextEditingController();
    final TextEditingController pricePerHourController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    bool isVerified = false;
    bool isActive = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Agregar nueva cancha'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(label: 'ID del propietario', controller: ownerIdController, validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                    _buildTextField(label: 'Nombre de la cancha', controller: nameController, validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                    _buildTextField(label: 'Zona', controller: zoneController, validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                    _buildTextField(label: 'Latitud', controller: latController, keyboardType: TextInputType.number, validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      final n = double.tryParse(v);
                      if (n == null) return 'Debe ser un número válido';
                      return null;
                    }),
                    _buildTextField(label: 'Longitud', controller: lngController, keyboardType: TextInputType.number, validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      final n = double.tryParse(v);
                      if (n == null) return 'Debe ser un número válido';
                      return null;
                    }),
                    _buildTextField(label: 'Tipo de cancha', controller: typeController, validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                    _buildTextField(label: 'Tipo de superficie', controller: surfaceTypeController, validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                    _buildTextField(label: 'Precio por hora', controller: pricePerHourController, keyboardType: TextInputType.number, validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      final n = double.tryParse(v);
                      if (n == null) return 'Debe ser un número válido';
                      return null;
                    }),
                    _buildTextField(label: 'URL de la imagen', controller: imageUrlController),
                    Row(
                      children: [
                        const Text('¿Verificada?'),
                        Checkbox(
                          value: isVerified,
                          onChanged: (val) {
                            setState(() {
                              isVerified = val ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        const Text('¿Activa?'),
                        Checkbox(
                          value: isActive,
                          onChanged: (val) {
                            setState(() {
                              isActive = val ?? true;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    final newField = {
                      'ownerId': ownerIdController.text.trim(),
                      'name': nameController.text.trim(),
                      'zone': zoneController.text.trim(),
                      'lat': double.parse(latController.text.trim()),
                      'lng': double.parse(lngController.text.trim()),
                      'type': typeController.text.trim(),
                      'surfaceType': surfaceTypeController.text.trim(),
                      'pricePerHour': double.parse(pricePerHourController.text.trim()),
                      'photoUrl': imageUrlController.text.trim(),
                      'isVerified': isVerified,
                      'isActive': isActive,
                      'createdAt': Timestamp.now(),
                      'availability': {}, // Puedes agregar aquí estructura de disponibilidad si quieres
                    };

                    FirebaseFirestore.instance.collection('fields').add(newField);

                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Agregar'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}