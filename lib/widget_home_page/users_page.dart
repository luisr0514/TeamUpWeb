import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup_web/models/user_model.dart';


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

  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
    return DateFormat('dd/MM/yyyy, hh:mm a').format(date);
  }

  void _showUserDetailsDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          titlePadding: const EdgeInsets.all(0),
          contentPadding: const EdgeInsets.all(0),
          title: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: user.blocked ? Colors.red.shade700 : Color.fromARGB(255, 60, 90, 29),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? NetworkImage(user.profileImageUrl)
                      : null,
                  child: user.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                ),
                Text(
                  '@${user.username}',
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (user.isVerified)
                      const Chip(
                        avatar: Icon(Icons.verified, color: Colors.white, size: 16),
                        label: Text('Verificado', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      ),
                    if (user.blocked)
                      const Chip(
                        avatar: Icon(Icons.block, color: Colors.white, size: 16),
                        label: Text('Bloqueado', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.black54,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      ),
                  ],
                )
              ],
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4, // Ancho del diálogo
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ListBody(
                children: <Widget>[
                  _buildSectionTitle('Estadísticas del Jugador'),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildStatCard(Icons.star, 'Rating Promedio', user.averageRating.toStringAsFixed(1)),
                      _buildStatCard(Icons.create, 'Partidos Creados', user.totalGamesCreated.toString()),
                      _buildStatCard(Icons.group_add, 'Partidos Unidos', user.totalGamesJoined.toString()),
                      _buildStatCard(Icons.report, 'Reportes Recibidos', user.reports.toString(), isWarning: user.reports > 0),
                    ],
                  ),

                  const Divider(height: 40),

                  _buildSectionTitle('Información de Perfil y Contacto'),
                  _buildDetailRow(Icons.email, 'Email', user.email),
                  _buildDetailRow(Icons.phone, 'Teléfono', user.phone),
                  _buildDetailRow(Icons.sports_soccer, 'Posición', user.position),
                  _buildDetailRow(Icons.bar_chart, 'Nivel', user.skillLevel),

                  const Divider(height: 40),

                  if (user.verification != null) ...[
                    _buildSectionTitle('Datos de Verificación'),
                    _buildDetailRow(Icons.badge, 'Estado', user.verification!.status, valueColor: _getStatusColor(user.verification!.status)),
                    if(user.verification!.rejectionReason != null && user.verification!.rejectionReason!.isNotEmpty)
                      _buildDetailRow(Icons.comment_bank, 'Razón de Rechazo', user.verification!.rejectionReason!),
                  ],

                  _buildSectionTitle('Información de Sistema'),
                  if(user.blocked && user.banReason != null && user.banReason!.isNotEmpty)
                    _buildDetailRow(Icons.gavel, 'Razón de Baneo', user.banReason!, valueColor: Colors.red.shade700),
                  _buildDetailRow(Icons.note_alt, 'Notas de Admin', user.notesByAdmin.isNotEmpty ? user.notesByAdmin : 'Sin notas'),
                  _buildDetailRow(Icons.person_add, 'Amigos', '${user.friends.length}'),
                  _buildDetailRow(Icons.block, 'Usuarios Bloqueados', '${user.blockedUsers.length}'),
                  _buildDetailRow(Icons.login, 'Último Login', _formatDate(user.lastLoginAt)),
                  _buildDetailRow(Icons.date_range, 'Fecha de Creación', _formatDate(user.createdAt)),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar', style: TextStyle(color: Colors.black54)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: (){ /* TODO: Implementar lógica de editar */ },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 60, 90, 29),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Editar Usuario'),
            )
          ],
          actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 16),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: isWarning ? Colors.red.shade600 : Color.fromARGB(255, 60, 90, 29)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isWarning ? Colors.red.shade600 : Colors.black)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'verificado':
        return Colors.green.shade700;
      case 'rejected':
      case 'rechazado':
        return Colors.red.shade700;
      case 'pending':
      case 'pendiente':
        return Colors.orange.shade700;
      default:
        return Colors.black87;
    }
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
                hintText: 'Buscar por nombre o email...',
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
                  return const Center(child: Text('No se encontraron usuarios.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    // ===== CAMBIO 1: Ajustar la relación de aspecto para hacer las tarjetas más cuadradas y compactas =====
                    childAspectRatio: 1.0,
                  ),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userDoc = filteredUsers[index];
                    final user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);

                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setStateCard) {
                        bool _isHovering = false;

                        return MouseRegion(
                          onEnter: (event) => setStateCard(() => _isHovering = true),
                          onExit: (event) => setStateCard(() => _isHovering = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: _isHovering ? Colors.blue.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(_isHovering ? 0.4 : 0.2),
                                  spreadRadius: _isHovering ? 2 : 1,
                                  blurRadius: _isHovering ? 8 : 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0), // Un poco más de padding
                              child: Column(
                                // ===== CAMBIO 2: Distribuir el espacio uniformemente en lugar de centrarlo =====
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 35, // Un poco más pequeño para dar más espacio
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: user.profileImageUrl.isNotEmpty
                                        ? NetworkImage(user.profileImageUrl)
                                        : null,
                                    child: user.profileImageUrl.isEmpty
                                        ? Icon(Icons.person, size: 35, color: Colors.grey[600])
                                        : null,
                                  ),
                                  // Eliminamos los SizedBox para que 'spaceEvenly' haga el trabajo
                                  Column(
                                    children: [
                                      Text(
                                        user.fullName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (user.email.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2.0),
                                          child: Text(
                                            user.email,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),

                                  // ===== CAMBIO 3: Eliminar el Spacer =====
                                  // const Spacer(), // <-- ELIMINADO

                                  TextButton(
                                    onPressed: () {
                                      _showUserDetailsDialog(user);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color.fromARGB(255, 133, 167, 10),
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