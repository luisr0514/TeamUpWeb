import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widget_home_page/sidebar.dart';
import 'widget_home_page/header.dart';
import 'widget_home_page/manage_games/manage_games_page.dart';
import 'widget_home_page/manage_fields/manage_fields_page.dart';
import 'widget_home_page/users_page.dart';
import 'widget_home_page/settings_page.dart';
import 'widget_home_page/table.dart';
import 'widget_home_page/dashboard.dart';
import 'widget_home_page/pagos.dart';

class VistaAdmin extends StatefulWidget {
  const VistaAdmin({Key? key}) : super(key: key);

  @override
  _VistaAdminState createState() => _VistaAdminState();
}

class _VistaAdminState extends State<VistaAdmin> {
  bool _isSidebarExpanded = true;
  String userEmail = "Cargando...";
  bool isLoading = true;
  Widget _currentPage = Container(); // Inicializamos con un contenedor vacío

  @override
  void initState() {
    super.initState();
    _getUserEmail(); // Corregido: sin espacio en el nombre
  }

  Future<void> _getUserEmail() async { // Corregido: nombre sin espacio
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        setState(() {
          userEmail = user.email!;
          _currentPage = _buildHomePage(userEmail); // Usamos el email obtenido
          isLoading = false;
        });
      } else {
        setState(() {
          userEmail = "No identificado";
          _currentPage = _buildHomePage(userEmail);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userEmail = "Error al cargar";
        _currentPage = _buildHomePage(userEmail);
        isLoading = false;
      });
    }
  }

  void _onToggleSidebar() => setState(() => _isSidebarExpanded = !_isSidebarExpanded);

  Widget _buildHomePage(String email) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.jpg',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Bienvenido, Admin!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            email,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            isExpanded: _isSidebarExpanded,
            onToggle: _onToggleSidebar,
            onItemSelected: (page) {
              setState(() {
                _currentPage = page;
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                Header(adminEmail: userEmail),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _currentPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<Widget> onItemSelected;

  const Sidebar({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = {
      'Dashboard': Dashboard(),
      'Juegos': ManageGamesPage(),
      'Canchas': ManageFieldsPage(),
      'Usuarios': UsersPage(),
      'Pagos': Pagos(),
      'Ajustes': SettingsPage(),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 240 : 60,
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFFDFFF4F),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(isExpanded ? Icons.arrow_back : Icons.arrow_forward,
                color: const Color(0xFF10B981)),
            onPressed: onToggle,
          ),
          if (isExpanded) ...[
            const Padding(
              padding: EdgeInsets.only(left: 24, bottom: 16),
              child: Text('Admin Dashboard',
                  style: TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.w400)),
            ),
            for (var entry in menuItems.entries)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onItemSelected(entry.value),
                  child: Container(
                    width: isExpanded ? 208 : 48,
                    height: 48,
                    margin: const EdgeInsets.only(left: 16, top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        if (isExpanded)
                          Text(entry.key,
                              style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? "No identificado";
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.jpg',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Bienvenido, Admin!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            email,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}