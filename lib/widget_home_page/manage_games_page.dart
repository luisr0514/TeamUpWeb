import 'package:flutter/material.dart';

class ManageGamesPage extends StatelessWidget {
  const ManageGamesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Games'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: const Center(
        child: Text(
          'Manage Games Page Content',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
