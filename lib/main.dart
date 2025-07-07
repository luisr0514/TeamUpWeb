// main.dart - ACTUALIZADO

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teamup_web/firebase_options.dart';
import 'package:teamup_web/login_view.dart';
import 'package:teamup_web/Vista_Admin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeamUp',
      theme: ThemeData(primarySwatch: Colors.blue),

      // <-- CAMBIO CLAVE 1: Definir la ruta inicial
      // La ruta '/' será manejada por AuthCheck para decidir si mostrar Login o VistaAdmin.
      initialRoute: '/',

      // <-- CAMBIO CLAVE 2: Definir el mapa de rutas
      // Aquí le decimos a Flutter qué widget corresponde a cada nombre de ruta.
      // Esto soluciona el error "Could not find a generator for route".
      routes: {
        '/': (context) => const AuthCheck(),
        '/login': (context) => const LoginView(),
        '/VistaAdmin': (context) => const VistaAdmin(),
      },
      // Ya no necesitamos 'home' porque 'initialRoute' y 'routes' se encargan de la navegación.
      // home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // Si el usuario ya está autenticado, lo llevamos a la vista de admin.
          return const VistaAdmin();
        } else {
          // Si no, a la vista de login.
          return const LoginView();
        }
      },
    );
  }
}