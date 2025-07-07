// lib/widget_home_page/pagos_view/user_payment_card.dart (ACTUALIZADO Y MEJORADO)

import 'package:flutter/material.dart';
// <-- CAMBIO: Ruta de importación actualizada
import 'package:teamup_web/models/user_model.dart';

class UserPaymentCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onShowPaymentHistory;

  const UserPaymentCard({
    Key? key,
    required this.user,
    required this.onShowPaymentHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user.profileImageUrl.isNotEmpty ? NetworkImage(user.profileImageUrl) : null,
              child: user.profileImageUrl.isEmpty ? const Icon(Icons.person, size: 30) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  SelectableText(user.email, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  // <-- NUEVO: Se muestra el saldo de la billetera del usuario
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Text(
                        'Saldo: \$${user.walletBalance.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Historial de Pagos'),
              onPressed: onShowPaymentHistory,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}