import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'form_validators.dart'; // Importa la clase de validadores

class FieldFormDialog extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? initialData;

  const FieldFormDialog({
    Key? key,
    this.docId,
    this.initialData,
  }) : super(key: key);

  bool get isEditing => docId != null;

  @override
  _FieldFormDialogState createState() => _FieldFormDialogState();
}

class _FieldFormDialogState extends State<FieldFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _photoUrlController;
  late final TextEditingController _zoneController;
  // ... agrega más controladores si son necesarios para otros campos de texto

  // Variables de estado para widgets que no son de texto
  String? _selectedType;
  String? _selectedSurfaceType;
  bool _isVerified = false;
  bool _isActive = true;
  bool _isLoading = false;

  // Opciones para los menús desplegables
  final List<String> _fieldTypes = ['Fútbol 5', 'Fútbol 7', 'Fútbol 11', 'Pádel', 'Tenis'];
  final List<String> _surfaceTypes = ['Césped Sintético', 'Césped Natural', 'Cemento', 'Polvo de Ladrillo', 'Parquet'];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? {};

    // Inicializa controladores
    _nameController = TextEditingController(text: data['name'] ?? '');
    _priceController = TextEditingController(text: data['pricePerHour']?.toString() ?? '');
    _photoUrlController = TextEditingController(text: data['photoUrl'] ?? '');
    _zoneController = TextEditingController(text: data['zone'] ?? '');

    // Inicializa menús desplegables de forma segura
    _selectedType = data['type'];
    if (!_fieldTypes.contains(_selectedType)) {
      _selectedType = null;
    }

    _selectedSurfaceType = data['surfaceType'];
    if (!_surfaceTypes.contains(_selectedSurfaceType)) {
      _selectedSurfaceType = null;
    }

    // Inicializa switches
    _isVerified = data['isVerified'] ?? false;
    _isActive = data['isActive'] ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _photoUrlController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Primero, valida el formulario. Si no es válido, no hace nada.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'pricePerHour': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'photoUrl': _photoUrlController.text.trim(),
        'zone': _zoneController.text.trim(),
        'type': _selectedType,
        'surfaceType': _selectedSurfaceType,
        'isVerified': _isVerified,
        'isActive': _isActive,
        'updatedAt': Timestamp.now(),
      };

      if (widget.isEditing) {
        await FirebaseFirestore.instance.collection('fields').doc(widget.docId!).update(data);
      } else {
        data['createdAt'] = Timestamp.now();
        // NOTA: No es necesario pre-crear el 'fieldId', Firestore lo genera.
        // Si necesitas el ID, puedes obtenerlo después de la creación.
        await FirebaseFirestore.instance.collection('fields').add(data);
      }

      if (!mounted) return;

      // Feedback de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cancha ${widget.isEditing ? 'actualizada' : 'agregada'} con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      // Feedback de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Editar Cancha' : 'Agregar Nueva Cancha'),
      content: _isLoading
          ? const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      )
          : Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4, // Ajusta el ancho del diálogo
          child: ListView( // Usar ListView permite un scroll suave si el contenido es mucho
            shrinkWrap: true,
            children: [
              _buildTextFormField(
                controller: _nameController,
                label: 'Nombre de la cancha',
                icon: Icons.sports_soccer,
                validator: FormValidators.required,
              ),
              _buildDropdownFormField(
                value: _selectedType,
                items: _fieldTypes,
                label: 'Tipo de cancha',
                onChanged: (value) => setState(() => _selectedType = value),
              ),
              _buildDropdownFormField(
                value: _selectedSurfaceType,
                items: _surfaceTypes,
                label: 'Tipo de superficie',
                onChanged: (value) => setState(() => _selectedSurfaceType = value),
              ),
              _buildTextFormField(
                controller: _priceController,
                label: 'Precio por hora',
                icon: Icons.monetization_on_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => FormValidators.compose(value, [
                  FormValidators.required,
                  FormValidators.isNumeric,
                  FormValidators.isPositiveNumber,
                ]),
              ),
              _buildTextFormField(
                controller: _zoneController,
                label: 'Zona / Ubicación',
                icon: Icons.location_on_outlined,
                validator: FormValidators.required,
              ),
              _buildTextFormField(
                controller: _photoUrlController,
                label: 'URL de la foto',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
                validator: (value) => FormValidators.compose(value, [
                  FormValidators.required,
                  FormValidators.isUrl,
                ]),
              ),
              const SizedBox(height: 16),
              _buildSwitchListTile(
                title: 'Verificada',
                subtitle: 'La cancha ha sido verificada por un administrador.',
                value: _isVerified,
                onChanged: (value) => setState(() => _isVerified = value),
              ),
              _buildSwitchListTile(
                title: 'Activa',
                subtitle: 'La cancha está disponible para ser reservada.',
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: Text(widget.isEditing ? 'Guardar Cambios' : 'Agregar'),
          onPressed: _isLoading ? null : _submitForm, // Desactiva el botón mientras carga
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 125, 176, 64),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // --- WIDGETS BUILDERS HELPERS ---
  // Estos métodos ayudan a mantener el método build() limpio y legible.

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required List<String> items,
    required String label,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value == null ? 'Debes seleccionar una opción' : null,
      ),
    );
  }

  Widget _buildSwitchListTile({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}