import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:teamup_web/firebase_options.dart';
import 'package:teamup_web/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

//hola
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Opcional: quita el banner de debug
      title: 'TeamUp', // Título de tu app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Puedes personalizar tu tema aquí
      ),
      home: LoginView(),
    );
  }
}
