import 'package:flutter/material.dart';
import 'widgets/action_row.dart';
import 'widgets/field_list.dart';
import 'widgets/field_form_dialog.dart';

class ManageFieldsPage extends StatefulWidget {
  const ManageFieldsPage({Key? key}) : super(key: key);

  @override
  State<ManageFieldsPage> createState() => _ManageFieldsPageState();
}

class _ManageFieldsPageState extends State<ManageFieldsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchText = _searchController.text.toLowerCase();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddFieldDialog() {
    showDialog(
      context: context,
      builder: (context) => FieldFormDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Canchas')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  ActionRow(
                    searchController: _searchController,
                    onAddField: _showAddFieldDialog,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: FieldList(searchText: _searchText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
