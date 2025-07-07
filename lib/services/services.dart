import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reemplaza estos valores con los de tu cuenta de Cloudinary.
  static const String _cloudName = 'drnkgp6xe';
  static const String _uploadPreset = 'TeamUp';

  Stream<QuerySnapshot> getFieldsStream() {
    return _db.collection('fields').snapshots();
  }

  Stream<QuerySnapshot> getCitiesStream() {
    return _db.collection('cities').orderBy('name').snapshots();
  }

  Future<void> deleteField(String docId) {
    return _db.collection('fields').doc(docId).delete();
  }

  Future<void> saveField({
    required Map<String, dynamic> data,
    String? docId,
    List<XFile> newFiles = const [],
    List<Uint8List> newBytes = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado. Por favor, inicie sesión.');
    }

    final uploadedUrls = await _uploadImages(newFiles, newBytes);

    final existingUrls = data['imageUrls'] as List<dynamic>? ?? [];
    data['imageUrls'] = [...existingUrls, ...uploadedUrls];

    data['ownerId'] = user.uid;
    data['updatedAt'] = Timestamp.now();

    if (docId != null) {
      await _db.collection('fields').doc(docId).update(data);
    } else {
      data['createdAt'] = Timestamp.now();
      await _db.collection('fields').add(data);
    }
  }

  Future<List<String>> _uploadImages(List<XFile> files, List<Uint8List> bytes) async {
    if (files.isEmpty && bytes.isEmpty) return [];

    final uploadedUrls = <String>[];
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

    // Procesar archivos de tipo XFile (móvil/desktop)
    for (final file in files) {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));
      final url = await _sendUploadRequest(request);
      if (url != null) uploadedUrls.add(url);
    }

    // Procesar archivos de tipo Uint8List (web)
    for (final byteData in bytes) {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(http.MultipartFile.fromBytes('file', byteData, filename: 'upload.png'));
      final url = await _sendUploadRequest(request);
      if (url != null) uploadedUrls.add(url);
    }

    return uploadedUrls;
  }

  Future<String?> _sendUploadRequest(http.MultipartRequest request) async {
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = jsonDecode(responseData);
        return decodedData['secure_url'];
      } else {
        final errorBody = await response.stream.bytesToString();
        debugPrint('Error al subir imagen: ${response.statusCode}');
        debugPrint('Cuerpo del error: $errorBody');
        throw Exception('Error al subir la imagen: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Excepción al subir imagen: $e');
      throw Exception('Excepción al subir la imagen: $e');
    }
  }
}