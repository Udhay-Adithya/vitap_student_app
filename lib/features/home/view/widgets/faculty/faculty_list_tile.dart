import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/common/widget/user_icon.dart';
import 'package:vit_ap_student_app/features/home/model/faculty.dart';

class FacultyListTile extends StatelessWidget {
  final FacultyListItem faculty;
  final VoidCallback onTap;

  const FacultyListTile({
    super.key,
    required this.faculty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: UserIcon(name: faculty.facultyName),
      title: Text(
        faculty.facultyName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faculty.designation,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            faculty.schoolOrCentre,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      isThreeLine: true,
      onTap: onTap,
    );
  }
}
