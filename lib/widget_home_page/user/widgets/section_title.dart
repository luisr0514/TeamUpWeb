import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}