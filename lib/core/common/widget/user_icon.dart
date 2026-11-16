import 'dart:math';

import 'package:flutter/material.dart';

class UserIcon extends StatefulWidget {
  final String name;
  const UserIcon({super.key, required this.name});

  @override
  State<UserIcon> createState() => _LeadingIconState();
}

class _LeadingIconState extends State<UserIcon> {
  @override
  Widget build(BuildContext context) {
    final Random randomObj = Random();
    final List<Color> colors = [
      Colors.red.shade100,
      Colors.amber.shade100,
      Colors.blue.shade100,
      Colors.pink.shade100,
      Colors.purple.shade100,
      Colors.indigo.shade100,
      Colors.blueGrey.shade100,
      Colors.brown.shade100,
      Colors.cyan.shade100,
      Colors.deepOrange.shade100,
      Colors.lime.shade100,
    ];
    final String facultyName = widget.name.trim();
    if (facultyName.isNotEmpty) {
      final String firstLetter = facultyName.characters.first;
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(color: colors[randomObj.nextInt(11)]),
          child: Center(
            child: Text(
              firstLetter,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    } else {
      return const CircleAvatar(child: Text('N/A'));
    }
  }
}
