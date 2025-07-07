// lib/models/payment_notification_model.dart - CORREGIDO

import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentNotificationModel {
  final String notificationId; // Este ahora será el ID real del documento
  final String gameId;
  final String userId;
  final String userEmail;
  final String method;
  final String reference;
  final double amount;
  final String status;
  final DateTime createdAt;
  final int guestsCount;
  final String? receiptUrl;

  PaymentNotificationModel({
    required this.notificationId,
    required this.gameId,
    required this.userId,
    required this.userEmail,
    required this.method,
    required this.reference,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.guestsCount,
    this.receiptUrl,
  });

  // ▼▼▼ CAMBIO PRINCIPAL: Este es el método que soluciona el error ▼▼▼
  /// Crea una instancia del modelo desde un DocumentSnapshot de Firestore.
  factory PaymentNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return PaymentNotificationModel(
      notificationId: doc.id, // Obtenemos el ID directamente del documento
      gameId: map['gameId'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      method: map['method'] ?? 'N/A',
      reference: map['reference'] ?? 'N/A',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      guestsCount: map['guestsCount'] ?? 0,
      receiptUrl: map['receiptUrl'],
    );
  }

  /// Convierte la instancia del modelo a un mapa para guardarlo en Firestore.
  Map<String, dynamic> toMap() {
    return {
      // Ya no guardamos 'notificationId' en el mapa, es redundante.
      'gameId': gameId,
      'userId': userId,
      'userEmail': userEmail,
      'method': method,
      'reference': reference,
      'amount': amount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'guestsCount': guestsCount,
      'receiptUrl': receiptUrl,
    };
  }
}