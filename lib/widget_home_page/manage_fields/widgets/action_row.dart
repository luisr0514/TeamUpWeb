import 'package:flutter/material.dart';

class ActionRow extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onAddField;

  const ActionRow({
    Key? key,
    required this.searchController,
    required this.onAddField,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildSearchField(),
        const SizedBox(width: 16),
        _buildActionButton('Export CSV', Colors.transparent),
        const SizedBox(width: 16),
        _buildAddFieldButton(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: Container(
        height: 41,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar canchas...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, Color backgroundColor) {
    return Container(
      width: 133,
      height: 41,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildAddFieldButton() {
    return GestureDetector(
      onTap: onAddField,
      child: Container(
        width: 151,
        height: 41,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 125, 176, 64),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Agregar cancha',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}