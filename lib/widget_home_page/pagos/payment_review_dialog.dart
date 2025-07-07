// lib/widget_home_page/pagos_view/payment_review_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup_web/models/payment_notification_model.dart';

class PaymentReviewDialog extends StatelessWidget {
  final PaymentNotificationModel payment;
  final Function(bool) onAction; // true para aprobar, false para rechazar

  const PaymentReviewDialog({
    Key? key,
    required this.payment,
    required this.onAction,
  }) : super(key: key);

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy, hh:mm a').format(date);

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(context: context, builder: (_) => Dialog(child: Padding(padding: const EdgeInsets.all(8.0), child: Image.network(imageUrl))));
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Revisar Pago Pendiente'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            _buildDetailRow(Icons.person, 'Usuario', payment.userEmail),
            _buildDetailRow(Icons.receipt, 'Referencia', payment.reference),
            _buildDetailRow(Icons.attach_money, 'Monto', '\$${payment.amount.toStringAsFixed(2)}'),
            if (payment.receiptUrl != null && payment.receiptUrl!.isNotEmpty) ...[
              const Divider(height: 20),
              const Text('Comprobante:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _showImageDialog(context, payment.receiptUrl!),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Image.network(payment.receiptUrl!, fit: BoxFit.contain,
                    loadingBuilder: (ctx, child, p) => p == null ? child : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (ctx, err, st) => const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 40)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(child: const Text('Cerrar'), onPressed: () => Navigator.of(context).pop()),
        ElevatedButton.icon(
          icon: const Icon(Icons.close), label: const Text('Rechazar'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.of(context).pop();
            onAction(false); // Llama a la acción con 'false' para rechazar
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check), label: const Text('Aprobar'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            Navigator.of(context).pop();
            onAction(true); // Llama a la acción con 'true' para aprobar
          },
        ),
      ],
    );
  }
}