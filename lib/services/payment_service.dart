// lib/services/payment_service.dart

import 'dart:io';
import 'dart:convert'; // Necesario para decodificar la respuesta JSON de Cloudinary
import 'package:http/http.dart' as http; // Importamos el paquete http
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup_web/models/game_model.dart';
import 'notification_service.dart';
import 'package:teamup_web/models/payment_notification_model.dart';

/// Este servicio centraliza la lógica de negocio relacionada con la notificación de pagos.
/// Utiliza Cloudinary para la gestión de imágenes de comprobantes.
class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // --- CONFIGURACIÓN DE CLOUDINARY ---
  // Reemplaza estos valores con los de tu cuenta de Cloudinary.
  final String _cloudinaryCloudName = 'drnkgp6xe'; // Tu Cloud Name
  final String _cloudinaryUploadPreset = 'TeamUp'; // Tu Upload Preset (Unsigned)

  /// Sube la imagen del comprobante a Cloudinary y devuelve la URL segura.
  ///
  /// [imageFile]: El archivo de la imagen seleccionada por el usuario.
  /// Retorna la URL segura como un String, o null si ocurre un error.
  Future<String?> _uploadReceiptToCloudinary(File imageFile) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _cloudinaryUploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        // Decodificamos la respuesta JSON y extraemos la 'secure_url'
        final imageUrl = json.decode(responseData)['secure_url'];
        print('✅ Imagen subida a Cloudinary: $imageUrl');
        return imageUrl;
      } else {
        // Si el estado no es 200, algo salió mal.
        print('❌ Error al subir a Cloudinary. Status code: ${response.statusCode}');
        final errorResponse = await response.stream.bytesToString();
        print('Error response: $errorResponse');
        return null;
      }
    } catch (e) {
      print('❌ Excepción al subir imagen a Cloudinary: $e');
      return null;
    }
  }

  /// Procesa la notificación de un pago realizado por un usuario.
  Future<String> notifyPayment({
    required GameModel game,
    required String method,
    required String reference,
    required double amount,
    required int guestsCount,
    File? receiptImage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "Error: No hay un usuario autenticado.";

      final userId = user.uid;
      final paymentNotificationRef = _firestore.collection('payment_notifications').doc();
      String? receiptUrl;

      // --- PASO CLAVE: SUBIR LA IMAGEN A CLOUDINARY (SI EXISTE) ---
      if (receiptImage != null) {
        receiptUrl = await _uploadReceiptToCloudinary(receiptImage);
        if (receiptUrl == null) {
          return "Error al subir la imagen del comprobante. Por favor, inténtalo de nuevo.";
        }
      }

      // --- PASO CLAVE: USAMOS EL NUEVO MODELO ---
      final newPaymentNotification = PaymentNotificationModel(
        notificationId: paymentNotificationRef.id,
        gameId: game.id,
        userId: userId,
        userEmail: user.email ?? 'No disponible',
        method: method,
        reference: reference,
        amount: amount,
        status: 'pending', // Siempre se crea como pendiente
        createdAt: DateTime.now(), // Se puede usar DateTime.now() directamente
        guestsCount: guestsCount,
        receiptUrl: receiptUrl,
      );

      // Guardamos el modelo convertido a mapa en Firestore.
      await paymentNotificationRef.set(newPaymentNotification.toMap());

      // --- ACTUALIZAR EL DOCUMENTO DEL PARTIDO ---
      final gameRef = _firestore.collection('games').doc(game.id);
      await gameRef.update({
        'usersJoined': FieldValue.arrayUnion([userId]),
        'paymentStatus.$userId': 'pending',
        'guests.$userId': guestsCount,
      });

      // --- ENVIAR NOTIFICACIÓN PUSH AL DUEÑO DEL PARTIDO ---
      await _notificationService.sendPaymentApprovalRequest(
        game: game,
        payingUserId: userId,
        payingUserEmail: user.email ?? 'No disponible',
        amount: amount,
        reference: reference,
        method: method,
      );

      return "Success";

    } on FirebaseException catch (e) {
      print("Error de Firebase al notificar pago: ${e.message}");
      return "Hubo un problema de conexión. Por favor, inténtalo de nuevo.";
    } catch (e) {
      print("Error inesperado al notificar pago: $e");
      return "Ocurrió un error inesperado. Por favor, contacta a soporte.";
    }
  }
}