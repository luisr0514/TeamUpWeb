import 'package:cloud_firestore/cloud_firestore.dart';

class FieldModel {
  final String id;
  final String ownerId;
  final String name;
  final String zone;
  final double lat;
  final double lng;
  final String surfaceType;
  final double pricePerHour;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, List<String>> availability;

  final String format;
  final double duration;
  final String description;
  final String footwear;
  final String contact;


  final bool hasDiscount;
  final double? discountPercentage;
  final int minPlayersToBook;

  FieldModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.zone,
    required this.lat,
    required this.lng,
    required this.surfaceType,
    required this.pricePerHour,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.availability,
    required this.format,
    required this.duration,
    required this.description,
    required this.footwear,
    required this.contact,
    this.hasDiscount = false,
    this.discountPercentage,
    this.minPlayersToBook = 1,
  });

  factory FieldModel.fromMap(Map<String, dynamic> map, String id) {
    return FieldModel(
      id: id,
      ownerId: map['ownerId'],
      name: map['name'],
      zone: map['zone'],
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      surfaceType: map['surfaceType'],
      pricePerHour: (map['pricePerHour'] as num).toDouble(),
      imageUrl: map['photoUrl'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      availability: (map['availability'] as Map).map(
            (key, value) => MapEntry(
          key.toString(),
          List<String>.from(value ?? []),
        ),
      ),
      format: map['format'] ?? '7v7',
      duration: (map['duration'] ?? 1.5).toDouble(),
      description: map['description'] ?? '',
      footwear: map['footwear'] ?? 'any',
      contact: map['contact'] ?? '',
      hasDiscount: map['hasDiscount'] ?? false,
      discountPercentage: map['discountPercentage'] != null
          ? (map['discountPercentage'] as num).toDouble()
          : null,
      minPlayersToBook: map['minPlayersToBook'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'zone': zone,
      'lat': lat,
      'lng': lng,
      'surfaceType': surfaceType,
      'pricePerHour': pricePerHour,
      'photoUrl': imageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'availability': availability,
      'format': format,
      'duration': duration,
      'description': description,
      'footwear': footwear,
      'contact': contact,
      'hasDiscount': hasDiscount,
      'discountPercentage': discountPercentage,
      'minPlayersToBook': minPlayersToBook,
    };
  }

  /// 🔢 Calcula el precio por jugador asumiendo que se unen el mínimo necesario
  double getPricePerPersonAuto() {
    double totalPrice = pricePerHour * duration;

    if (hasDiscount && discountPercentage != null) {
      totalPrice *= (1 - discountPercentage! / 100);
    }

    if (minPlayersToBook <= 0) return totalPrice;

    return totalPrice / minPlayersToBook;
  }
}
