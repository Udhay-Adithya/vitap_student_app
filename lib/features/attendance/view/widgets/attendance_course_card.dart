import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/models/attendance.dart';
import 'package:vit_ap_student_app/features/attendance/view/widgets/attendance_bottom_sheet.dart';
import 'package:vit_ap_student_app/features/attendance/view/widgets/attendance_percentage_text.dart';

class AttendanceCourseCard extends StatelessWidget {
  final Attendance attendance;

  const AttendanceCourseCard({super.key, required this.attendance});

  bool _shouldShowDebarStatus() {
    final debarStatus = attendance.debarStatus.trim();
    // Show if it contains both "Debarred" and "Permitted" or only "Debarred"
    return debarStatus.contains('Debarred') ||
        debarStatus.contains('Permitted');
  }

  bool _isOnlyDebarred() {
    final debarStatus = attendance.debarStatus.trim();
    // Check if it contains only "Debarred" (not "Permitted")
    return debarStatus.contains('Debarred') &&
        !debarStatus.contains('Permitted');
  }

  @override
  Widget build(BuildContext context) {
    final isDebarred = _isOnlyDebarred();
    final showDebarStatus = _shouldShowDebarStatus();

    return ListTile(
      tileColor: isDebarred
          ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3)
          : Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AttendancePercentageText(
            attendancePercentage:
                double.tryParse(attendance.attendancePercentage) ?? 0.0,
          ),
          const SizedBox(height: 12),
          Text(
            attendance.courseName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Text(
            attendance.courseCode,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (showDebarStatus) ...[
            const SizedBox(height: 4),
            Text(
              attendance.debarStatus,
              style: TextStyle(
                color: isDebarred
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        showAttendanceBottomSheet(context, attendance);
      },
    );
  }
}
