import 'package:flutter/material.dart';

class FacultySearchBar extends StatelessWidget {
  final TextEditingController controller;
  const FacultySearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Search faculty name...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
