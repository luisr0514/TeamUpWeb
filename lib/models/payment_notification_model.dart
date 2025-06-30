import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un registro de una notificación de pago.
/// Este objeto contiene todos los detalles que un administrador necesita para verificar un pago.
class PaymentNotificationModel {
  final String notificationId;
  final String gameId;
  final String userId;
  final String userEmail;
  final String method;
  final String reference;
  final double amount;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final int guestsCount;
  final String? receiptUrl; // La URL de la imagen del comprobante (opcional)

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

  /// Crea una instancia del modelo desde un documento de Firestore.
  factory PaymentNotificationModel.fromMap(Map<String, dynamic> map) {
    return PaymentNotificationModel(
      notificationId: map['notificationId'] ?? '',
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
      'notificationId': notificationId,
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