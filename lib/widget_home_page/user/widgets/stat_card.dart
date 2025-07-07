import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isWarning;

  const StatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.isWarning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? Colors.red.shade600 : Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
