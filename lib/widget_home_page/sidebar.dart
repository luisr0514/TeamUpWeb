import 'package:flutter/material.dart';

import 'manage_games_page.dart'; // Asegúrate de importar tus páginas
import 'manage_fields_page.dart';
import 'users_page.dart';
import 'settings_page.dart';

class Sidebar extends StatelessWidget {
  final bool isExpanded; // Propiedad para saber si el sidebar está expandido
  final VoidCallback onToggle; // Callback para alternar el estado

  const Sidebar({Key? key, required this.isExpanded, required this.onToggle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Duración de la animación
      width: isExpanded ? 240 : 60, // Ancho del menú
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFFDFFF4F),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón para alternar el menú
          IconButton(
            icon: Icon(
              isExpanded ? Icons.arrow_back : Icons.arrow_forward, // Icono de flecha
              color: const Color(0xFF10B981),
            ),
            onPressed: onToggle, // Llama al callback para alternar
          ),
          if (isExpanded) ...[
            Container(
              height: 101,
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.only(left: 24, bottom: 16),
              child: const Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            _buildMenuItem(context, 'Dashboard', false, () {
              // Navegar a la página del Dashboard
            }),
            _buildMenuItem(context, 'Juegos', true, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageGamesPage()),
              );
            }),
            _buildMenuItem(context, 'Canchas', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageFieldsPage()),
              );
            }),
            _buildMenuItem(context, 'Usuarios', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsersPage()),
              );
            }),
            _buildMenuItem(context, 'Ajustes', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 208,
          height: 48,
          margin: const EdgeInsets.only(left: 16, top: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF10B981) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(width: 20, height: 20, color: Colors.transparent),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}