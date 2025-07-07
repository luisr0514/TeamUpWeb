// lib/widget_home_page/manage_games/manage_games_page.dart (ACTUALIZADO CON IMAGEN DE COMPROBANTE)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup_web/models/game_model.dart';
// <-- CAMBIO: Importamos el modelo de notificación para usarlo
import 'package:teamup_web/models/payment_notification_model.dart';
import 'package:teamup_web/models/user_model.dart';
import 'package:teamup_web/services/game_service.dart';

class ManageGamesPage extends StatefulWidget {
  const ManageGamesPage({super.key});

  @override
  State<ManageGamesPage> createState() => _ManageGamesPageState();
}

class _ManageGamesPageState extends State<ManageGamesPage> {
  DateTime? selectedDate;
  final GameService _gameService = GameService();

  late final Stream<List<GameModel>> _gamesStream =
  FirebaseFirestore.instance.collection('games').orderBy('date', descending: false).snapshots().map(
          (snap) => snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GameModel.fromMap(data);
      }).toList());

  final _dateTimeFmt = DateFormat('dd/MM/yyyy HH:mm');
  final _dateOnlyFmt = DateFormat('dd/MM/yyyy');
  final _paymentDateFmt = DateFormat("dd 'de' MMMM 'de' yyyy, hh:mm a", 'es_ES');

  // --- MÉTODOS DE LA UI ---

  // ... (build, _buildFilterBar, _buildGameCard no necesitan cambios) ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control de Partidos'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0CC0DF), Color(0xFFDFFF4F)]),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFilterBar(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<GameModel>>(
                stream: _gamesStream,
                builder: (ctx, snap) {
                  if (snap.hasError) {
                    return Center(child: Text('Error cargando partidos: ${snap.error}'));
                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var games = snap.data ?? [];
                  if (selectedDate != null) {
                    games = games.where((g) => DateUtils.isSameDay(g.date, selectedDate)).toList();
                  }
                  if (games.isEmpty) {
                    return Center(
                      child: Text(
                        selectedDate == null
                            ? 'No hay partidos programados.'
                            : 'No hay partidos para el ${_dateOnlyFmt.format(selectedDate!)}.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: games.length,
                    itemBuilder: (_, i) => _buildGameCard(games[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.date_range),
          label: Text(selectedDate == null ? 'Filtrar por fecha' : _dateOnlyFmt.format(selectedDate!)),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2022),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => selectedDate = picked);
          },
        ),
        if (selectedDate != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Limpiar filtro',
            onPressed: () => setState(() => selectedDate = null),
          ),
        ],
      ],
    );
  }

  Widget _buildGameCard(GameModel game) {
    final uniqueUids = game.usersJoined.toSet().toList();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.sports_soccer, color: Theme.of(context).primaryColor),
        title: Text(game.fieldName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text('Fecha: ${_dateTimeFmt.format(game.date)}  •  ${game.status.toUpperCase()}'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Divider(height: 16),
              Text(
                'Jugadores: ${game.totalPlayers} / ${game.playerCount}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: game.totalPlayers >= game.playerCount ? Colors.red : Colors.green,
                ),
              ),
              const Divider(height: 24),
              const Text('👥 Jugadores Registrados:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (uniqueUids.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Aún no hay jugadores unidos.'),
                )
              else
                ...uniqueUids.map((uid) => _buildPlayerTile(game, uid)),
              if (game.guests.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('🙋‍♂️ Invitados:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...game.guests.entries.map((entry) => Card(
                  color: Colors.grey[100],
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.group_add_outlined),
                    title: Text(entry.key),
                    trailing: Text('+${entry.value} persona(s)'),
                  ),
                ))
              ]
            ]),
          ),
        ],
      ),
    );
  }


  // --- CAMBIOS PRINCIPALES AQUÍ ---

  Widget _buildPlayerTile(GameModel game, String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (ctxU, snapU) {
        if (snapU.connectionState == ConnectionState.waiting) {
          return const ListTile(leading: CircularProgressIndicator(), title: Text('Cargando jugador…'));
        }

        final user = snapU.hasData
            ? UserModel.fromMap(snapU.data!.data() as Map<String, dynamic>, snapU.data!.id)
            : UserModel(uid: uid, fullName: 'Usuario no encontrado', email: 'N/A', username: 'N/A', phone: '', profileImageUrl: '', isVerified: false, blocked: false, reports: 0, totalGamesCreated: 0, totalGamesJoined: 0, position: '', skillLevel: '', notesByAdmin: '', friends: [], friendRequestsSent: [], friendRequestsReceived: [], ratingCount: 0, ratingSum: 0, blockedUsers: []);

        final paymentData = game.paymentInfo[uid];

        if (paymentData == null) {
          return Card(
            // ... (código para jugador sin pago registrado, sin cambios)
          );
        }

        final status = paymentData['status'] as String? ?? 'pending';
        final amount = (paymentData['amount'] as num? ?? 0.0).toDouble();
        final paidAt = (paymentData['paidAt'] as Timestamp?)?.toDate();
        // <-- CAMBIO: Obtenemos el ID de la notificación para buscar la imagen
        final notificationId = paymentData['notificationId'] as String?;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
                backgroundImage: user.profileImageUrl.isNotEmpty ? NetworkImage(user.profileImageUrl) : null,
                child: user.profileImageUrl.isEmpty ? const Icon(Icons.person) : null),
            title: Text(user.fullName),
            // <-- CAMBIO: El subtítulo ahora es una columna para organizar mejor la información
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText('Email: ${user.email}'),
                Text('Monto: \$${amount.toStringAsFixed(2)}'),
                if (paidAt != null) Text('Fecha de pago: ${_paymentDateFmt.format(paidAt)}'),

                // <-- NUEVO: FutureBuilder para buscar y mostrar los detalles del pago (imagen y método)
                if (notificationId != null)
                  FutureBuilder<PaymentNotificationModel?>(
                    future: _fetchPaymentNotification(notificationId),
                    builder: (context, snapP) {
                      if (snapP.connectionState == ConnectionState.waiting) {
                        return const Padding(padding: EdgeInsets.all(8.0), child: Text('Cargando comprobante...'));
                      }
                      if (!snapP.hasData || snapP.data == null) {
                        return const SizedBox.shrink(); // No mostrar nada si no se encuentra
                      }
                      final paymentDetails = snapP.data!;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Text('Método: ${paymentDetails.method}'),
                            const SizedBox(width: 16),
                            if (paymentDetails.receiptUrl != null)
                              InkWell(
                                onTap: () => _showImageDialog(context, paymentDetails.receiptUrl!),
                                child: Tooltip(
                                  message: "Ver comprobante de pago",
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      paymentDetails.receiptUrl!,
                                      width: 50, height: 50, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
            isThreeLine: false, // El tamaño se ajusta por la columna del subtítulo
            trailing: status == 'pending'
                ? Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.check_circle, color: Colors.green, size: 28), tooltip: 'Aprobar Pago', onPressed: () => _approvePayment(game.id, uid)),
              IconButton(icon: const Icon(Icons.cancel, color: Colors.orange, size: 28), tooltip: 'Rechazar Pago', onPressed: () => _rejectPayment(game.id, uid)),
            ])
                : Chip(
              label: Text(status.toUpperCase()),
              backgroundColor: status == 'approved' ? Colors.green.shade100 : Colors.red.shade100,
              labelStyle: TextStyle(color: status == 'approved' ? Colors.green.shade900 : Colors.red.shade900, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // --- MÉTODOS AUXILIARES ---

  // <-- NUEVO: Función para buscar la notificación de pago por su ID
  Future<PaymentNotificationModel?> _fetchPaymentNotification(String notificationId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('payment_notifications').doc(notificationId).get();
      if (doc.exists) {
        return PaymentNotificationModel.fromFirestore(doc);
      }
    } catch (e) {
      print("Error al buscar la notificación de pago $notificationId: $e");
    }
    return null;
  }

  // <-- NUEVO: Función para mostrar la imagen del comprobante en un diálogo
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(imageUrl,
            loadingBuilder: (_, child, prog) => prog == null ? child : const Center(child: CircularProgressIndicator()),
            errorBuilder: (_, __, ___) => const Center(child: Text("No se pudo cargar la imagen")),
          ),
        ),
      ),
    );
  }

  // ... (Las funciones _approvePayment, _rejectPayment y _showConfirmDialog no cambian)
  Future<void> _approvePayment(String gameId, String userId) async {
    final ok = await _showConfirmDialog(
      title: '¿Aprobar pago?',
      content: 'Esto confirmará el pago del usuario y actualizará su estado en el partido.',
      confirmText: 'Aprobar',
      confirmColor: Colors.green,
    );
    if (ok != true || !mounted) return;
    try {
      await _gameService.approvePayment(gameId, userId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Pago aprobado con éxito.'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error al aprobar: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _rejectPayment(String gameId, String userId) async {
    final ok = await _showConfirmDialog(
      title: '¿Rechazar pago?',
      content: 'Esto rechazará el pago y expulsará al jugador del partido.',
      confirmText: 'Rechazar y expulsar',
      confirmColor: Colors.orange,
    );
    if (ok != true || !mounted) return;
    try {
      await _gameService.rejectPayment(gameId, userId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Pago rechazado y jugador expulsado.'), backgroundColor: Colors.orange));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error al rechazar: $e'), backgroundColor: Colors.red));
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}