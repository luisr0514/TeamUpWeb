// lib/features/manage_fields/field_form_dialog.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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

    _selectedSurfaceType = _surfaceTypes.contains(data['surfaceType']) ? data['surfaceType'] : null;
    _selectedFormat = _formats.contains(data['format']) ? data['format'] : null;
    _selectedFootwear = _footwearTypes.contains(data['footwear']) ? data['footwear'] : null;
    _selectedDuration = _durations.contains(data['duration']?.toDouble()) ? data['duration']?.toDouble() : null;
    _isActive = data['isActive'] ?? true;
    _hasDiscount = data['hasDiscount'] ?? false;
  }

  @override
  void dispose() {
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

  Future<void> _useCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso de ubicación denegado')));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latController.text = pos.latitude.toStringAsFixed(6);
        _lngController.text = pos.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al obtener ubicación: $e')));
    }
  }

  Future<void> _selectOnMap() async {
    final initialLat = double.tryParse(_latController.text) ?? 0.0;
    final initialLng = double.tryParse(_lngController.text) ?? 0.0;
    LatLng selectedPoint = LatLng(initialLat, initialLng);
    final result = await showDialog<LatLng>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar ubicación en mapa'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: FlutterMap(
            options: MapOptions(
              center: selectedPoint,
              zoom: 15,
              onTap: (_, point) => selectedPoint = point,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.yourcompany.teamup',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedPoint,
                    width: 40,
                    height: 40,
                    builder: (_) => const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(selectedPoint), child: const Text('Confirmar')),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        _latController.text = result.latitude.toStringAsFixed(6);
        _lngController.text = result.longitude.toStringAsFixed(6);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: usuario no autenticado'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);

    final dataToSave = {
      'ownerId': currentUser.uid,
      'name': _nameController.text.trim(),
      'zone': _zoneController.text.trim(),
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

    try {
      if (widget.isEditing) {
        dataToSave.remove('ownerId');
        await FirebaseFirestore.instance.collection('fields').doc(widget.docId!).update(dataToSave);
      } else {
        dataToSave['createdAt'] = Timestamp.now();
        await FirebaseFirestore.instance.collection('fields').add(dataToSave);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancha ${widget.isEditing ? 'actualizada' : 'agregada'} con éxito'), backgroundColor: Colors.green));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red));
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

              _buildSectionTitle('Ubicación'),
              _buildTextFormField(controller: _zoneController, label: 'Zona / Ubicación', icon: Icons.location_on_outlined, validator: FormValidators.required),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _buildTextFormField(controller: _latController, label: 'Latitud', icon: Icons.map, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), validator: FormValidators.isNumeric)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextFormField(controller: _lngController, label: 'Longitud', icon: Icons.map, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), validator: FormValidators.isNumeric)),
                  IconButton(icon: const Icon(Icons.my_location), tooltip: 'Usar mi ubicación', onPressed: _useCurrentLocation),
                  IconButton(icon: const Icon(Icons.map), tooltip: 'Seleccionar en mapa', onPressed: _selectOnMap),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
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

  Widget _buildDropdownFormField<T>({
    required T? value,
    required List<T> items,
    required String label,
    required void Function(T?) onChanged,
  }) {
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

  Widget _buildSwitchListTile({
    required String title,
    String? subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: Theme.of(context).textTheme.bodySmall) : null,
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
