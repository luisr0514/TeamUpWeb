// lib/widget_home_page/pagos_view/payment_history_dialog.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup_web/models/payment_notification_model.dart';
import 'package:teamup_web/models/user_model.dart';
import 'payment_review_dialog.dart';

class PaymentHistoryDialog extends StatelessWidget {
  final UserModel user;
  final Function(BuildContext, PaymentNotificationModel, bool) onPaymentAction;

  const PaymentHistoryDialog({
    Key? key,
    required this.user,
    required this.onPaymentAction,
  }) : super(key: key);

  String _formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy, hh:mm a').format(date);

  void _showReviewDialog(BuildContext context, PaymentNotificationModel payment) {
    showDialog(
      context: context,
      builder: (reviewContext) => PaymentReviewDialog(
        payment: payment,
        onAction: (bool approve) => onPaymentAction(context, payment, approve),
      ),
    );
  }

  Widget _buildPaymentHistoryTile(
      BuildContext context, PaymentNotificationModel payment) {
    final statusMap = {
      'approved': {
        'icon': Icons.check_circle,
        'color': Colors.green,
        'text': 'Aprobado'
      },
      'rejected': {
        'icon': Icons.cancel,
        'color': Colors.red,
        'text': 'Rechazado'
      },
      'pending': {
        'icon': Icons.hourglass_top,
        'color': Colors.orange,
        'text': 'Pendiente'
      }
    };
    final status = statusMap[payment.status] ?? statusMap['pending']!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(status['icon'] as IconData,
            color: status['color'] as Color, size: 28),
        title: Text(
            'Monto: \$${payment.amount.toStringAsFixed(2)} – Ref: ${payment.reference}'),
        subtitle: Text(
            'Fecha: ${_formatDate(payment.createdAt)}\nEstado: ${status['text']}'),
        isThreeLine: true,
        trailing: payment.status == 'pending'
            ? Tooltip(
          message: 'Revisar este pago',
          child: ElevatedButton(
            onPressed: () => _showReviewDialog(context, payment),
            child: const Icon(Icons.rate_review),
          ),
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Historial de Pagos de ${user.username}'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
          // ► Ajusta aquí el nombre de tu colección si es distinto:
              .collection('payment_notifications')
              .where('userId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text('No hay pagos registrados.'));
            }
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final payment =
                PaymentNotificationModel.fromFirestore(docs[index]);
                return _buildPaymentHistoryTile(context, payment);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
