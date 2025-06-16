import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageFieldsPage extends StatefulWidget {
  const ManageFieldsPage({Key? key}) : super(key: key);

  @override
  State<ManageFieldsPage> createState() => _ManageFieldsPageState();
}

class _ManageFieldsPageState extends State<ManageFieldsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                _buildActionRow(context),
                const SizedBox(height: 24),
                Expanded(child: _buildFieldsList()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        _buildSearchField(),
        const SizedBox(width: 16),
        _buildActionButton('Export CSV', Colors.transparent),
        const SizedBox(width: 16),
        _buildAddFieldButton(context),
      ],
    );
  }

  Widget _buildActionButton(String title, Color backgroundColor) {
    return Container(
      width: 133,
      height: 41,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: Container(
        height: 41,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search fields...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildAddFieldButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddFieldDialog(context),
      child: Container(
        width: 151,
        height: 41,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 125, 176, 64),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Agregar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('fields').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar canchas'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay canchas registradas.'));
        }

        final fields = snapshot.data!.docs;
        final filteredFields = fields.where((field) {
          final fieldData = field.data() as Map<String, dynamic>;
          final name = fieldData['name']?.toString().toLowerCase() ?? '';
          return name.contains(_searchText.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: filteredFields.length,
          itemBuilder: (context, index) {
            final fieldDoc = filteredFields[index];
            final fieldData = fieldDoc.data() as Map<String, dynamic>;
            return _buildFieldCard(fieldData, fieldDoc.id, context);
          },
        );
      },
    );
  }

  Widget _buildFieldCard(Map<String, dynamic> fieldData, String docId, BuildContext context) {
    final name = fieldData['name'] ?? 'Sin nombre';
    final zone = fieldData['zone'] ?? 'Sin zona';
    final type = fieldData['type'] ?? 'Sin tipo';
    final surfaceType = fieldData['surfaceType'] ?? 'Sin tipo superficie';
    final pricePerHour = (fieldData['pricePerHour'] != null) ? (fieldData['pricePerHour'] as num).toDouble() : 0.0;
    final imageUrl = fieldData['photoUrl'] ?? '';
    final isVerified = fieldData['isVerified'] ?? false;
    final isActive = fieldData['isActive'] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
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
        title: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Zona: $zone'),
                Text('Tipo de cancha: $type'),
                Text('Tipo de superficie: $surfaceType'),
                Text('Precio por hora: \$${pricePerHour.toStringAsFixed(2)}'),
                Text('Verificada: ${isVerified ? "Sí" : "No"}'),
                Text('Activa: ${isActive ? "Sí" : "No"}'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _showEditFieldDialog(context, fieldData, docId),
                      child: const Text('EDITAR'),
                    ),
                    TextButton(
                      onPressed: () {
                        FirebaseFirestore.instance.collection('fields').doc(docId).delete();
                      },
                      child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
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

  void _showAddFieldDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final ownerIdController = TextEditingController();
    final nameController = TextEditingController();
    final zoneController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();
    final typeController = TextEditingController();
    final surfaceTypeController = TextEditingController();
    final pricePerHourController = TextEditingController();
    final imageUrlController = TextEditingController();
    bool isVerified = false;
    bool isActive = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar nueva cancha'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField('ID del propietario', ownerIdController, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                  _buildTextField('Nombre de la cancha', nameController, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                  _buildTextField('Zona', zoneController, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                  _buildTextField('Latitud', latController, keyboardType: TextInputType.number, validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Debe ser un número válido';
                    return null;
                  }),
                  _buildTextField('Longitud', lngController, keyboardType: TextInputType.number, validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Debe ser un número válido';
                    return null;
                  }),
                  _buildTextField('Tipo de cancha', typeController, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                  _buildTextField('Tipo de superficie', surfaceTypeController, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                  _buildTextField('Precio por hora', pricePerHourController, keyboardType: TextInputType.number, validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Debe ser un número válido';
                    return null;
                  }),
                  _buildTextField('URL de la imagen', imageUrlController),
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
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
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
                    'availability': {},
                  };

                  FirebaseFirestore.instance.collection('fields').add(newField);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFieldDialog(BuildContext context, Map<String, dynamic> fieldData, String docId) {
    final _formKey = GlobalKey<FormState>();

    final ownerIdController = TextEditingController(text: fieldData['ownerId'] ?? '');
    final nameController = TextEditingController(text: fieldData['name'] ?? '');
    final zoneController = TextEditingController(text: fieldData['zone'] ?? '');
    final latController = TextEditingController(text: fieldData['lat']?.toString() ?? '');
    final lngController = TextEditingController(text: fieldData['lng']?.toString() ?? '');
    final typeController = TextEditingController(text: fieldData['type'] ?? '');
    final surfaceTypeController = TextEditingController(text: fieldData['surfaceType'] ?? '');
    final pricePerHourController = TextEditingController(text: fieldData['pricePerHour']?.toString() ?? '');
    final imageUrlController = TextEditingController(text: fieldData['photoUrl'] ?? '');
    bool isVerified = fieldData['isVerified'] ?? false;
    bool isActive = fieldData['isActive'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar cancha'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField('ID del propietario', ownerIdController, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                  _buildTextField('Nombre de la cancha', nameController, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                  _buildTextField('Zona', zoneController, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                  _buildTextField('Latitud', latController, keyboardType: TextInputType.number, validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Debe ser un número válido';
                    return null;
                  }),
                  _buildTextField('Longitud', lngController, keyboardType: TextInputType.number, validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Debe ser un número válido';
                    return null;
                  }),
                  _buildTextField('Tipo de cancha', typeController, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                  _buildTextField('Tipo de superficie', surfaceTypeController, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                  _buildTextField('Precio por hora', pricePerHourController, keyboardType: TextInputType.number, validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Debe ser un número válido';
                    return null;
                  }),
                  _buildTextField('URL de la imagen', imageUrlController),
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
                            isActive = val ?? false;
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
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final updatedField = {
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
                    'updatedAt': Timestamp.now(),
                  };

                  await FirebaseFirestore.instance.collection('fields').doc(docId).update(updatedField);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: validator,
      ),
    );
  }
}