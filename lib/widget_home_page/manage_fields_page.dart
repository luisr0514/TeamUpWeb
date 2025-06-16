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
        _searchText = _searchController.text.toLowerCase();
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
            hintText: 'Buscar canchas...',
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
              'Agregar cancha',
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
          // Para depuración, es útil imprimir el error real
          print(snapshot.error);
          return const Center(child: Text('Error al cargar canchas'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay canchas registradas.'));
        }

        final filteredFields = snapshot.data!.docs.where((field) {
          final name = (field.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
          return name.contains(_searchText);
        }).toList();

        return ListView.builder(
          itemCount: filteredFields.length,
          itemBuilder: (context, index) {
            final fieldDoc = filteredFields[index];
            return _buildFieldCard(fieldDoc.data() as Map<String, dynamic>, fieldDoc.id, context);
          },
        );
      },
    );
  }

  Widget _buildFieldCard(Map<String, dynamic> fieldData, String docId, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        leading: _buildFieldImage(fieldData['photoUrl']),
        title: Text(fieldData['name'] ?? 'Sin nombre', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        children: _buildFieldDetails(fieldData, docId, context),
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

  List<Widget> _buildFieldDetails(Map<String, dynamic> fieldData, String docId, BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zona: ${fieldData['zone'] ?? 'Sin zona'}'),
            Text('Tipo de cancha: ${fieldData['type'] ?? 'Sin tipo'}'),
            Text('Tipo de superficie: ${fieldData['surfaceType'] ?? 'Sin tipo superficie'}'),
            Text('Precio por hora: \$${(fieldData['pricePerHour'] ?? 0).toStringAsFixed(2)}'),

            // ===== CORRECCIÓN APLICADA AQUÍ =====
            Text('Verificada: ${(fieldData['isVerified'] ?? false) ? "Sí" : "No"}'),
            Text('Activa: ${(fieldData['isActive'] ?? false) ? "Sí" : "No"}'),
            // =====================================

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
      ),
    ];
  }


  void _showAddFieldDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final controllers = {
      // Campos originales
      'ownerId': TextEditingController(),
      'name': TextEditingController(),
      'zone': TextEditingController(), // Original
      'zoneId': TextEditingController(), // Nuevo
      'lat': TextEditingController(),
      'lng': TextEditingController(),
      'duration': TextEditingController(),
      'footwear': TextEditingController(),
      'format': TextEditingController(),
      'pricePerHour': TextEditingController(),
      'photoUrl': TextEditingController(), // Original
      'contact': TextEditingController(),
      'description': TextEditingController(),
      'discountPercentage': TextEditingController(),
      'hasDiscount': TextEditingController(),
      'availability': TextEditingController(),
      'minPlayersToBook': TextEditingController(),
      // Nuevos campos
      'type': TextEditingController(),
      'surfaceType': TextEditingController(),
    };

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
                  ...controllers.entries.map((entry) => _buildTextField(entry.key, entry.value)),
                  Row(
                    children: [
                      const Text('¿Verificada?'),
                      Checkbox(
                        value: isVerified,
                        onChanged: (val) => setState(() => isVerified = val ?? false),
                      ),
                      const SizedBox(width: 16),
                      const Text('¿Activa?'),
                      Checkbox(
                        value: isActive,
                        onChanged: (val) => setState(() => isActive = val ?? true),
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
                    'fieldId': '', // Se actualizará después
                    // Campos originales
                    'ownerId': controllers['ownerId']!.text.trim(),
                    'name': controllers['name']!.text.trim(),
                    'zone': controllers['zone']!.text.trim(),
                    'zoneId': controllers['zoneId']!.text.trim(),
                    'lat': double.tryParse(controllers['lat']!.text.trim()) ?? 0.0,
                    'lng': double.tryParse(controllers['lng']!.text.trim()) ?? 0.0,
                    'duration': int.tryParse(controllers['duration']!.text.trim()) ?? 0,
                    'footwear': controllers['footwear']!.text.trim(),
                    'format': controllers['format']!.text.trim(),
                    'pricePerHour': double.tryParse(controllers['pricePerHour']!.text.trim()) ?? 0.0,
                    'photoUrl': controllers['photoUrl']!.text.trim(),
                    'contact': controllers['contact']!.text.trim(),
                    'description': controllers['description']!.text.trim(),
                    'discountPercentage': controllers['discountPercentage']!.text.trim(),
                    'hasDiscount': controllers['hasDiscount']!.text.trim().toLowerCase() == 'true',
                    'availability': controllers['availability']!.text.trim().isNotEmpty
                        ? controllers['availability']!.text.trim().split(',')
                        : [],
                    'minPlayersToBook': int.tryParse(controllers['minPlayersToBook']!.text.trim()) ?? 1,
                    // Nuevos campos
                    'type': controllers['type']!.text.trim(),
                    'surfaceType': controllers['surfaceType']!.text.trim(),
                    // Checkboxes
                    'isVerified': isVerified,
                    'isActive': isActive,
                    'createdAt': Timestamp.now(),
                  };

                  FirebaseFirestore.instance.collection('fields').add(newField)
                      .then((docRef) => docRef.update({'fieldId': docRef.id}));

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
    final controllers = {
      'ownerId': TextEditingController(text: fieldData['ownerId']),
      'name': TextEditingController(text: fieldData['name']),
      'zoneId': TextEditingController(text: fieldData['zoneId']),
      'lat': TextEditingController(text: fieldData['lat']?.toString()),
      'lng': TextEditingController(text: fieldData['lng']?.toString()),
      'type': TextEditingController(text: fieldData['type']),
      'surfaceType': TextEditingController(text: fieldData['surfaceType']),
      'pricePerHour': TextEditingController(text: fieldData['pricePerHour']?.toString()),
      'imageUrl': TextEditingController(text: fieldData['photoUrl']),
    };
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
                  ...controllers.entries.map((entry) => _buildTextField(entry.key, entry.value)),
                  Row(
                    children: [
                      const Text('¿Verificada?'),
                      Checkbox(
                        value: isVerified,
                        onChanged: (val) => setState(() => isVerified = val ?? false),
                      ),
                      const SizedBox(width: 16),
                      const Text('¿Activa?'),
                      Checkbox(
                        value: isActive,
                        onChanged: (val) => setState(() => isActive = val ?? false),
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
                    'ownerId': controllers['ownerId']!.text.trim(),
                    'name': controllers['name']!.text.trim(),
                    'zoneId': controllers['zoneId']!.text.trim(),
                    'lat': double.tryParse(controllers['lat']!.text.trim()) ?? 0.0,
                    'lng': double.tryParse(controllers['lng']!.text.trim()) ?? 0.0,
                    'type': controllers['type']!.text.trim(),
                    'surfaceType': controllers['surfaceType']!.text.trim(),
                    'pricePerHour': double.tryParse(controllers['pricePerHour']!.text.trim()) ?? 0.0,
                    'photoUrl': controllers['imageUrl']!.text.trim(),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
      ),
    );
  }
}