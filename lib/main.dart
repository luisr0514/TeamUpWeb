import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teamup_web/firebase_options.dart';
import 'package:teamup_web/login_view.dart';
import 'package:teamup_web/Vista_Admin.dart';

// 1. IMPORTACIÓN NECESARIA PARA EL FORMATO DE FECHAS
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  // Asegura que los componentes de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. INICIALIZACIÓN DEL IDIOMA PARA EVITAR EL ERROR 'LocaleDataException'
  // Esto carga los datos necesarios para mostrar fechas en español.
  await initializeDateFormatting('es_ES', null);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeamUp Admin',
      theme: ThemeData(
        primarySwatch: Colors.green, // Un color que puede encajar más con deportes
        appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
        ),
        useMaterial3: true, // Se recomienda usar Material 3
      ),

      // La ruta inicial es manejada por AuthCheck para decidir a dónde ir.
      initialRoute: '/',

      // Mapa de rutas para la navegación.
      routes: {
        '/': (context) => const AuthCheck(),
        '/login': (context) => const LoginView(),
        '/VistaAdmin': (context) => const VistaAdmin(),
      },
    );
  }
}

/// Widget que comprueba el estado de autenticación del usuario
/// y redirige a la pantalla de Login o a la Vista de Administrador.
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Muestra un indicador de carga mientras se verifica la sesión.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si hay datos de usuario (sesión iniciada), muestra la vista de admin.
        if (snapshot.hasData) {
          return const VistaAdmin();
        }

        // Si no hay sesión, muestra la vista de login.
        return const LoginView();
      },
    );
  }
}