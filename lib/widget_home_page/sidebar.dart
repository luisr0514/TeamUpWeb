// sidebar.dart
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFFDFFF4F),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _buildMenuItem('Dashboard', false),
          _buildMenuItem('Manage Games', true),
          _buildMenuItem('Manage Fields', false),
          _buildMenuItem('Users', false),
          _buildMenuItem('Settings', false),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, bool isActive) {
    return Container(
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
    );
  }
}
