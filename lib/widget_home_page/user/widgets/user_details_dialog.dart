// lib/features/auth/widgets/user_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup_web/models/user_model.dart';
import 'stat_card.dart';
import 'section_title.dart';
import 'detail_row.dart';
import 'package:intl/intl.dart';

class UserDetailsDialog extends StatelessWidget {
  final UserModel user;
  const UserDetailsDialog({Key? key, required this.user}) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
    return DateFormat('dd/MM/yyyy, hh:mm a').format(date);
  }

  Color _statusColor(String status) {
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
    final hasNoVerification = user.verification == null ||
        (user.verification!.idCardFrontUrl.isEmpty &&
            user.verification!.idCardBackUrl.isEmpty &&
            user.verification!.faceWithIdUrl.isEmpty);

    return AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: user.blocked
              ? Colors.red.shade700
              : const Color.fromARGB(255, 60, 90, 29),
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20)),
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
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white),
            ),
            Text(
              '@${user.username}',
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (user.isVerified)
                  const Chip(
                    avatar: Icon(Icons.verified,
                        color: Colors.white, size: 16),
                    label:
                    Text('Verificado', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue,
                    padding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                if (user.blocked)
                  const Chip(
                    avatar: Icon(Icons.block,
                        color: Colors.white, size: 16),
                    label:
                    Text('Bloqueado', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.black54,
                    padding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
              ],
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // — Estadísticas —
            SectionTitle('Estadísticas del Jugador'),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                StatCard(
                  icon: Icons.star,
                  label: 'Rating Promedio',
                  value: user.averageRating.toStringAsFixed(1),
                ),
                StatCard(
                  icon: Icons.create,
                  label: 'Partidos Creados',
                  value: user.totalGamesCreated.toString(),
                ),
                StatCard(
                  icon: Icons.group_add,
                  label: 'Partidos Unidos',
                  value: user.totalGamesJoined.toString(),
                ),
                StatCard(
                  icon: Icons.report,
                  label: 'Reportes Recibidos',
                  value: user.reports.toString(),
                  isWarning: user.reports > 0,
                ),
              ],
            ),

            const Divider(height: 40),

            // — Perfil y Contacto —
            SectionTitle('Información de Perfil y Contacto'),
            DetailRow(icon: Icons.email, label: 'Email', value: user.email),
            DetailRow(icon: Icons.phone, label: 'Teléfono', value: user.phone),
            DetailRow(
                icon: Icons.sports_soccer,
                label: 'Posición',
                value: user.position),
            DetailRow(
                icon: Icons.bar_chart,
                label: 'Nivel',
                value: user.skillLevel),

            const Divider(height: 40),

            // — Verificación —
            if (hasNoVerification) ...[
              SectionTitle('Datos de Verificación'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'El usuario no ha subido datos de verificación aún.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Divider(height: 40),
            ] else ...[
              SectionTitle('Datos de Verificación'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildImagePreview(
                      user.verification!.idCardFrontUrl, 'Frente DNI'),
                  _buildImagePreview(
                      user.verification!.idCardBackUrl, 'Reverso DNI'),
                  _buildImagePreview(user.verification!.faceWithIdUrl,
                      'Selfie con DNI'),
                ],
              ),
              const SizedBox(height: 16),
              if (user.verification!.status.toLowerCase() == 'pending')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _approveVerification(context, user),
                      child: const Text('Aprobar'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () =>
                          _rejectVerification(context, user),
                      child: const Text('Rechazar'),
                    ),
                  ],
                ),
              if (user.verification!.status.toLowerCase() == 'rejected' &&
                  (user.verification!.rejectionReason?.isNotEmpty ?? false))
                DetailRow(
                  icon: Icons.comment_bank,
                  label: 'Razón de Rechazo',
                  value: user.verification!.rejectionReason!,
                ),
              const Divider(height: 40),
            ],

            // — Sistema —
            SectionTitle('Información de Sistema'),
            if (user.blocked &&
                (user.banReason?.isNotEmpty ?? false))
              DetailRow(
                icon: Icons.gavel,
                label: 'Razón de Baneo',
                value: user.banReason!,
                valueColor: Colors.red.shade700,
              ),
            DetailRow(
                icon: Icons.note_alt,
                label: 'Notas de Admin',
                value: user.notesByAdmin.isNotEmpty
                    ? user.notesByAdmin
                    : 'Sin notas'),
            DetailRow(
                icon: Icons.person_add,
                label: 'Amigos',
                value: '${user.friends.length}'),
            DetailRow(
                icon: Icons.block,
                label: 'Usuarios Bloqueados',
                value: '${user.blockedUsers.length}'),
            DetailRow(
                icon: Icons.login,
                label: 'Último Login',
                value: _formatDate(user.lastLoginAt)),
            DetailRow(
                icon: Icons.date_range,
                label: 'Fecha de Creación',
                value: _formatDate(user.createdAt)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:
          const Text('Cerrar', style: TextStyle(color: Colors.black54)),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: implementar lógica de edición si hace falta
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 60, 90, 29)),
          child: const Text('Editar Usuario'),
        ),
      ],
    );
  }

  Widget _buildImagePreview(String url, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(url, width: 100, height: 70, fit: BoxFit.cover),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Future<void> _approveVerification(
      BuildContext ctx, UserModel user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'isVerified': true,
      'verification.status': 'approved',
      'verification.rejectionReason': null,
    });
    Navigator.of(ctx).pop();
  }

  Future<void> _rejectVerification(
      BuildContext ctx, UserModel user) async {
    final reason = await showDialog<String>(
      context: ctx,
      builder: (dialogCtx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Razón de rechazo'),
          content: TextField(
            controller: ctrl,
            decoration:
            const InputDecoration(hintText: 'Escribe el motivo'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancelar')),
            ElevatedButton(
                onPressed: () =>
                    Navigator.of(dialogCtx).pop(ctrl.text),
                child: const Text('Enviar')),
          ],
        );
      },
    );
    if (reason != null && reason.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'isVerified': false,
        'verification.status': 'rejected',
        'verification.rejectionReason': reason,
      });
      Navigator.of(ctx).pop();
    }
  }
}
