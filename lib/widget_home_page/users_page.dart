import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar usuarios'));
          }

          final users = snapshot.data?.docs;

          return ListView.builder(
            itemCount: users?.length ?? 0,
            itemBuilder: (context, index) {
              final user = users![index];
              final email = user['email'];

              return ListTile(
                title: Text(email),
              );
            },
          );
        },
      ),
    );
  }
}