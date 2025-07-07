import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa una cancha (Field) en la aplicación.
///
/// Contiene toda la información relevante de una cancha, incluyendo su ubicación,
/// precios, disponibilidad y galería de imágenes.
class FieldModel {
  final String id;
  final String ownerId;
  final String name;
  final String city;
  final double lat;
  final double lng;
  final String surfaceType;
  final double pricePerHour;
  final List<String> imageUrls;

  final bool isActive;
  final DateTime createdAt;
  final Map<String, List<String>> availability;
  final String format;
  final double duration;
  final String description;

  final String phone;
  final String email;

  final bool hasDiscount;
  final double? discountPercentage;
  final int minPlayersToBook;

  FieldModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.city,
    required this.lat,
    required this.lng,
    required this.surfaceType,
    required this.pricePerHour,
    required this.imageUrls,
    required this.isActive,
    required this.createdAt,
    required this.availability,
    required this.format,
    required this.duration,
    required this.description,
    required this.phone,
    required this.email,
    this.hasDiscount = false,
    this.discountPercentage,
    this.minPlayersToBook = 1,
  });

  /// Coordenadas combinadas de la cancha para filtros de distancia
  GeoPoint get location => GeoPoint(lat, lng);

  /// Constructor factory para crear una instancia de FieldModel desde un mapa.
  factory FieldModel.fromMap(Map<String, dynamic> map, String id) {
    return FieldModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      city: map['city'] ?? map['zone'] ?? '',
      lat: (map['lat'] as num? ?? 0.0).toDouble(),
      lng: (map['lng'] as num? ?? 0.0).toDouble(),
      surfaceType: map['surfaceType'] ?? '',
      pricePerHour: (map['pricePerHour'] as num? ?? 0.0).toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      availability: (map['availability'] as Map? ?? {}).map(
            (k, v) => MapEntry(k.toString(), List<String>.from(v ?? [])),
      ),
      format: map['format'] ?? '',
      duration: (map['duration'] as num? ?? 1.0).toDouble(),
      description: map['description'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      hasDiscount: map['hasDiscount'] ?? false,
      discountPercentage: map['discountPercentage'] != null
          ? (map['discountPercentage'] as num).toDouble()
          : null,
      minPlayersToBook: map['minPlayersToBook'] ?? 1,
    );
  }

  /// Convierte la instancia de FieldModel a un mapa para guardar en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'city': city,
      'lat': lat,
      'lng': lng,
      'surfaceType': surfaceType,
      'pricePerHour': pricePerHour,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'availability': availability,
      'format': format,
      'duration': duration,
      'description': description,
      'phone': phone,
      'email': email,
      'hasDiscount': hasDiscount,
      'discountPercentage': discountPercentage,
      'minPlayersToBook': minPlayersToBook,
    };
  }

  /// Calcula el precio por jugador asumiendo que se unen el mínimo necesario.
  double getPricePerPersonAuto() {
    double total = pricePerHour * duration;
    if (hasDiscount && discountPercentage != null && discountPercentage! > 0) {
      total *= (1 - discountPercentage! / 100);
    }
    return minPlayersToBook > 0 ? total / minPlayersToBook : total;
  }
}