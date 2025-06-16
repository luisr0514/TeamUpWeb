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
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
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
    );
  }
}


@immutable
class VerificationData {
  final String idCardUrl;
  final String faceImageUrl;
  final String status;
  final String? rejectionReason;

  const VerificationData({
    required this.idCardUrl,
    required this.faceImageUrl,
    required this.status,
    this.rejectionReason,
  });

  factory VerificationData.fromMap(Map<String, dynamic> map) {
    return VerificationData(
      idCardUrl: map['idCardUrl'] ?? '',
      faceImageUrl: map['faceImageUrl'] ?? '',
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idCardUrl': idCardUrl,
      'faceImageUrl': faceImageUrl,
      'status': status,
      'rejectionReason': rejectionReason,
    };
  }
}