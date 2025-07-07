// lib/widgets/field_form_dialog.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

import 'package:teamup_web/services/services.dart';
import 'form_validators.dart';
import 'availability_editor.dart';

class FieldFormDialog extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? initialData;

  FieldFormDialog({Key? key, this.docId, this.initialData}) : super(key: key);

  bool get isEditing => docId != null;

  @override
  _FieldFormDialogState createState() => _FieldFormDialogState();
}

class _FieldFormDialogState extends State<FieldFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Controllers de texto
  late final TextEditingController _nameCtrl, _zoneCtrl, _latCtrl, _lngCtrl, _priceCtrl, _descriptionCtrl, _phoneCtrl, _emailCtrl, _discountCtrl, _minPlayersCtrl;

  // Variables de estado (Dropdowns, Switches, etc.)
  String? _selectedCity, _selectedSurface, _selectedFormat, _selectedFootwear;
  double? _selectedDuration;
  bool _hasDiscount = false, _isActive = true;
  late Map<String, List<String>> _availability;

  // Manejo de imágenes
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _pickedFiles = [];
  final List<Uint8List> _pickedBytes = [];
  List<String> _existingImageUrls = [];

  bool _isLoading = false;

  // Listas estáticas para Dropdowns
  final _surfaceTypes = ['Césped Sintético', 'Césped Natural', 'Cemento'];
  final _formats = ['5vs5', '7vs7', '11vs11'];
  final _footwears = ['Cualquiera', 'Micro', 'Suela Lisa'];
  final _durations = [1.0, 1.5, 2.0]; // <-- AHORA SÍ SE USA

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? {};

    _nameCtrl        = TextEditingController(text: data['name'] ?? '');
    _zoneCtrl        = TextEditingController(text: data['zone'] ?? '');
    _latCtrl         = TextEditingController(text: data['lat']?.toString() ?? '');
    _lngCtrl         = TextEditingController(text: data['lng']?.toString() ?? '');
    _priceCtrl       = TextEditingController(text: data['pricePerHour']?.toString() ?? '');
    _descriptionCtrl = TextEditingController(text: data['description'] ?? '');
    _phoneCtrl       = TextEditingController(text: data['phone'] ?? '');
    _emailCtrl       = TextEditingController(text: data['email'] ?? '');
    _discountCtrl    = TextEditingController(text: data['discountPercentage']?.toString() ?? '');
    _minPlayersCtrl  = TextEditingController(text: data['minPlayersToBook']?.toString() ?? '');

    _selectedCity     = data['city'];
    _selectedSurface  = data['surfaceType'];
    _selectedFormat   = data['format'];
    _selectedFootwear = data['footwear'];
    _selectedDuration = (data['duration'] as num?)?.toDouble();
    _hasDiscount      = data['hasDiscount'] ?? false;
    _isActive         = data['isActive'] ?? true;
    _existingImageUrls = List<String>.from(data['imageUrls'] ?? []);

    final availabilityData = data['availability'] as Map?;
    _availability = availabilityData?.map(
          (k, v) => MapEntry(k.toString(), List<String>.from(v ?? [])),
    ) ?? {};
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _zoneCtrl.dispose(); _latCtrl.dispose(); _lngCtrl.dispose();
    _priceCtrl.dispose(); _descriptionCtrl.dispose(); _phoneCtrl.dispose();
    _emailCtrl.dispose(); _discountCtrl.dispose(); _minPlayersCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'city': _selectedCity,
      'zone': _zoneCtrl.text.trim(),
      'lat': double.tryParse(_latCtrl.text.trim()) ?? 0.0,
      'lng': double.tryParse(_lngCtrl.text.trim()) ?? 0.0,
      'pricePerHour': double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
      'description': _descriptionCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'surfaceType': _selectedSurface,
      'format': _selectedFormat,
      'footwear': _selectedFootwear,
      'duration': _selectedDuration,
      'hasDiscount': _hasDiscount,
      'discountPercentage': _hasDiscount ? (double.tryParse(_discountCtrl.text.trim()) ?? 0.0) : null,
      'minPlayersToBook': int.tryParse(_minPlayersCtrl.text.trim()) ?? 1,
      'isActive': _isActive,
      'availability': _availability,
      'imageUrls': _existingImageUrls,
    };

    try {
      await _firestoreService.saveField(
        data: data,
        docId: widget.docId,
        newFiles: _pickedFiles,
        newBytes: _pickedBytes,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cancha ${widget.isEditing ? 'actualizada' : 'agregada'} exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
  );

  Future<void> _useCurrentLocation() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso de ubicación denegado')));
      return;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latCtrl.text = pos.latitude.toStringAsFixed(6);
      _lngCtrl.text = pos.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _selectOnMap() async {
    double lat = double.tryParse(_latCtrl.text) ?? -34.6037;
    double lng = double.tryParse(_lngCtrl.text) ?? -58.3816;
    LatLng picked = LatLng(lat, lng);

    final result = await showDialog<LatLng>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Seleccionar ubicación'),
        content: SizedBox(
          width: double.maxFinite, height: 300,
          child: FlutterMap(
            options: MapOptions(center: picked, zoom: 13, onTap: (_, p) => picked = p),
            children: [
              TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: ['a','b','c']),
              MarkerLayer(markers: [Marker(point: picked, width: 40, height: 40, builder: (_) => const Icon(Icons.location_on, size: 40, color: Colors.red))]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, picked), child: const Text('Confirmar')),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _latCtrl.text = result.latitude.toStringAsFixed(6);
        _lngCtrl.text = result.longitude.toStringAsFixed(6);
      });
    }
  }

  Widget _buildImagePreview() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: () async {
              final imgs = await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1024);
              // <-- CORRECCIÓN 3: `pickMultiImage` devuelve lista vacía, no null.
              if (imgs.isEmpty) return;

              if (kIsWeb) {
                for (final f in imgs) {
                  _pickedBytes.add(await f.readAsBytes());
                }
              } else {
                _pickedFiles.addAll(imgs);
              }
              setState(() {});
            },
            child: Container(
              width: 80, height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
            ),
          ),
          ..._existingImageUrls.map((url) => _buildExistingImage(url)),
          if (kIsWeb) ..._pickedBytes.map((bytes) => _buildNewImagePreview(Image.memory(bytes, fit: BoxFit.cover), () => setState(() => _pickedBytes.remove(bytes))))
          else ..._pickedFiles.map((file) => _buildNewImagePreview(Image.file(File(file.path), fit: BoxFit.cover), () => setState(() => _pickedFiles.remove(file)))),
        ],
      ),
    );
  }

  Widget _buildExistingImage(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover)),
          Positioned(top: 0, right: 0, child: GestureDetector(
            onTap: () => setState(() => _existingImageUrls.remove(url)),
            child: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 16, color: Colors.white)),
          )),
        ],
      ),
    );
  }

  Widget _buildNewImagePreview(Widget imageWidget, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 80, height: 80, child: imageWidget)),
          Positioned(top: 0, right: 0, child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 16, color: Colors.white)),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Editar Cancha' : 'Agregar Nueva Cancha'),
      content: _isLoading
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          : Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: ListView(
            shrinkWrap: true,
            children: [
              _sectionTitle('Información Básica'),
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre de la cancha', prefixIcon: Icon(Icons.sports_soccer), border: OutlineInputBorder()), validator: FormValidators.required),

              _sectionTitle('Ubicación'),
              StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getCitiesStream(),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snap.data!.docs;

                  final cityItems = docs.map((d) {
                    final cityName = (d.data() as Map<String, dynamic>)['name'] ?? d.id;
                    // <-- CORRECCIÓN 1: Especificar el tipo <String> explícitamente.
                    return DropdownMenuItem<String>(
                        value: cityName,
                        child: Text(cityName)
                    );
                  }).toList();

                  if (_selectedCity != null && !cityItems.any((item) => item.value == _selectedCity)) {
                    _selectedCity = null;
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedCity,
                    items: cityItems,
                    onChanged: (v) => setState(() => _selectedCity = v),
                    decoration: const InputDecoration(labelText: 'Selecciona ciudad', border: OutlineInputBorder()),
                    validator: (v) => v == null ? 'Debes escoger una ciudad' : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _zoneCtrl, decoration: const InputDecoration(labelText: 'Zona/Barrio', prefixIcon: Icon(Icons.location_on_outlined), border: OutlineInputBorder()), validator: FormValidators.required),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _latCtrl, decoration: const InputDecoration(labelText: 'Latitud', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), validator: FormValidators.isNumeric)),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _lngCtrl, decoration: const InputDecoration(labelText: 'Longitud', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), validator: FormValidators.isNumeric)),
                  IconButton(icon: const Icon(Icons.my_location), tooltip: 'Mi ubicación', onPressed: _useCurrentLocation),
                  IconButton(icon: const Icon(Icons.map), tooltip: 'Seleccionar en mapa', onPressed: _selectOnMap),
                ],
              ),

              _sectionTitle('Detalles de la Cancha'),
              DropdownButtonFormField<String>(value: _selectedFormat, items: _formats.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(), onChanged: (v) => setState(() => _selectedFormat = v), decoration: const InputDecoration(labelText: 'Formato', border: OutlineInputBorder()), validator: (v) => v == null ? 'Selecciona un formato' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: _selectedSurface, items: _surfaceTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _selectedSurface = v), decoration: const InputDecoration(labelText: 'Superficie', border: OutlineInputBorder()), validator: (v) => v == null ? 'Selecciona una superficie' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: _selectedFootwear, items: _footwears.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(), onChanged: (v) => setState(() => _selectedFootwear = v), decoration: const InputDecoration(labelText: 'Calzado Permitido', border: OutlineInputBorder())),
              const SizedBox(height: 12), // <-- AÑADIDO

              // <-- CORRECCIÓN 2: Añadido el Dropdown para la duración.
              DropdownButtonFormField<double>(
                  value: _selectedDuration,
                  items: _durations.map((d) => DropdownMenuItem(
                      value: d,
                      child: Text('$d hs')
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedDuration = v),
                  decoration: const InputDecoration(labelText: 'Duración por turno', border: OutlineInputBorder()),
                  validator: (v) => v == null ? 'Selecciona una duración' : null
              ),

              _sectionTitle('Disponibilidad y Horarios'),
              AvailabilityEditor(
                initialAvailability: _availability,
                onAvailabilityChanged: (newAvailability) => setState(() => _availability = newAvailability),
              ),

              _sectionTitle('Galería de Imágenes'),
              _buildImagePreview(),

              _sectionTitle('Precio y Reglas'),
              TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Precio por hora', prefixIcon: Icon(Icons.monetization_on_outlined), border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => FormValidators.compose(v, [FormValidators.required, FormValidators.isNumeric, FormValidators.isPositiveNumber])),
              const SizedBox(height: 12),
              TextFormField(controller: _minPlayersCtrl, decoration: const InputDecoration(labelText: 'Mínimo de jugadores para reservar', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => FormValidators.compose(v, [FormValidators.required, FormValidators.isNumeric, FormValidators.isPositiveNumber])),
              SwitchListTile(title: const Text('¿Tiene descuento?'), value: _hasDiscount, onChanged: (v) => setState(() => _hasDiscount = v), contentPadding: EdgeInsets.zero),
              if (_hasDiscount)
                TextFormField(controller: _discountCtrl, decoration: const InputDecoration(labelText: '% de descuento', prefixIcon: Icon(Icons.percent), border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => FormValidators.compose(v, [FormValidators.required, FormValidators.isNumeric])),

              _sectionTitle('Contacto'),
              TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()), validator: (v) => FormValidators.compose(v, [FormValidators.required, FormValidators.phone])),
              const SizedBox(height: 12),
              TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()), validator: (v) => FormValidators.compose(v, [FormValidators.required, FormValidators.email])),
              const SizedBox(height: 12),
              TextFormField(controller: _descriptionCtrl, decoration: const InputDecoration(labelText: 'Descripción / Reglas adicionales', border: OutlineInputBorder()), maxLines: 3),

              _sectionTitle('Estado'),
              SwitchListTile(title: const Text('Cancha Activa'), subtitle: const Text('Permitir que los usuarios vean y reserven esta cancha'), value: _isActive, onChanged: (v) => setState(() => _isActive = v), contentPadding: EdgeInsets.zero),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: Text(widget.isEditing ? 'Guardar Cambios' : 'Agregar Cancha'),
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 125, 176, 64), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
        ),
      ],
    );
  }
}