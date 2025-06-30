// lib/features/admin/manage_games_page.dart (o donde la tengas)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup_web/models/game_model.dart'; // Asegúrate que la ruta sea correcta
import 'package:teamup_web/services/game_service.dart'; // Asegúrate que la ruta sea correcta

class ManageGamesPage extends StatefulWidget {
  const ManageGamesPage({super.key});

  @override
  State<ManageGamesPage> createState() => _ManageGamesPageState();
}

class _ManageGamesPageState extends State<ManageGamesPage> {
  DateTime? selectedDate;
  final GameService _gameService = GameService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat _paymentDateFormat = DateFormat('dd MMM yyyy, HH:mm');

  // --- LÓGICA DE ACCIONES ---
  Future<void> _approvePayment(String gameId, String userId) async {
    final confirmed = await _showConfirmationDialog(context, title: 'Aprobar Pago', content: '¿Estás seguro de que quieres confirmar el pago para este usuario?', confirmText: 'Aprobar');
    if (confirmed != true) return;
    try {
      await _gameService.approvePayment(gameId, userId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Pago aprobado con éxito.'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error al aprobar: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _rejectPayment(GameModel game, String userId) async {
    final confirmed = await _showConfirmationDialog(context, title: 'Rechazar Pago y Expulsar', content: 'Esta acción rechazará el pago y eliminará al jugador del partido. ¿Continuar?', confirmText: 'Sí, Rechazar y Expulsar');
    if (confirmed != true) return;
    try {
      await _gameService.rejectPayment(game.id, userId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Pago rechazado y jugador expulsado.'), backgroundColor: Colors.orange));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error al rechazar: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _kickPlayer(GameModel game, String userId) async {
    final confirmed = await _showConfirmationDialog(context, title: 'Expulsar Jugador', content: '¿Estás seguro de que quieres expulsar a este jugador del partido?', confirmText: 'Sí, Expulsar', confirmColor: Colors.red);
    if (confirmed != true) return;
    try {
      await _gameService.removePlayerFromGame(game.id, userId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Jugador expulsado con éxito.'), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error al expulsar: $e'), backgroundColor: Colors.red));
    }
  }

  // --- WIDGETS Y LÓGICA DE UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Panel de Control de Partidos',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 46, 69, 23)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilterBar(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<GameModel>>(
                stream: _gameService.getGamesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No hay juegos registrados.'));

                  final games = snapshot.data!;
                  final filteredGames = _filterGamesByDate(games);

                  if (filteredGames.isEmpty) return const Center(child: Text('No se encontraron juegos con esos filtros.'));

                  return ListView.builder(
                    itemCount: filteredGames.length,
                    itemBuilder: (context, index) {
                      final game = filteredGames[index];
                      return _buildGameExpansionTile(game);
                    },
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
          label: Text(selectedDate == null ? 'Filtrar por fecha' : DateFormat('dd/MM/yyyy').format(selectedDate!)),
          onPressed: _selectDate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 125, 176, 64),
            foregroundColor: Colors.white,
          ),
        ),
        if (selectedDate != null)
          IconButton(
            tooltip: 'Limpiar filtro',
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => selectedDate = null),
          ),
      ],
    );
  }

  Widget _buildGameExpansionTile(GameModel game) {
    final playersCount = game.totalPlayers;
    final capacity = game.playerCount;
    final status = game.status.toUpperCase();
    final isFull = playersCount >= capacity;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ExpansionTile(
        title: Text(game.fieldName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('Fecha: ${_dateFormat.format(game.date)} - Estado: $status'),
        trailing: Chip(
          label: Text('$playersCount / $capacity Jugadores'),
          backgroundColor: isFull ? Colors.red.shade100 : Colors.green.shade100,
          labelStyle: TextStyle(color: isFull ? Colors.red.shade800 : Colors.green.shade800, fontWeight: FontWeight.bold),
        ),
        children: [_buildPlayerList(game)],
      ),
    );
  }

  Widget _buildPlayerList(GameModel game) {
    if (game.usersJoined.isEmpty) {
      return const Padding(padding: EdgeInsets.all(16.0), child: Text('Aún no hay jugadores unidos.'));
    }
    final sortedUserIds = List<String>.from(game.usersJoined)
      ..sort((a, b) {
        final statusA = game.paymentStatus[a];
        if (statusA == 'pending') return -1;
        return 1;
      });

    return Column(
      children: sortedUserIds.map((userId) => _buildPlayerTile(game, userId)).toList(),
    );
  }

  Widget _buildPlayerTile(GameModel game, String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const ListTile(title: Text("Cargando jugador..."));

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        final userEmail = userData?['email'] ?? 'Email no disponible';
        final paymentStatus = game.paymentStatus[userId];

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlayerHeader(userEmail, paymentStatus, game, userId),
                if (paymentStatus == 'pending') ...[
                  const Divider(height: 24),
                  _buildPaymentDetails(game.id, userId),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerHeader(String userEmail, String? paymentStatus, GameModel game, String userId) {
    return Row(
      children: [
        CircleAvatar(child: Icon(Icons.person)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userEmail, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 4),
              _buildStatusChip(paymentStatus, game.price),
            ],
          ),
        ),
        _buildActionButtons(game, userId, paymentStatus),
      ],
    );
  }

  Widget _buildPaymentDetails(String gameId, String userId) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('payment_notifications')
          .where('gameId', isEqualTo: gameId)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Detalles del pago no encontrados.", style: TextStyle(color: Colors.red))));

        final paymentDoc = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final receiptUrl = paymentDoc['receiptUrl'] as String?;

        return LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 700;
            return isWide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: _buildPaymentInfoTable(paymentDoc)),
              if (receiptUrl != null) Expanded(flex: 3, child: _buildReceiptImage(receiptUrl)),
            ])
                : Column(children: [
              _buildPaymentInfoTable(paymentDoc),
              if (receiptUrl != null) ...[const SizedBox(height: 16), _buildReceiptImage(receiptUrl)],
            ]);
          },
        );
      },
    );
  }

  Widget _buildPaymentInfoTable(Map<String, dynamic> paymentDoc) {
    final method = paymentDoc['method']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'N/A';
    final reference = paymentDoc['reference'] ?? 'N/A';
    final amount = (paymentDoc['amount'] as num?)?.toDouble() ?? 0.0;
    final date = (paymentDoc['createdAt'] as Timestamp?)?.toDate();
    final guests = paymentDoc['guestsCount'] ?? 0;

    return DataTable(
      columnSpacing: 16,
      headingRowHeight: 0,
      dataRowMinHeight: 38,
      dataRowMaxHeight: 42,
      columns: const [DataColumn(label: Text('')), DataColumn(label: Text(''))],
      rows: [
        DataRow(cells: [const DataCell(Text('Método')), DataCell(Text(method, style: const TextStyle(fontWeight: FontWeight.bold)))]),
        DataRow(cells: [const DataCell(Text('Referencia')), DataCell(Text(reference, style: const TextStyle(fontWeight: FontWeight.bold)))]),
        DataRow(cells: [const DataCell(Text('Monto')), DataCell(Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)))]),
        DataRow(cells: [const DataCell(Text('Invitados')), DataCell(Text('+$guests', style: const TextStyle(fontWeight: FontWeight.bold)))]),
        if (date != null) DataRow(cells: [const DataCell(Text('Fecha Notif.')), DataCell(Text(_paymentDateFormat.format(date), style: const TextStyle(fontWeight: FontWeight.bold)))]),
      ],
    );
  }

  Widget _buildReceiptImage(String url) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Comprobante Adjunto:", style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showImageDialog(context, url),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 40)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 4,
              child: Image.network(url),
            ),
            IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status, double price) {
    if (price == 0) return Chip(label: const Text('Gratis'), backgroundColor: Colors.blue.shade100, visualDensity: VisualDensity.compact);
    switch (status) {
      case 'paid': return Chip(label: const Text('Pagado'), backgroundColor: Colors.green.shade200, visualDensity: VisualDensity.compact);
      case 'pending': return Chip(label: const Text('Pendiente'), backgroundColor: Colors.orange.shade200, visualDensity: VisualDensity.compact);
      default: return Chip(label: const Text('Sin Pago'), backgroundColor: Colors.red.shade100, visualDensity: VisualDensity.compact);
    }
  }

  Widget _buildActionButtons(GameModel game, String userId, String? paymentStatus) {
    if (paymentStatus == 'pending') {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _approvePayment(game.id, userId), tooltip: 'Aprobar Pago'),
        IconButton(icon: const Icon(Icons.cancel, color: Colors.orange), onPressed: () => _rejectPayment(game, userId), tooltip: 'Rechazar Pago'),
      ]);
    }
    return IconButton(icon: const Icon(Icons.person_remove, color: Colors.red), onPressed: () => _kickPlayer(game, userId), tooltip: 'Expulsar Jugador');
  }

  List<GameModel> _filterGamesByDate(List<GameModel> games) {
    if (selectedDate == null) return games;
    return games.where((game) {
      return game.date.year == selectedDate!.year && game.date.month == selectedDate!.month && game.date.day == selectedDate!.day;
    }).toList();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(context: context, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate) setState(() => selectedDate = picked);
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, {required String title, required String content, required String confirmText, Color? confirmColor}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), style: FilledButton.styleFrom(backgroundColor: confirmColor ?? Theme.of(context).primaryColor), child: Text(confirmText)),
        ],
      ),
    );
  }
}