// lib/features/auth/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String profileImageUrl;
  final bool isVerified;
  final bool blocked;
  final String? banReason;
  final int reports;
  final int totalGamesCreated;
  final int totalGamesJoined;
  final String position;
  final String skillLevel;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final String notesByAdmin;
  final VerificationData? verification;
  final List<String> friends;
  final List<String> friendRequestsSent;
  final List<String> friendRequestsReceived;
  final int ratingCount;
  final double ratingSum;
  final List<String> blockedUsers;
  final double walletBalance;

  double get averageRating => (ratingCount > 0) ? ratingSum / ratingCount : 0.0;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.isVerified,
    required this.blocked,
    this.banReason,
    required this.reports,
    required this.totalGamesCreated,
    required this.totalGamesJoined,
    required this.position,
    required this.skillLevel,
    this.lastLoginAt,
    this.createdAt,
    required this.notesByAdmin,
    this.verification,
    required this.friends,
    required this.friendRequestsSent,
    required this.friendRequestsReceived,
    required this.ratingCount,
    required this.ratingSum,
    required this.blockedUsers,
    this.walletBalance = 0.0, // <-- NUEVO: Valor por defecto
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImageUrl: map['profileImage'] ?? '',
      isVerified: map['isVerified'] ?? false,
      blocked: map['blocked'] ?? false,
      banReason: map['banReason'],
      reports: map['reports'] ?? 0,
      totalGamesCreated: map['totalGamesCreated'] ?? 0,
      totalGamesJoined: map['totalGamesJoined'] ?? 0,
      position: map['position'] ?? '',
      skillLevel: map['skillLevel'] ?? '',
      lastLoginAt: map['lastLoginAt'] is Timestamp ? (map['lastLoginAt'] as Timestamp).toDate() : null,
      createdAt: map['createdAt'] is Timestamp ? (map['createdAt'] as Timestamp).toDate() : null,
      notesByAdmin: map['notesByAdmin'] ?? '',
      verification: map['verification'] != null ? VerificationData.fromMap(map['verification']) : null,
      friends: List<String>.from(map['friends'] ?? []),
      friendRequestsSent: List<String>.from(map['friendRequestsSent'] ?? []),
      friendRequestsReceived: List<String>.from(map['friendRequestsReceived'] ?? []),
      ratingCount: map['ratingCount'] ?? 0,
      ratingSum: (map['ratingSum'] ?? 0.0).toDouble(),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(), // <-- NUEVO: Lectura desde Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'profileImage': profileImageUrl,
      'isVerified': isVerified,
      'blocked': blocked,
      'banReason': banReason,
      'reports': reports,
      'totalGamesCreated': totalGamesCreated,
      'totalGamesJoined': totalGamesJoined,
      'position': position,
      'skillLevel': skillLevel,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'notesByAdmin': notesByAdmin,
      'verification': verification?.toMap(),
      'friends': friends,
      'friendRequestsSent': friendRequestsSent,
      'friendRequestsReceived': friendRequestsReceived,
      'ratingCount': ratingCount,
      'ratingSum': ratingSum,
      'blockedUsers': blockedUsers,
      'walletBalance': walletBalance, // <-- NUEVO: Escritura a Firestore
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? profileImageUrl,
    bool? isVerified,
    bool? blocked,
    String? banReason,
    int? reports,
    int? totalGamesCreated,
    int? totalGamesJoined,
    String? position,
    String? skillLevel,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    String? notesByAdmin,
    VerificationData? verification,
    List<String>? friends,
    List<String>? friendRequestsSent,
    List<String>? friendRequestsReceived,
    int? ratingCount,
    double? ratingSum,
    List<String>? blockedUsers,
    double? walletBalance, // <-- NUEVO
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      blocked: blocked ?? this.blocked,
      banReason: banReason ?? this.banReason,
      reports: reports ?? this.reports,
      totalGamesCreated: totalGamesCreated ?? this.totalGamesCreated,
      totalGamesJoined: totalGamesJoined ?? this.totalGamesJoined,
      position: position ?? this.position,
      skillLevel: skillLevel ?? this.skillLevel,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      notesByAdmin: notesByAdmin ?? this.notesByAdmin,
      verification: verification ?? this.verification,
      friends: friends ?? this.friends,
      friendRequestsSent: friendRequestsSent ?? this.friendRequestsSent,
      friendRequestsReceived: friendRequestsReceived ?? this.friendRequestsReceived,
      ratingCount: ratingCount ?? this.ratingCount,
      ratingSum: ratingSum ?? this.ratingSum,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      walletBalance: walletBalance ?? this.walletBalance, // <-- NUEVO
    );
  }
}

// El resto del archivo (VerificationData) no necesita cambios.
@immutable
class VerificationData {
  // ... sin cambios ...
  final String idCardFrontUrl;
  final String idCardBackUrl;
  final String faceWithIdUrl;
  final String status;
  final String? rejectionReason;

  const VerificationData({
    required this.idCardFrontUrl,
    required this.idCardBackUrl,
    required this.faceWithIdUrl,
    required this.status,
    this.rejectionReason,
  });

  factory VerificationData.fromMap(Map<String, dynamic> map) {
    return VerificationData(
      idCardFrontUrl: map['idCardFrontUrl'] ?? '',
      idCardBackUrl: map['idCardBackUrl'] ?? '',
      faceWithIdUrl: map['faceWithIdUrl'] ?? '',
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idCardFrontUrl': idCardFrontUrl,
      'idCardBackUrl': idCardBackUrl,
      'faceWithIdUrl': faceWithIdUrl,
      'status': status,
      'rejectionReason': rejectionReason,
    };
  }
}