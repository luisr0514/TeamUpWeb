// lib/services/game_service.dart (Para el proyecto WEB de Administración)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:teamup_web/models/game_model.dart';
import 'package:teamup_web/services/notification_service.dart';

/// Servicio para gestionar las operaciones y la lógica de negocio de los partidos
/// desde el panel de administración.
class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Es una buena práctica tipar la referencia de la colección.
  final CollectionReference<Map<String, dynamic>> _gamesCollection;
  final NotificationService _notificationService = NotificationService();

  GameService() : _gamesCollection = FirebaseFirestore.instance.collection('games');

  // --- MÉTODOS DE LECTURA DE DATOS ---

  /// Obtiene un Stream de una lista de todos los partidos, ordenados por fecha ascendente.
  Stream<List<GameModel>> getGamesStream() {
    return _gamesCollection
        .orderBy('date', descending: false) // false para ver los próximos partidos primero
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      // CORRECCIÓN: Se inyecta el ID del documento en los datos antes de crear el modelo,
      // para asegurar que el modelo `GameModel` tenga su propio ID.
      final data = doc.data();
      data['id'] = doc.id;
      return GameModel.fromMap(data);
    }).toList());
  }

  /// Obtiene un único partido por su ID.
  Future<GameModel?> getGame(String id) async {
    final doc = await _gamesCollection.doc(id).get();
    if (doc.exists) {
      // CORRECCIÓN: Al igual que en el Stream, se inyecta el ID del documento.
      final data = doc.data()!;
      data['id'] = doc.id;
      return GameModel.fromMap(data);
    }
    return null;
  }

  // --- MÉTODOS DE ACCIÓN PARA EL ADMINISTRADOR ---

  Future<void> approvePayment(String gameId, String userId) async {
    try {
      // 1. Obtener los datos del partido para usarlos en la notificación
      final game = await getGame(gameId);
      if (game == null) {
        throw Exception('No se pudo encontrar el partido para enviar la notificación.');
      }

      // 2. Actualizar el estado del pago en Firestore
      final String fieldPath = 'paymentInfo.$userId.status';
      await _gamesCollection.doc(gameId).update({
        fieldPath: 'approved',
      });

      if (kDebugMode) {
        print("✅ Pago APROBADO para el usuario $userId en el partido $gameId.");
      }

      await _notificationService.sendPaymentConfirmedNotification(
        toUserId: userId,
        gameId: gameId,
        gameDescription: game.description,
      );

      if (kDebugMode) {
        print("📬 Notificación de pago confirmado enviada a $userId.");
      }

    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al aprobar el pago: $e");
      }
      rethrow;
    }
  }

  /// <-- EXTRA: También podemos conectar la notificación de RECHAZO
  /// Rechaza el pago de un jugador, marca su estado como 'rejected' y lo expulsa del partido.
  Future<void> rejectPayment(String gameId, String userId, {String reason = 'No se pudo verificar el comprobante.'}) async {
    try {
      final game = await getGame(gameId);
      if (game == null) {
        throw Exception('No se pudo encontrar el partido para enviar la notificación.');
      }

      final String fieldPath = 'paymentInfo.$userId.status';
      await _gamesCollection.doc(gameId).update({
        fieldPath: 'rejected',
        'usersJoined': FieldValue.arrayRemove([userId]),
      });

      if (kDebugMode) {
        print("🗑️ Pago RECHAZADO y usuario $userId expulsado del partido $gameId.");
      }

      // <-- CONEXIÓN: Enviar notificación de rechazo
      await _notificationService.sendPaymentRejectedNotification(
        toUserId: userId,
        gameId: gameId,
        gameDescription: game.description,
        reason: reason, // Aquí podrías permitir al admin escribir un motivo
      );

      if (kDebugMode) {
        print("📬 Notificación de pago rechazado enviada a $userId.");
      }

      await updateGameStatus(game);

    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al rechazar el pago y expulsar al usuario $userId: $e");
      }
      rethrow;
    }
  }

  /// Elimina a un jugador y todos sus datos asociados de un partido (usado para expulsiones manuales).
  Future<void> removePlayerFromGame(String gameId, String playerId) async {
    final gameRef = _gamesCollection.doc(gameId);
    try {
      await _firestore.runTransaction((transaction) async {
        final gameDoc = await transaction.get(gameRef);

        if (!gameDoc.exists) {
          throw Exception('El partido no fue encontrado.');
        }

        // CORRECCIÓN: Se eliminan las entradas correctas para mantener la consistencia.
        transaction.update(gameRef, {
          'usersJoined': FieldValue.arrayRemove([playerId]), // Quita al jugador de la lista.
          'guests.$playerId': FieldValue.delete(), // Quita si tenía invitados.
          'paymentInfo.$playerId': FieldValue.delete(), // Quita toda su información de pago.
        });
      });
      if (kDebugMode) {
        print("🗑️ Jugador $playerId y sus datos eliminados del partido $gameId.");
      }

      final game = await getGame(gameId);
      if (game != null) {
        await updateGameStatus(game);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al eliminar jugador $playerId del partido $gameId: $e");
      }
      rethrow;
    }
  }

  /// Actualiza el estado de un partido ('scheduled', 'confirmed', 'full')
  /// basado en el número actual de jugadores.
  Future<void> updateGameStatus(GameModel game) async {
    final int currentPlayers = game.totalPlayers;
    final int minToConfirm = game.minPlayersToConfirm;
    final int capacity = game.playerCount;

    String newStatus;
    if (currentPlayers >= capacity) {
      newStatus = 'full';
    } else if (currentPlayers >= minToConfirm) {
      newStatus = 'confirmed';
    } else {
      newStatus = 'scheduled';
    }

    if (game.status != newStatus) {
      await _gamesCollection.doc(game.id).update({'status': newStatus});
      if (kDebugMode) {
        print('🔄 Estado del partido ${game.id} actualizado a: $newStatus');
      }
    }
  }
}