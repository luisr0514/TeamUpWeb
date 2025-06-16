import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> singIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("inicio correctamente");
      return result.user;
    } catch (e, stacktrace) {
      print('Error de inicio de seccion $e');
      debugPrint('Error de inicio de sesion: $e');
      debugPrint("Stacktrace: $stacktrace");
      return null;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Error de inicio de seccion: $e");
      return null;
    }
  }

  Future<void> singOut() async {
    await _auth.signOut();
  }
  
  
 /// Envía un correo para restablecer la contraseña al email indicado.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Error al enviar correo de restablecimiento');
    }
  }

  /// Opcional: método que actualiza contraseña (requiere usuario autenticado)
  Future<void> updatePassword(String email, String newPassword) async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    if (user.email != email) {
      throw Exception('El correo electrónico no coincide con el usuario autenticado');
    }

    await user.updatePassword(newPassword);
  }
}

