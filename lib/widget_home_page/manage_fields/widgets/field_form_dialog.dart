import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- 1. IMPORTA FIREBASE AUTH
import 'package:flutter/material.dart';
import 'form_validators.dart';

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

  // --- DECLARACIÓN DE CONTROLADORES ---
  // Se elimina el _ownerIdController

  late final TextEditingController _nameController;
  late final TextEditingController _zoneController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _priceController;
  late final TextEditingController _photoUrlController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contactController;
  late final TextEditingController _discountPercentageController;
  late final TextEditingController _minPlayersController;

  // ... (el resto de las variables de estado se mantienen igual)
  String? _selectedSurfaceType;
  String? _selectedFormat;
  String? _selectedFootwear;
  double? _selectedDuration;
  bool _isActive = true;
  bool _hasDiscount = false;

  bool _isLoading = false;

  final List<String> _surfaceTypes = ['Césped Sintético', 'Césped Natural', 'Cemento', 'Parquet'];
  final List<String> _formats = ['Fútbol 5', 'Fútbol 7', 'Fútbol 8', 'Fútbol 11', 'Pádel', 'Tenis'];
  final List<String> _footwearTypes = ['Cualquiera', 'Botines de Césped Sintético', 'Zapatillas de Suela Lisa'];
  final List<double> _durations = [1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? {};

    // --- INICIALIZACIÓN DE CONTROLADORES ---
    // Se elimina la inicialización de _ownerIdController
    _nameController = TextEditingController(text: data['name'] ?? '');
    _zoneController = TextEditingController(text: data['zone'] ?? '');
    _latController = TextEditingController(text: data['lat']?.toString() ?? '');
    _lngController = TextEditingController(text: data['lng']?.toString() ?? '');
    _priceController = TextEditingController(text: data['pricePerHour']?.toString() ?? '');
    _photoUrlController = TextEditingController(text: data['photoUrl'] ?? '');
    _descriptionController = TextEditingController(text: data['description'] ?? '');
    _contactController = TextEditingController(text: data['contact'] ?? '');
    _discountPercentageController = TextEditingController(text: data['discountPercentage']?.toString() ?? '');
    _minPlayersController = TextEditingController(text: data['minPlayersToBook']?.toString() ?? '');

    // ... (el resto de la inicialización se mantiene igual)
    _selectedSurfaceType = data['surfaceType'];
    if (!_surfaceTypes.contains(_selectedSurfaceType)) _selectedSurfaceType = null;

    _selectedFormat = data['format'];
    if (!_formats.contains(_selectedFormat)) _selectedFormat = null;

    _selectedFootwear = data['footwear'];
    if (!_footwearTypes.contains(_selectedFootwear)) _selectedFootwear = null;

    _selectedDuration = (data['duration'] as num?)?.toDouble();
    if (!_durations.contains(_selectedDuration)) _selectedDuration = null;

    _isActive = data['isActive'] ?? true;
    _hasDiscount = data['hasDiscount'] ?? false;
  }

  @override
  void dispose() {
    // Se elimina el dispose de _ownerIdController
    _nameController.dispose();
    _zoneController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _priceController.dispose();
    _photoUrlController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _discountPercentageController.dispose();
    _minPlayersController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // --- 2. OBTENER EL ID DEL USUARIO LOGUEADO ---
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Si por alguna razón no hay usuario, muestra un error y no continúes.
      // Esto es una salvaguarda importante.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se ha podido identificar al usuario. Por favor, inicie sesión de nuevo.'), backgroundColor: Colors.red),
      );
      return;
    }
    final ownerId = currentUser.uid;

    setState(() => _isLoading = true);

    try {
      final dataToSave = {
        'ownerId': ownerId, // <-- 3. AÑADIR EL ID AUTOMÁTICAMENTE
        'name': _nameController.text.trim(),
        'zone': _zoneController.text.trim(),
        // ... (el resto de los campos se mantienen igual)
        'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
        'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
        'pricePerHour': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'photoUrl': _photoUrlController.text.trim(),
        'description': _descriptionController.text.trim(),
        'contact': _contactController.text.trim(),
        'surfaceType': _selectedSurfaceType,
        'format': _selectedFormat,
        'footwear': _selectedFootwear,
        'duration': _selectedDuration,
        'isActive': _isActive,
        'hasDiscount': _hasDiscount,
        'discountPercentage': _hasDiscount ? (double.tryParse(_discountPercentageController.text.trim()) ?? 0.0) : null,
        'minPlayersToBook': int.tryParse(_minPlayersController.text.trim()) ?? 1,
        'updatedAt': Timestamp.now(),
      };

      if (widget.isEditing) {
        // En modo edición, no actualizamos el ownerId ni createdAt.
        // Se podría hacer, pero generalmente estos campos son inmutables.
        dataToSave.remove('ownerId');
        await FirebaseFirestore.instance.collection('fields').doc(widget.docId!).update(dataToSave);
      } else {
        dataToSave['createdAt'] = Timestamp.now();
        await FirebaseFirestore.instance.collection('fields').add(dataToSave);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cancha ${widget.isEditing ? 'actualizada' : 'agregada'} con éxito.'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${e.toString()}'), backgroundColor: Colors.red),
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
          ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
          : Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildSectionTitle('Información Básica'),
              _buildTextFormField(controller: _nameController, label: 'Nombre de la cancha', icon: Icons.sports_soccer, validator: FormValidators.required),
              // --- 4. SE ELIMINA EL CAMPO DEL FORMULARIO ---
              // Ya no se muestra el campo para el ID de propietario.
              _buildTextFormField(controller: _descriptionController, label: 'Descripción', icon: Icons.description, maxLines: 3),

              // ... (el resto del método build se mantiene exactamente igual)
              _buildSectionTitle('Ubicación'),
              _buildTextFormField(controller: _zoneController, label: 'Zona / Ubicación', icon: Icons.location_on_outlined, validator: FormValidators.required),
              Row(
                children: [
                  Expanded(child: _buildTextFormField(controller: _latController, label: 'Latitud', icon: Icons.map, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), validator: FormValidators.isNumeric)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextFormField(controller: _lngController, label: 'Longitud', icon: Icons.map, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), validator: FormValidators.isNumeric)),
                ],
              ),

              _buildSectionTitle('Detalles de la Cancha'),
              _buildDropdownFormField(value: _selectedFormat, items: _formats, label: 'Formato', onChanged: (v) => setState(() => _selectedFormat = v)),
              _buildDropdownFormField(value: _selectedSurfaceType, items: _surfaceTypes, label: 'Tipo de superficie', onChanged: (v) => setState(() => _selectedSurfaceType = v)),
              _buildDropdownFormField(value: _selectedFootwear, items: _footwearTypes, label: 'Calzado permitido', onChanged: (v) => setState(() => _selectedFootwear = v)),
              _buildDropdownFormField(value: _selectedDuration, items: _durations, label: 'Duración por turno (horas)', onChanged: (v) => setState(() => _selectedDuration = v)),
              _buildTextFormField(controller: _minPlayersController, label: 'Mínimo de jugadores', icon: Icons.group, keyboardType: TextInputType.number, validator: FormValidators.isNumeric),

              _buildSectionTitle('Precio y Contacto'),
              _buildTextFormField(controller: _priceController, label: 'Precio por hora', icon: Icons.monetization_on_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => FormValidators.compose(v, [FormValidators.required, FormValidators.isNumeric, FormValidators.isPositiveNumber])),
              _buildSwitchListTile(title: '¿Tiene descuento?', value: _hasDiscount, onChanged: (v) => setState(() => _hasDiscount = v)),
              if (_hasDiscount)
                _buildTextFormField(controller: _discountPercentageController, label: 'Porcentaje de descuento (%)', icon: Icons.percent, keyboardType: TextInputType.number, validator: (v) => FormValidators.compose(v, [FormValidators.required, FormValidators.isNumeric])),
              _buildTextFormField(controller: _contactController, label: 'Contacto (teléfono/email)', icon: Icons.contact_phone, validator: FormValidators.required),
              _buildTextFormField(controller: _photoUrlController, label: 'URL de la foto', icon: Icons.image_outlined, keyboardType: TextInputType.url, validator: (v) => FormValidators.compose(v, [FormValidators.required, FormValidators.isUrl])),

              _buildSectionTitle('Estado'),
              _buildSwitchListTile(title: 'Activa', subtitle: 'La cancha está disponible para ser reservada.', value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton.icon(icon: const Icon(Icons.save), label: Text(widget.isEditing ? 'Guardar Cambios' : 'Agregar'), onPressed: _isLoading ? null : _submitForm, style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 125, 176, 64), foregroundColor: Colors.white)),
      ],
    );
  }

  // Los métodos _build... helpers se mantienen igual

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextFormField({ required TextEditingController controller, required String label, IconData? icon, TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1, }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          alignLabelWithHint: maxLines > 1,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownFormField<T>({ required T? value, required List<T> items, required String label, required void Function(T?) onChanged, }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items.map((item) => DropdownMenuItem<T>(value: item, child: Text(item.toString()))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        validator: (value) => value == null ? 'Debes seleccionar una opción' : null,
      ),
    );
  }

  Widget _buildSwitchListTile({ required String title, String? subtitle, required bool value, required void Function(bool) onChanged, }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: Theme.of(context).textTheme.bodySmall) : null,
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}