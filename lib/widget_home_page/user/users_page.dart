import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/user_card.dart';
import 'package:teamup_web/models/user_model.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, toolbarHeight: 0),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Usuarios',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: const Color.fromARGB(255, 46, 69, 23)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                final filtered = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['fullName'] as String).toLowerCase();
                  final email = (data['email'] as String).toLowerCase();
                  return name.contains(_searchQuery.toLowerCase()) || email.contains(_searchQuery.toLowerCase());
                }).toList();
                if (filtered.isEmpty) return const Center(child: Text('No se encontraron usuarios.'));
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final user = UserModel.fromMap(doc.data()! as Map<String, dynamic>, doc.id);
                    return UserCard(user: user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
