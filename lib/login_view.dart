import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup_web/aut/auth_service.dart';

import 'reset_password_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;
  bool rememberMe = false;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    bool? remember = prefs.getBool('rememberMe');

    if (remember == true) {
      emailController.text = email ?? '';
      passwordController.text = password ?? '';
      rememberMe = true;
    }
  }

  Future<void> handleAuth() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      AuthService authService = AuthService();

      if (isLogin) {
        await authService.singIn(email, password);
        if (rememberMe) {
          _saveCredentials(email, password);
        } else {
          _clearCredentials();
        }
        Navigator.pushReplacementNamed(context, '/VistaAdmin');
      } else {
        await authService.register(email, password);
        await authService.singIn(email, password);
        if (rememberMe) {
          _saveCredentials(email, password);
        } else {
          _clearCredentials();
        }
        Navigator.pushReplacementNamed(context, '/VistaAdmin');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setBool('rememberMe', true);
  }

  Future<void> _clearCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.setBool('rememberMe', false);
  }

  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      emailController.clear();
      passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1272),
          height: 599,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: const Color(0xFF0CC0DF),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/logo.jpg", width: 361),
                      const SizedBox(height: 20),
                      Text(
                        'TeamUp',
                        style: TextStyle(
                          fontSize: 48,
                          fontFamily: 'Sansation',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Let´s play',
                        style: TextStyle(fontSize: 32, fontFamily: 'Sansation'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLogin ? 'Admin Login' : 'Registro',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isLogin
                            ? 'Enter your credentials to access'
                            : 'Create a new admin account',
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (value) {
                          handleAuth();
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          handleAuth();
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (v) {
                              setState(() => rememberMe = v ?? false);
                            },
                          ),
                          const Text('Remember me'),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ResetPasswordView()),
                              );
                            },
                            child: const Text('Forgot password?'),
                              ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0CC0DF),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: isLoading ? null : handleAuth,
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : Text(isLogin ? 'Sign In' : 'Register'),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLogin
                                ? 'Not an admin?'
                                : 'Already have an account?',
                          ),
                          TextButton(
                            onPressed: toggleAuthMode,
                            child: Text(
                              isLogin
                                  ? 'Return to user login'
                                  : 'Login instead',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}