import 'package:flutter/material.dart';

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const DetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 16),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}