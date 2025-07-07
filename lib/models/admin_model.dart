// lib/models/admin_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para definir los roles DENTRO del panel de administración.
// Por ejemplo, un super admin puede gestionar otros admins,
// mientras que un fieldManager solo puede ver y editar canchas.
enum AdminRole { superAdmin, fieldManager, support }

// Funciones auxiliares para convertir el enum a/desde String
String adminRoleToString(AdminRole role) {
  return role.toString().split('.').last;
}

AdminRole adminRoleFromString(String? roleString) {
  if (roleString == null) return AdminRole.fieldManager; // Rol por defecto
  return AdminRole.values.firstWhere(
        (e) => adminRoleToString(e) == roleString,
    orElse: () => AdminRole.fieldManager,
  );
}

class AdminModel {
  final String id;
  final String email;
  final AdminRole role;
  final String displayName;
  final Timestamp createdAt;

  AdminModel({
    required this.id,
    required this.email,
    required this.role,
    required this.displayName,
    required this.createdAt,
  });

  // Constructor para crear un AdminModel desde un documento de Firestore
  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      id: doc.id,
      email: data['email'] ?? 'No email',
      role: adminRoleFromString(data['role']),
      displayName: data['displayName'] ?? 'Sin Nombre',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Método para convertir el AdminModel a un mapa para guardarlo en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': adminRoleToString(role),
      'displayName': displayName,
      'createdAt': createdAt,
    };
  }
}