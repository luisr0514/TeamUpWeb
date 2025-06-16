import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to show user details dialog
  void _showUserDetailsDialog(Map<String, dynamic> userData) {
    final name = userData['fullName'] ?? 'Desconocido';
    final email = userData['email'] ?? 'No disponible';
    final phone = userData['phone'] ?? 'No disponible'; 
    final skill = userData['skillLevel'] ?? 'No disponible'; 
    final profileImageUrl = userData['profileImageUrl'] as String?;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (profileImageUrl != null && profileImageUrl.isNotEmpty)
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profileImageUrl),
                    ),
                  )
                else
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                    ),
                  ),
                const SizedBox(height: 20),
                Text('Email: $email', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('Teléfono: $phone', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('Habilidad: $skill', style: const TextStyle(fontSize: 16)),
                // Add more user details here as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24.0, bottom: 16.0, left: 16.0, right: 16.0),
            child: Text(
              'Usuarios',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 46, 69, 23),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuarios...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar usuarios: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay usuarios disponibles.'));
                }

                final filteredUsers = snapshot.data!.docs.where((doc) {
                  final userData = doc.data() as Map<String, dynamic>;
                  final name = (userData['fullName'] as String?)?.toLowerCase() ?? '';
                  final email = (userData['email'] as String?)?.toLowerCase() ?? '';
                  final query = _searchQuery.toLowerCase();

                  return name.contains(query) || email.contains(query);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('No se encontraron usuarios que coincidan con la búsqueda.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8, // Adjusted to be slightly taller than square
                  ),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final userData = user.data() as Map<String, dynamic>;
                    final name = userData['fullName'] ?? 'Desconocido';
                    final email = userData['email'] ?? '';
                    final profileImageUrl = userData['profileImageUrl'] as String?;

                    // Use a StatefulBuilder to manage hover state for each card
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setStateCard) {
                        bool _isHovering = false; // Initial hover state for this specific card

                        return MouseRegion(
                          onEnter: (event) => setStateCard(() => _isHovering = true),
                          onExit: (event) => setStateCard(() => _isHovering = false),
                          child: AnimatedContainer( // Use AnimatedContainer for smooth color transition
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: _isHovering ? Colors.blue.shade50 : Colors.white, // Change color on hover
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(_isHovering ? 0.4 : 0.2), // Stronger shadow on hover
                                  spreadRadius: _isHovering ? 2 : 1,
                                  blurRadius: _isHovering ? 8 : 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                        ? NetworkImage(profileImageUrl) as ImageProvider<Object>?
                                        : null,
                                    child: profileImageUrl == null || profileImageUrl.isEmpty
                                        ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (email.isNotEmpty)
                                    Column(
                                      children: [
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.email, size: 16, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                email,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  // New "Ver Información" button
                                  const Spacer(), // Pushes the button to the bottom
                                  TextButton(
                                    onPressed: () {
                                      _showUserDetailsDialog(userData);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white, // Text color
                                      backgroundColor: Color.fromARGB(255, 133, 167, 10), // Button background color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    child: const Text(
                                      'Ver Información',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
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