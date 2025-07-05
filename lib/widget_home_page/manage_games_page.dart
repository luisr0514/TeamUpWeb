import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageGamesPage extends StatefulWidget {
  const ManageGamesPage({super.key});

  @override
  State<ManageGamesPage> createState() => _ManageGamesPageState();
}

class _ManageGamesPageState extends State<ManageGamesPage> {
  DateTime? selectedDate;

  // Formato para mostrar fecha legible
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  // Filtrar juegos en base a fecha
  List<QueryDocumentSnapshot> _filterGames(List<QueryDocumentSnapshot> games) {
    return games.where((game) {
      final createdAtTimestamp = game['date'] as Timestamp?;
      final createdAtDate = createdAtTimestamp != null ? createdAtTimestamp.toDate() : null;

      final matchDate = selectedDate == null
          ? true
          : (createdAtDate != null &&
              createdAtDate.year == selectedDate!.year &&
              createdAtDate.month == selectedDate!.month &&
              createdAtDate.day == selectedDate!.day);

      return matchDate;
    }).toList();
  }

  Future<void> _selectDate() async {
   final now = DateTime.now();
  final initialDate = selectedDate ?? now;
  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000), 
    lastDate: DateTime(2100), 
    helpText: 'Seleccione fecha para filtrar',
  );
  if (picked != null) {
    setState(() {
      selectedDate = picked;
      });
    }
  }

  void _clearDate() {
    setState(() {
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Historial de Juegos',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 46, 69, 23),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Fila con ambos botones alineados horizontalmente a la misma altura
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    selectedDate == null
                        ? 'Filtrar por fecha'
                        : DateFormat('dd/MM/yyyy').format(selectedDate!),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: _selectDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedDate == null
                        ? const Color.fromARGB(255, 125, 176, 64)
                        : const Color.fromARGB(255, 140, 192, 81),
                    foregroundColor: Colors.white,
                  ),
                ),
                if (selectedDate != null)
                  IconButton(
                    tooltip: 'Limpiar filtro fecha',
                    icon: const Icon(Icons.close),
                    onPressed: _clearDate,
                    color: Colors.black54,
                    splashRadius: 20,
                  ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text(
                    'Exportar CSV',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    // Sin funcionalidad intencionada
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 125, 176, 64),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('games')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No hay juegos registrados.'));
                  }

                  final games = snapshot.data!.docs;
                  final filteredGames = _filterGames(games);

                  if (filteredGames.isEmpty) {
                    return const Center(child: Text('No se encontraron juegos con esos filtros.'));
                  }

                  return ListView.builder(
                    itemCount: filteredGames.length,
                    itemBuilder: (context, index) {
                      final game = filteredGames[index];
                      final gameName = game['fieldName']?.toString() ?? 'Sin nombre';
                      final createdAtTimestamp = game['date'] as Timestamp?;
                      final createdAtString = createdAtTimestamp != null
                          ? _dateFormat.format(createdAtTimestamp.toDate())
                          : 'Fecha no disponible';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          title: Text(
                            gameName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Creado el: $createdAtString',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      );
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
}
