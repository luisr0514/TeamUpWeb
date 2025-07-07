import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa un partido en la aplicación.
///
/// Contiene toda la información relevante de un partido, desde los detalles
/// del evento hasta la lista de jugadores, sus invitados y el estado de sus pagos.
class GameModel {
  final String id;
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

  // ▼▼▼ CAMBIO PRINCIPAL ▼▼▼
  /// Lista de URLs de las imágenes del partido para la galería.
  final List<String> imageUrls;
  // ▲▲▲ FIN DEL CAMBIO ▲▲▲

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

  /// Lista de UIDs de los usuarios que se han unido directamente.
  final List<String> usersJoined;

  /// Mapa para gestionar los invitados.
  /// La clave (String) es el UID del usuario anfitrión.
  /// El valor (int) es el número de invitados que trae ese usuario.
  /// Ejemplo: {'uid_de_carlos': 2} significa que Carlos trae a 2 invitados.
  final Map<String, int> guests;

  /// Mapa para rastrear el estado del pago de cada usuario.
  /// Clave: UID del usuario.
  /// Valor: Estado del pago ('pending', 'paid', 'rejected').
  /// Ejemplo: {'uid_user1': 'pending', 'uid_user2': 'paid'}
  final Map<String, String> paymentStatus;

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
    required this.imageUrls, // <-- CAMBIO: Se usa la lista de URLs
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
    required this.paymentStatus,
  });

  /// Getter para calcular el número total de plazas ocupadas.
  /// Suma los usuarios unidos directamente más todos los invitados.
  int get totalPlayers => usersJoined.length + guests.values.fold(0, (sum, count) => sum + count);

  /// Constructor factory para crear una instancia de GameModel desde un mapa (documento de Firestore).
  factory GameModel.fromMap(Map<String, dynamic> map) {
    // Función de ayuda para parsear la fecha de forma segura
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
      // ▼▼▼ CAMBIO ▼▼▼
      // Parsea la lista de URLs. Si no existe o no es una lista, devuelve una lista vacía.
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      // ▲▲▲ FIN DEL CAMBIO ▲▲▲
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
      paymentStatus: Map<String, String>.from(map['paymentStatus'] ?? {}),
    );
  }

  /// Convierte la instancia de GameModel a un mapa para guardarlo en Firestore.
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
      // ▼▼▼ CAMBIO ▼▼▼
      'imageUrls': imageUrls, // <-- CAMBIO: Se añade la lista al mapa
      // ▲▲▲ FIN DEL CAMBIO ▲▲▲
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
      'paymentStatus': paymentStatus,
    };
  }

  /// Crea una copia del objeto GameModel con los campos proporcionados actualizados.
  GameModel copyWith({
    String? id,
    String? ownerId,
    String? groupChatId,
    String? city,
    String? fieldName,
    DateTime? date,
    String? hour,
    String? description,
    int? playerCount,
    bool? isPublic,
    double? price,
    double? duration,
    String? createdAt,
    // ▼▼▼ CAMBIO ▼▼▼
    List<String>? imageUrls, // <-- CAMBIO: Se añade al copyWith
    // ▲▲▲ FIN DEL CAMBIO ▲▲▲
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
    Map<String, int>? guests,
    Map<String, String>? paymentStatus,
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
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}