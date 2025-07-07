// lib/services/game_service.dart (Para el proyecto WEB de Administración)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:teamup_web/models/game_model.dart';

/// Servicio para gestionar las operaciones y la lógica de negocio de los partidos
/// desde el panel de administración.
class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Es una buena práctica tipar la referencia de la colección.
  final CollectionReference<Map<String, dynamic>> _gamesCollection;

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

  /// Aprueba el pago de un jugador específico en un partido.
  /// Actualiza el estado a 'approved' dentro del mapa 'paymentInfo'.
  Future<void> approvePayment(String gameId, String userId) async {
    try {
      // CORRECCIÓN: La ruta correcta para actualizar un campo anidado en un mapa.
      final String fieldPath = 'paymentInfo.$userId.status';

      await _gamesCollection.doc(gameId).update({
        fieldPath: 'approved', // Se establece el estado a 'approved'.
      });

      if (kDebugMode) {
        print("✅ Pago APROBADO para el usuario $userId en el partido $gameId.");
      }

      // Aquí podrías llamar al NotificationService para notificar al usuario.
      // await _notificationService.sendPaymentConfirmedNotification(...);

    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al aprobar el pago: $e");
      }
      rethrow;
    }
  }

  /// Rechaza el pago de un jugador, marca su estado como 'rejected' y lo expulsa del partido.
  Future<void> rejectPayment(String gameId, String userId) async {
    try {
      final String fieldPath = 'paymentInfo.$userId.status';

      // Se realizan ambas operaciones en una sola actualización atómica.
      await _gamesCollection.doc(gameId).update({
        fieldPath: 'rejected', // 1. Marca el pago como rechazado.
        'usersJoined': FieldValue.arrayRemove([userId]), // 2. Elimina al usuario de la lista de unidos.
      });

      if (kDebugMode) {
        print("🗑️ Pago RECHAZADO y usuario $userId expulsado del partido $gameId.");
      }

      // OPCIONAL: Actualizar el estado general del partido (e.g., de 'full' a 'confirmed').
      final game = await getGame(gameId);
      if (game != null) {
        await updateGameStatus(game);
      }
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