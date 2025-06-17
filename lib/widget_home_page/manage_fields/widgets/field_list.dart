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
          print(snapshot.error); // For debugging
          return const Center(child: Text('Error al cargar canchas'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay canchas registradas.'));
        }

        final filteredFields = snapshot.data!.docs.where((field) {
          final name = (field.data() as Map<String, dynamic>)['name']
              ?.toString()
              .toLowerCase() ??
              '';
          return name.contains(searchText);
        }).toList();

        if (filteredFields.isEmpty) {
          return const Center(child: Text('No se encontraron canchas.'));
        }

        return ListView.builder(
          itemCount: filteredFields.length,
          itemBuilder: (context, index) {
            final fieldDoc = filteredFields[index];
            // Delegamos la construcción de la tarjeta a su propio widget
            return FieldCard(
              docId: fieldDoc.id,
              fieldData: fieldDoc.data() as Map<String, dynamic>,
            );
          },
        );
      },
    );
  }
}