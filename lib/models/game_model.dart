// game_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String id;
  final String ownerId;
  final String groupChatId;
  final String zone;
  final String fieldName;
  final DateTime date;
  final String hour;
  final String description;
  final int playerCount;
  final bool isPublic;
  final double price;
  final double duration;
  final String createdAt;
  final String imageUrl;
  final List<String> usersJoined;
  final String skillLevel;
  final String type;
  final String format;
  final String footwear;

  /// Coordenadas de la cancha (lat/lng) para filtros de distancia
  final GeoPoint? location;

  final String status;
  final int minPlayersToConfirm;
  final String? privateCode;
  final double? fieldRating;
  final String? report;
  final List<String> usersPaid;

  GameModel({
    required this.id,
    required this.ownerId,
    required this.groupChatId,
    required this.zone,
    required this.fieldName,
    required this.date,
    required this.hour,
    required this.description,
    required this.playerCount,
    required this.isPublic,
    required this.price,
    required this.duration,
    required this.createdAt,
    required this.imageUrl,
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
    required this.usersPaid,
  });

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
      zone: map['zone'] ?? '',
      fieldName: map['fieldName'] ?? '',
      date: parseDate(map['date']),
      hour: map['hour'] ?? '',
      description: map['description'] ?? '',
      playerCount: map['playerCount'] ?? 0,
      isPublic: map['isPublic'] ?? true,
      price: (map['price'] ?? 0.0).toDouble(),
      duration: (map['duration'] ?? 1.0).toDouble(),
      createdAt: map['createdAt'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
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
      usersPaid: List<String>.from(map['usersPaid'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'groupChatId': groupChatId,
      'zone': zone,
      'fieldName': fieldName,
      'date': Timestamp.fromDate(date),
      'hour': hour,
      'description': description,
      'playerCount': playerCount,
      'isPublic': isPublic,
      'price': price,
      'duration': duration,
      'createdAt': createdAt,
      'imageUrl': imageUrl,
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
      'usersPaid': usersPaid,
    };
  }

  GameModel copyWith({
    String? id,
    String? ownerId,
    String? groupChatId,
    String? zone,
    String? fieldName,
    DateTime? date,
    String? hour,
    String? description,
    int? playerCount,
    bool? isPublic,
    double? price,
    double? duration,
    String? createdAt,
    String? imageUrl,
    List<String>? usersJoined,
    String? skillLevel,
    String? type,
    String? format,
    String? footwear,
    GeoPoint? location,
    String? status,
    int? minPlayersToConfirm,
    String? privateCode,
    double? fieldRating,
    String? report,
    List<String>? usersPaid,
  }) {
    return GameModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      groupChatId: groupChatId ?? this.groupChatId,
      zone: zone ?? this.zone,
      fieldName: fieldName ?? this.fieldName,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      description: description ?? this.description,
      playerCount: playerCount ?? this.playerCount,
      isPublic: isPublic ?? this.isPublic,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
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
      usersPaid: usersPaid ?? this.usersPaid,
    );
  }
}
