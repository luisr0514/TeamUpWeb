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
}
