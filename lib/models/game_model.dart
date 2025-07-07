// lib/models/game_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String id;
  final List<String> usersJoined;
  final Map<String, int> guests;

  final Map<String, Map<String, dynamic>> paymentInfo;
  final String ownerId;
  final String groupChatId;
  final String city;
  final String fieldName;
  final DateTime date;
  final String hour;
  final String description;
  final int playerCount;
  final bool isPublic;
  final double price;
  final double duration;
  final String createdAt;
  final List<String> imageUrls;
  final String skillLevel;
  final String type;
  final String format;
  final String footwear;
  final GeoPoint? location;
  final String status;
  final int minPlayersToConfirm;
  final String? privateCode;
  final double? fieldRating;
  final String? report;

  GameModel({
    required this.id,
    required this.ownerId,
    required this.groupChatId,
    required this.city,
    required this.fieldName,
    required this.date,
    required this.hour,
    required this.description,
    required this.playerCount,
    required this.isPublic,
    required this.price,
    required this.duration,
    required this.createdAt,
    required this.imageUrls,
    required this.usersJoined,
    required this.skillLevel,
    required this.type,
    required this.format,
    required this.footwear,
    this.location,
    required this.status,
    required this.minPlayersToConfirm,
    this.privateCode,
    this.fieldRating,
    this.report,
    required this.guests,
    required this.paymentInfo,
  });

  int get totalPlayers => usersJoined.length + guests.values.fold(0, (sum, count) => sum + count);

  factory GameModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return GameModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      groupChatId: map['groupChatId'] ?? '',
      city: map['city'] ?? '',
      fieldName: map['fieldName'] ?? '',
      date: parseDate(map['date']),
      hour: map['hour'] ?? '',
      description: map['description'] ?? '',
      playerCount: map['playerCount'] ?? 0,
      isPublic: map['isPublic'] ?? true,
      price: (map['price'] ?? 0.0).toDouble(),
      duration: (map['duration'] ?? 1.0).toDouble(),
      createdAt: map['createdAt'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      usersJoined: List<String>.from(map['usersJoined'] ?? []),
      skillLevel: map['skillLevel'] ?? '',
      type: map['type'] ?? '',
      format: map['format'] ?? '7v7',
      footwear: map['footwear'] ?? 'any',
      location: map['location'] as GeoPoint?,
      status: map['status'] ?? 'waiting',
      minPlayersToConfirm: map['minPlayersToConfirm'] ?? 0,
      privateCode: map['privateCode'],
      fieldRating: map['fieldRating'] != null ? (map['fieldRating'] as num).toDouble() : null,
      report: map['report'],
      guests: Map<String, int>.from(map['guests'] ?? {}),
      paymentInfo: Map<String, Map<String, dynamic>>.from(map['paymentInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'groupChatId': groupChatId,
      'city': city,
      'fieldName': fieldName,
      'date': Timestamp.fromDate(date),
      'hour': hour,
      'description': description,
      'playerCount': playerCount,
      'isPublic': isPublic,
      'price': price,
      'duration': duration,
      'createdAt': createdAt,
      'imageUrls': imageUrls,
      'usersJoined': usersJoined,
      'skillLevel': skillLevel,
      'type': type,
      'format': format,
      'footwear': footwear,
      'location': location,
      'status': status,
      'minPlayersToConfirm': minPlayersToConfirm,
      'privateCode': privateCode,
      'fieldRating': fieldRating,
      'report': report,
      'guests': guests,
      'paymentInfo': paymentInfo, // <-- CAMBIO
    };
  }

  GameModel copyWith({
    String? id,
    // ... otros ...
    Map<String, int>? guests,
    Map<String, Map<String, dynamic>>? paymentInfo, // <-- CAMBIO
  }) {
    return GameModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      groupChatId: groupChatId ?? this.groupChatId,
      city: city ?? this.city,
      fieldName: fieldName ?? this.fieldName,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      description: description ?? this.description,
      playerCount: playerCount ?? this.playerCount,
      isPublic: isPublic ?? this.isPublic,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
      usersJoined: usersJoined ?? this.usersJoined,
      skillLevel: skillLevel ?? this.skillLevel,
      type: type ?? this.type,
      format: format ?? this.format,
      footwear: footwear ?? this.footwear,
      location: location ?? this.location,
      status: status ?? this.status,
      minPlayersToConfirm: minPlayersToConfirm ?? this.minPlayersToConfirm,
      privateCode: privateCode ?? this.privateCode,
      fieldRating: fieldRating ?? this.fieldRating,
      report: report ?? this.report,
      guests: guests ?? this.guests,
      paymentInfo: paymentInfo ?? this.paymentInfo, // <-- CAMBIO
    );
  }
}