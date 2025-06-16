import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teamup_web/firebase_options.dart';
import 'package:teamup_web/login_view.dart';
import 'package:teamup_web/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeamUp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', //
      routes: {
        '/': (context) => AuthCheck(),
        '/VistaAdmin': (context) => VistaAdmin(),
        '/login': (context) => LoginView(),
      },

    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return VistaAdmin();
        } else {
          return LoginView();
        }
      },
    );
  }
}
