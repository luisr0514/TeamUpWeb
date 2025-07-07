// lib/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup_web/models/admin_model.dart'; // <-- 1. IMPORTA EL NUEVO MODELO

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 2. Apunta a la colección 'admins'
  final CollectionReference _adminsCollection = FirebaseFirestore.instance.collection('admins');

  // Método de inicio de sesión MÁS SEGURO
  Future<User?> singIn(String email, String password) async {
    try {
      // 1. Autentica con Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // 2. VERIFICA si el usuario existe en la colección 'admins'
        final adminDoc = await _adminsCollection.doc(user.uid).get();

        if (!adminDoc.exists) {
          // Si no existe, es un usuario normal o no tiene permisos. Lo deslogueamos.
          await signOut();
          throw Exception('Acceso denegado. No tienes permisos de administrador.');
        }

        print("Inicio de sesión de admin correcto: ${user.email}");
        return user;
      }
      return null;
    } catch (e) {
      print('Error de inicio de sesión: $e');
      // Re-lanza la excepción para que la UI pueda mostrar el mensaje de error
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  // Método de registro para NUEVOS ADMINISTRADORES
  Future<User?> register(String email, String password, {String displayName = 'Nuevo Admin'}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? newUser = result.user;

      if (newUser != null) {
        // Crea el modelo de administrador
        final newAdmin = AdminModel(
          id: newUser.uid,
          email: email,
          // Por defecto, un nuevo admin será un 'fieldManager'.
          // Un 'superAdmin' podría cambiar este rol más tarde.
          role: AdminRole.fieldManager,
          displayName: displayName,
          createdAt: Timestamp.now(),
        );

        // Guarda el nuevo admin en la colección 'admins'
        await _adminsCollection.doc(newUser.uid).set(newAdmin.toFirestore());
        print("Nuevo administrador registrado en Auth y Firestore.");
      }

      return newUser;
    } catch (e) {
      print("Error de registro de admin: $e");
      throw Exception('Error al registrar: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    print("Usuario administrador desconectado.");
  }

  /// Envía un correo para restablecer la contraseña al email indicado.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(
        e.message ?? 'Error al enviar correo de restablecimiento',
      );
    }
  }

  /// Opcional: método que actualiza contraseña (requiere usuario autenticado)
  Future<void> updatePassword(String email, String newPassword) async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    if (user.email != email) {
      throw Exception(
        'El correo electrónico no coincide con el usuario autenticado',
      );
    }

    await user.updatePassword(newPassword);
  }
}
