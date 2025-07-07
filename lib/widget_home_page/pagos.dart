// lib/widget_home_page/pagos.dart (ACTUALIZADO)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// <-- CAMBIO: Ruta de importación actualizada
import 'package:teamup_web/models/user_model.dart';
import 'package:teamup_web/models/payment_notification_model.dart';
import 'package:teamup_web/services/game_service.dart';
import 'package:teamup_web/services/notification_service.dart';

import 'pagos/payment_history_dialog.dart';
import 'pagos/user_payment_card.dart';

class Pagos extends StatefulWidget {
  const Pagos({Key? key}) : super(key: key);

  @override
  State<Pagos> createState() => _PagosState();
}

class _PagosState extends State<Pagos> {
  final TextEditingController _searchController = TextEditingController();
  final GameService _gameService = GameService();
  final NotificationService _notificationService = NotificationService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handlePaymentAction(
      BuildContext context, PaymentNotificationModel payment, bool approve) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final newStatus = approve ? 'approved' : 'rejected';
      await FirebaseFirestore.instance
          .collection('payment_notifications')
          .doc(payment.notificationId)
          .update({'status': newStatus});

      final game = await _gameService.getGame(payment.gameId);
      if (game == null) throw Exception("Partido no encontrado.");

      if (approve) {
        await _gameService.approvePayment(payment.gameId, payment.userId);
        await _notificationService.sendPaymentConfirmedNotification(
            toUserId: payment.userId, gameId: game.id, gameDescription: game.description);
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('Pago aprobado con éxito.'), backgroundColor: Colors.green));
      } else {
        await _gameService.removePlayerFromGame(payment.gameId, payment.userId);
        await _notificationService.sendPaymentRejectedNotification(
            toUserId: payment.userId,
            gameId: game.id,
            gameDescription: game.description,
            reason: "El comprobante no pudo ser verificado.");
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('Pago rechazado y jugador eliminado del partido.'),
            backgroundColor: Colors.orange));
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _showPaymentHistory(UserModel user) {
    showDialog(
      context: context,
      builder: (dialogContext) => PaymentHistoryDialog(
        user: user,
        onPaymentAction: _handlePaymentAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Gestión de Usuarios y Pagos'),
        elevation: 1,
        backgroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0CC0DF), Color(0xFFDFFF4F)]),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuario por nombre, email...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').orderBy('fullName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No hay usuarios registrados.'));

          final filteredDocs = snapshot.data!.docs.where((doc) {
            final user = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            final query = _searchQuery.toLowerCase();
            return user.fullName.toLowerCase().contains(query) || user.email.toLowerCase().contains(query);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final user = UserModel.fromMap(filteredDocs[index].data() as Map<String, dynamic>, filteredDocs[index].id);
              return UserPaymentCard(
                user: user,
                onShowPaymentHistory: () => _showPaymentHistory(user),
              );
            },
          );
        },
      ),
    );
  }
}