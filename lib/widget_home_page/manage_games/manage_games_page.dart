// lib/widget_home_page/manage_games/manage_games/manage_games_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup_web/models/game_model.dart';
import 'package:teamup_web/models/payment_notification_model.dart';
import 'package:teamup_web/services/game_service.dart';

class ManageGamesPage extends StatefulWidget {
  const ManageGamesPage({Key? key}) : super(key: key);

  @override
  State<ManageGamesPage> createState() => _ManageGamesPageState();
}

class _ManageGamesPageState extends State<ManageGamesPage> {
  DateTime? selectedDate;
  final GameService _gameService = GameService();

  /// Stream de partidos, ordenados cronológicamente
  late final Stream<List<GameModel>> _gamesStream = FirebaseFirestore.instance
      .collection('games')  // Ajusta si tu colección se llama distinto
      .orderBy('date', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
    final map = doc.data();
    map['id'] = doc.id;  // Inyecta el ID en el modelo
    return GameModel.fromMap(map);
  }).toList());

  final _dateTimeFmt   = DateFormat('dd/MM/yyyy HH:mm');
  final _dateOnlyFmt   = DateFormat('dd/MM/yyyy');
  final _paymentDateFmt = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control de Partidos'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
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
                  var games = snap.data!;
                  if (selectedDate != null) {
                    games = games.where((g) {
                      return g.date.year  == selectedDate!.year &&
                          g.date.month == selectedDate!.month &&
                          g.date.day   == selectedDate!.day;
                    }).toList();
                  }
                  if (games.isEmpty) {
                    return Center(
                      child: Text(
                        selectedDate == null
                            ? 'No hay partidos registrados.'
                            : 'No hay partidos el ${_dateOnlyFmt.format(selectedDate!)}.',
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
          label: Text(
            selectedDate == null
                ? 'Filtrar por fecha'
                : _dateOnlyFmt.format(selectedDate!),
          ),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
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
        title: Text(
          game.fieldName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Fecha: ${_dateTimeFmt.format(game.date)}  •  Precio: \$${game.price.toStringAsFixed(2)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Descripción: ${game.description}'),
              const SizedBox(height: 6),
              Text('Ciudad: ${game.city}'),
              const SizedBox(height: 6),
              Text('Hora: ${game.hour}'),
              const SizedBox(height: 6),
              Text('Formato: ${game.format} — Nivel: ${game.skillLevel}'),
              const SizedBox(height: 6),
              Text('Duración: ${game.duration} h — Público: ${game.isPublic ? 'Sí' : 'No'}'),
              const Divider(height: 24),

              if (game.imageUrls.isNotEmpty) ...[
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: game.imageUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, j) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        game.imageUrls[j],
                        width: 140,
                        height: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, prog) =>
                        prog == null ? child : const Center(child: CircularProgressIndicator()),
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 40, color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 24),
              ],

              Text(
                'Jugadores: ${game.totalPlayers} / ${game.playerCount}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: game.totalPlayers >= game.playerCount ? Colors.red : Colors.green,
                ),
              ),
              const Divider(height: 24),

              const Text('👥 Jugadores y Pagos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              if (uniqueUids.isEmpty)
                const Text('Aún no hay jugadores unidos.')
              else
                ...uniqueUids.map((uid) => _buildPlayerTile(game, uid)),
            ]),
          ),
        ],
      ),
    );
  }

  /// Trae el último pago para este userId + gameId
  Future<PaymentNotificationModel?> _fetchLatestPayment(String gameId, String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('payment_notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    for (var doc in snap.docs) {
      final p = PaymentNotificationModel.fromFirestore(doc);
      if (p.gameId == gameId) return p;
    }
    return null;
  }

  Widget _buildPlayerTile(GameModel game, String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (ctxU, snapU) {
        if (snapU.connectionState == ConnectionState.waiting) {
          return const ListTile(title: Text('Cargando jugador…'));
        }
        final userData = snapU.data?.data() as Map<String, dynamic>? ?? {};
        final fullName = userData['fullName'] ?? 'Sin nombre';
        final email    = userData['email']    ?? '';

        return FutureBuilder<PaymentNotificationModel?>(
          future: _fetchLatestPayment(game.id, uid),
          builder: (ctxP, snapP) {
            if (snapP.connectionState == ConnectionState.waiting) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(fullName),
                subtitle: const Text('Cargando pago…'),
              );
            }
            final payment = snapP.data;
            if (payment == null) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(fullName),
                subtitle: const Text('No se encontró pago'),
              );
            }
            // Pago encontrado: mostramos detalles y la imagen del comprobante
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(fullName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: $email'),
                    Text('Monto: \$${payment.amount.toStringAsFixed(2)}'),
                    Text('Ref: ${payment.reference}'),
                    Text('Método: ${payment.method.replaceAll('_', ' ').toUpperCase()}'),
                    Text('Fecha: ${_paymentDateFmt.format(payment.createdAt)}'),
                    if (payment.receiptUrl != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          // opción: mostrar en diálogo de pantalla completa
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            payment.receiptUrl!,
                            width: 120,
                            height: 80,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, prog) =>
                            prog == null ? child : const Center(child: CircularProgressIndicator()),
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 40, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                isThreeLine: true,
                trailing: payment.status == 'pending'
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Aprobar Pago',
                    onPressed: () => _approvePayment(game.id, uid),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.orange),
                    tooltip: 'Rechazar Pago',
                    onPressed: () => _rejectPayment(game.id, uid),
                  ),
                ])
                    : Chip(
                  label: Text(payment.status.toUpperCase()),
                  backgroundColor: payment.status == 'approved'
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _approvePayment(String gameId, String userId) async {
    final ok = await _showConfirmDialog(
      title: '¿Aprobar pago?',
      content: 'Confirmar que el usuario ha pagado y puede unirse al partido.',
      confirmText: 'Aprobar',
      confirmColor: Colors.green,
    );
    if (ok != true) return;
    try {
      await _gameService.approvePayment(gameId, userId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Pago aprobado'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al aprobar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectPayment(String gameId, String userId) async {
    final ok = await _showConfirmDialog(
      title: '¿Rechazar pago?',
      content: 'Rechazar el pago y expulsar al jugador del partido.',
      confirmText: 'Rechazar y expulsar',
      confirmColor: Colors.orange,
    );
    if (ok != true) return;
    try {
      await _gameService.rejectPayment(gameId, userId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Pago rechazado y expulsado'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al rechazar: $e'), backgroundColor: Colors.red),
      );
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
