// lib/services/notification_service.dart (o la ruta donde lo tengas)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup_web/models/notification_model.dart'; // ¡Asegúrate que la ruta del modelo es correcta!
import 'package:teamup_web/models/game_model.dart';         // <-- IMPORTACIÓN AÑADIDA para el contexto

class NotificationService {
  final CollectionReference _notificationsCollection =
  FirebaseFirestore.instance.collection('notifications');

  // --- TUS MÉTODOS ORIGINALES (SIN CAMBIOS) ---

  /// Obtener notificaciones de un usuario en tiempo real.
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots() // Obtiene el stream de datos
        .map((snapshot) {
      // Convierte cada documento en un objeto NotificationModel
      return snapshot.docs.map((doc) {
        return NotificationModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Marcar una notificación como leída.
  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({'isRead': true});
  }

  /// Eliminar una notificación.
  Future<void> deleteNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).delete();
  }

  // --- MÉTODO CREATE ACTUALIZADO PARA SER MÁS POTENTE ---

  /// Crear una nueva notificación, dejando que Firestore genere el ID.
  /// Se ha añadido un parámetro opcional 'context' para guardar datos adicionales
  /// que hacen la notificación "accionable", sin alterar tu modelo.
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? senderId,
    Map<String, dynamic>? context, // <-- ACTUALIZACIÓN: Parámetro opcional añadido
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
      senderId: senderId,
    );

    final notificationMap = notification.toMap();
    if (context != null) {
      // Si se proporciona un contexto, lo añadimos al documento que se guarda en Firestore.
      notificationMap['context'] = context;
    }

    await _notificationsCollection.add(notificationMap);
  }


  // --- NUEVAS FUNCIONES AÑADIDAS PARA EL CICLO DE PAGO ---
  // Estos métodos utilizan tu `createNotification` para mantener la lógica centralizada.

  /// 1. Envía una notificación al dueño del partido para que apruebe un pago.
  /// Es llamado por `PaymentService` cuando un usuario notifica su pago.
  Future<void> sendPaymentApprovalRequest({
    required GameModel game,
    required String payingUserId,
    required String payingUserEmail,
    required double amount,
    required String reference,
    required String method, // <-- CORRECCIÓN: Se añade el parámetro que faltaba.
  }) async {
    // Llama a tu método createNotification con los datos correctos.
    await createNotification(
      userId: game.ownerId, // El destinatario es el dueño del partido.
      title: 'Pago por Aprobar',
      body: 'El usuario $payingUserEmail notificó un pago de \$${amount.toStringAsFixed(2)} para tu partido "${game.description}".',
      type: 'payment_approval_request',
      senderId: payingUserId,
      // El contexto es crucial para que el admin sepa qué aprobar.
      context: {
        'gameId': game.id,
        'reference': reference,
        'payingUserId': payingUserId, // Repetimos el ID aquí para fácil acceso.
        'method': method, // <-- CORRECCIÓN: Ahora se guarda el método en el contexto.
      },
    );
  }

  /// 2. Envía una notificación de confirmación al usuario cuyo pago fue aprobado.
  /// Se debe llamar desde tu panel de administración.
  Future<void> sendPaymentConfirmedNotification({
    required String toUserId,
    required String gameId,
    required String gameDescription,
  }) async {
    await createNotification(
      userId: toUserId,
      title: '¡Pago Confirmado!',
      body: 'Tu pago para el partido "$gameDescription" ha sido aprobado. ¡Nos vemos en la cancha!',
      type: 'payment_confirmed',
      senderId: 'system', // O el ID del admin.
      context: {'gameId': gameId}, // Para que el usuario pueda ir al partido.
    );
  }

  /// 3. Envía una notificación de rechazo al usuario cuyo pago no fue válido.
  /// También se debe llamar desde tu panel de administración.
  Future<void> sendPaymentRejectedNotification({
    required String toUserId,
    required String gameId,
    required String gameDescription,
    required String reason,
  }) async {
    await createNotification(
      userId: toUserId,
      title: 'Pago Rechazado',
      body: 'Tu pago para el partido "$gameDescription" fue rechazado. Motivo: $reason.',
      type: 'payment_rejected',
      senderId: 'system',
      context: {'gameId': gameId},
    );
  }
}