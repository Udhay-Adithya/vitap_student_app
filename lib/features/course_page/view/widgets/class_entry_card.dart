import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/features/course_page/model/slots_response.dart';

class ClassEntryCard extends StatelessWidget {
  final CourseClassEntryModel entry;
  final VoidCallback onTap;

  const ClassEntryCard({super.key, required this.entry, required this.onTap});

  String _extractFacultyName(String faculty) {
    // Faculty format: "70735 - Shaik Subhani - SCOPE"
    final parts = faculty.split(' - ');
    if (parts.length >= 2) {
      return parts[1];
    }
    return faculty;
  }

  @override
  Widget build(BuildContext context) {
    final facultyName = _extractFacultyName(entry.faculty);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          facultyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${entry.courseCode} - ${entry.slot}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
