import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'field_card.dart';

class FieldList extends StatelessWidget {
  final String searchText;

  const FieldList({Key? key, required this.searchText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('fields').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar canchas'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No hay canchas registradas.'));
        }

        final filtered = docs.where((d) {
          final name = (d.data() as Map<String, dynamic>)['name']
              ?.toString()
              .toLowerCase() ??
              '';
          return name.contains(searchText);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No se encontraron canchas.'));
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final d = filtered[i];
            return FieldCard(
              docId: d.id,
              fieldData: d.data() as Map<String, dynamic>,
            );
          },
        );
      },
    );
  }
}
