import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/models/exam_schedule.dart';

enum _ExamStatus { today, upcoming, completed, unknown }

class ExamCard extends StatelessWidget {
  final Subject exam;
  final VoidCallback? onTap;

  const ExamCard({super.key, required this.exam, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = _statusForExam(exam.date);
    final isToday = status == _ExamStatus.today;
    final isCompleted = status == _ExamStatus.completed;
    final statusColor = _statusColor(status, colorScheme);
    final statusLabel = _statusLabel(status);

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
            gradient: isToday
                ? LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.1),
                      colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and status
              Row(
                children: [
                  Expanded(
                    child: _DateTimeChip(
                      date: exam.date,
                      session: exam.session,
                      isToday: isToday,
                      isCompleted: isCompleted,
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(label: statusLabel, color: statusColor),
                ],
              ),

              const SizedBox(height: 16),

              // Course information
              Text(
                exam.courseTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                exam.courseCode,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // Exam details in organized sections
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DetailSection(
                      icon: Icons.access_time,
                      title: 'Time',
                      content: exam.examTime,
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DetailSection(
                      icon: Icons.location_on,
                      title: 'Venue',
                      content: exam.venue,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DetailSection(
                      icon: Icons.event_seat,
                      title: 'Seat Location',
                      content: exam.seatLocation.trim(),
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DetailSection(
                      icon: Icons.numbers,
                      title: 'Seat Number',
                      content: exam.seatNumber.trim(),
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),

              if (exam.reportingTime.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reporting: ${exam.reportingTime}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _ExamStatus _statusForExam(String dateStr) {
    final examDate = _parseExamDate(dateStr);
    if (examDate == null) return _ExamStatus.unknown;

    final today = _stripTime(DateTime.now());
    final examDay = _stripTime(examDate);

    if (examDay.isAtSameMomentAs(today)) return _ExamStatus.today;
    if (examDay.isAfter(today)) return _ExamStatus.upcoming;
    return _ExamStatus.completed;
  }

  String _statusLabel(_ExamStatus status) {
    switch (status) {
      case _ExamStatus.today:
        return 'Today';
      case _ExamStatus.upcoming:
        return 'Upcoming';
      case _ExamStatus.completed:
        return 'Completed';
      case _ExamStatus.unknown:
        return 'Scheduled';
    }
  }

  Color _statusColor(_ExamStatus status, ColorScheme colorScheme) {
    switch (status) {
      case _ExamStatus.today:
        return colorScheme.primary;
      case _ExamStatus.upcoming:
        return colorScheme.tertiary;
      case _ExamStatus.completed:
        return colorScheme.secondary;
      case _ExamStatus.unknown:
        return colorScheme.primary;
    }
  }

  /// Parses exam date string into DateTime.
  ///
  /// Expected format: DD-MMM-YYYY (e.g., "18-Aug-2025")
  /// - DD: Two-digit day (01-31)
  /// - MMM: Three-letter month abbreviation (Jan, Feb, Mar, etc.)
  /// - YYYY: Four-digit year
  DateTime? _parseExamDate(String dateStr) {
    try {
      final dateParts = dateStr.split('-');
      if (dateParts.length != 3) return null;

      final months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };

      final day = int.tryParse(dateParts[0]);
      final month = months[dateParts[1]];
      final year = int.tryParse(dateParts[2]);

      if (day == null || month == null || year == null) return null;
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  DateTime _stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

class _DateTimeChip extends StatelessWidget {
  final String date;
  final String session;
  final bool isToday;
  final bool isCompleted;
  final ColorScheme colorScheme;

  const _DateTimeChip({
    required this.date,
    required this.session,
    required this.isToday,
    required this.isCompleted,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isToday
            ? colorScheme.primary.withValues(alpha: 0.1)
            : isCompleted
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$date • $session',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final ColorScheme colorScheme;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
