// lib/services/game_service.dart (Para el proyecto WEB de Administración)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:teamup_web/models/game_model.dart'; // Asegúrate de que este modelo es el mismo que en la app de usuario

/// Servicio para gestionar las operaciones y la lógica de negocio de los partidos
/// desde el panel de administración.
class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference<Map<String, dynamic>> _gamesCollection;

  GameService() : _gamesCollection = FirebaseFirestore.instance.collection('games');

  // --- MÉTODOS DE LECTURA DE DATOS ---

  /// Obtiene un Stream de una lista de todos los partidos, ordenados por fecha.
  /// Ideal para la vista principal del panel de administración.
  Stream<List<GameModel>> getGamesStream() {
    return _gamesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GameModel.fromMap(doc.data()))
        .toList());
  }

  /// Obtiene un único partido por su ID. Útil para operaciones específicas.
  Future<GameModel?> getGame(String id) async {
    final doc = await _gamesCollection.doc(id).get();
    if (doc.exists) {
      return GameModel.fromMap(doc.data()!);
    }
    return null;
  }

  // --- MÉTODOS DE ACCIÓN PARA EL ADMINISTRADOR ---

  /// Aprueba el pago de un jugador específico en un partido.
  Future<void> approvePayment(String gameId, String userId) async {
    try {
      await _gamesCollection.doc(gameId).update({
        'paymentStatus.$userId': 'paid',
      });
      if (kDebugMode) {
        print("✅ Pago aprobado para el usuario $userId en el partido $gameId.");
      }
      // Aquí podrías llamar al NotificationService para notificar al usuario.
      // await _notificationService.sendPaymentConfirmedNotification(...);
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al aprobar el pago: $e");
      }
      // Re-lanzar el error para que la UI pueda manejarlo si es necesario.
      rethrow;
    }
  }

  /// Rechaza el pago de un jugador, lo que implica eliminarlo del partido.
  Future<void> rejectPayment(String gameId, String userId) async {
    // La lógica de rechazar un pago es la misma que expulsar al jugador,
    // ya que su lugar no puede quedar reservado si el pago no es válido.
    await removePlayerFromGame(gameId, userId);
  }

  /// Elimina a un jugador y todos sus datos asociados de un partido.
  /// Este es el método central para expulsar o rechazar pagos.
  Future<void> removePlayerFromGame(String gameId, String playerId) async {
    final gameRef = _gamesCollection.doc(gameId);
    try {
      await _firestore.runTransaction((transaction) async {
        final gameDoc = await transaction.get(gameRef);

        if (!gameDoc.exists) {
          throw Exception('El partido no fue encontrado.');
        }

        // En una sola transacción, eliminamos todos los datos del jugador del partido
        // para mantener la consistencia de los datos.
        transaction.update(gameRef, {
          'usersJoined': FieldValue.arrayRemove([playerId]),
          'guests.$playerId': FieldValue.delete(),
          'paymentStatus.$playerId': FieldValue.delete(),
        });
      });
      if (kDebugMode) {
        print("🗑️ Jugador $playerId y sus datos eliminados del partido $gameId.");
      }

      // Después de eliminar al jugador, actualizamos el estado general del partido.
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

    // Solo actualiza si el estado ha cambiado para evitar escrituras innecesarias.
    if (game.status != newStatus) {
      await _gamesCollection.doc(game.id).update({'status': newStatus});
      if (kDebugMode) {
        print('🔄 Estado del partido ${game.id} actualizado a: $newStatus');
      }
    }
  }
}