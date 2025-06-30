import 'package:flutter/material.dart';
import 'widget_home_page/sidebar.dart';
import 'widget_home_page/header.dart';
import 'widget_home_page/manage_games/manage_games_page.dart';
import 'widget_home_page/manage_fields/manage_fields_page.dart';
import 'widget_home_page/users_page.dart';
import 'widget_home_page/settings_page.dart';
import 'widget_home_page/table.dart';

class VistaAdmin extends StatefulWidget {
  const VistaAdmin({Key? key}) : super(key: key);

  @override
  _VistaAdminState createState() => _VistaAdminState();
}

class _VistaAdminState extends State<VistaAdmin> {
  bool _isSidebarExpanded = true;
  Widget _currentPage = const Center(
    child: Text('Contenido del Dashboard (¡Bienvenido!)',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
  );

  void _onToggleSidebar() => setState(() => _isSidebarExpanded = !_isSidebarExpanded);

  // Cambia la página actual que se muestra
  void _onMenuItemSelected(Widget page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            isExpanded: _isSidebarExpanded,
            onToggle: _onToggleSidebar,
            onItemSelected: _onMenuItemSelected,
          ),
          Expanded(
            child: Column(
              children: [
                Header(),
                Expanded(child: _currentPage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sidebar actualizado para aceptar ValueChanged<Widget> y manejar páginas sin índices
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
      'Dashboard': const Center(
          child: Text('Contenido del Dashboard (¡Bienvenido!)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      'Juegos': ManageGamesPage(),
      'Canchas': ManageFieldsPage(),
      'Usuarios': UsersPage(),
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
                  style:
                      TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.w400)),
            ),
            for (var title in menuItems.keys)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onTap: () => onItemSelected(menuItems[title]!),
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
                            Text(title,
                                style: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )),
              ),
          ],
        ],
      ),
    );
  }
}


