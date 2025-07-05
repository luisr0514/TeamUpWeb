import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class Reports extends StatelessWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
      ),
      body: Column(
        children: [
          // Resumen de reportes
          _buildReportsSummary(),
          
          // Lista de reportes
          Expanded(
            child: _buildReportsList(),
          ),
        ],
      ),
    );
  }



  Widget _buildReportsSummary() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reports').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final total = snapshot.data!.docs.length;
          final resolved = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'resolved';
          }).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen de Reportes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Total', total.toString()),
                  _buildSummaryItem('Pendientes', (total - resolved).toString()),
                  _buildSummaryItem('Resueltos', resolved.toString()),
                ],
              ),
              const Divider(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildReportsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .orderBy('fecha', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No hay reportes disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final report = snapshot.data!.docs[index];
            final data = report.data() as Map<String, dynamic>;
            
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['ownerId'])
                  .get(),
              builder: (context, userSnapshot) {
                String userName = 'Usuario desconocido';
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  userName = userData['fullName'] ?? 
                            userData['username'] ?? 
                            userData['email']?.split('@').first ?? 
                            'Usuario';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(data['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(data['status']),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getReportIcon(data['categoria']),
                        color: _getStatusColor(data['status']),
                      ),
                    ),
                    title: Text(
                      data['categoria'] ?? 'Reporte sin categoría',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatDate(data['fecha'])} • $userName',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showReportDetails(context, report.id, data, userName),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showReportDetails(BuildContext context, String reportId, Map<String, dynamic> data, String userName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data['categoria'] ?? 'Detalles del Reporte'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Categoría', data['categoria'] ?? 'No especificada'),
                _buildDetailRow('Fecha', _formatDate(data['fecha'])),
                _buildDetailRow('Reportado por', userName),
                const SizedBox(height: 16),
                const Text(
                  'Descripción:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(data['descripcion'] ?? 'Sin descripción'),
                if (data['foto'] != null && data['foto'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Evidencia:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Image.network(data['foto']),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (data['status'] != 'resolved')
              TextButton(
                child: const Text('Resolver', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('reports')
                      .doc(reportId)
                      .update({'status': 'resolved'});
                  Navigator.of(context).pop();
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(dynamic fecha) {
    if (fecha == null) return 'Fecha desconocida';
    try {
      if (fecha is Timestamp) {
        return DateFormat('dd/MM/yyyy HH:mm').format(fecha.toDate());
      } else if (fecha is String) {
        return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(fecha));
      }
      return 'Fecha no válida';
    } catch (e) {
      return 'Fecha no válida';
    }
  }

  IconData _getReportIcon(String? categoria) {
    switch (categoria?.toLowerCase()) {
      case 'comportamiento de jugadores':
        return Icons.people;
      case 'pago':
        return Icons.payment;
      case 'cancha':
        return Icons.place;
      default:
        return Icons.report;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}