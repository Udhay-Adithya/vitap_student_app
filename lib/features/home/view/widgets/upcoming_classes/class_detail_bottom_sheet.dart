import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/utils/format_to_12_hour.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/upcoming_classes/class_occurrence.dart';

/// The full record for a single class.
///
/// The cards in the Today stack deliberately show only what you decide with at a
/// glance — time, course, room. Everything else that used to compete for space on
/// the card (faculty, course code, slot) lives here, one tap away.
void showClassDetailBottomSheet(
  BuildContext context,
  ClassOccurrence occurrence,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (BuildContext context) =>
        _ClassDetailSheet(occurrence: occurrence),
  );
}

class _ClassDetailSheet extends StatelessWidget {
  const _ClassDetailSheet({required this.occurrence});

  final ClassOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final DateTime now = DateTime.now();
    final ClassPhase phase = occurrence.phaseAt(now);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              occurrence.info.courseName ?? 'Class',
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _Chip(label: _phaseLabel(phase, occurrence, now)),
                if ((occurrence.info.courseType ?? '').isNotEmpty)
                  _Chip(label: occurrence.info.courseType!),
                if ((occurrence.info.slot ?? '').isNotEmpty)
                  _Chip(label: 'Slot ${occurrence.info.slot}'),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.schedule_rounded,
              label: 'Time',
              value: formatTimeRange(
                occurrence.info.startTime,
                occurrence.info.endTime,
              ),
            ),
            _DetailRow(
              icon: Icons.place_outlined,
              label: 'Venue',
              value: occurrence.info.venue,
            ),
            _DetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Faculty',
              value: occurrence.info.faculty,
            ),
            _DetailRow(
              icon: Icons.tag_rounded,
              label: 'Course code',
              value: occurrence.info.courseCode,
            ),
          ],
        ),
      ),
    );
  }

  String _phaseLabel(
    ClassPhase phase,
    ClassOccurrence occurrence,
    DateTime now,
  ) {
    switch (phase) {
      case ClassPhase.ongoing:
        final Duration? left = occurrence.remainingAt(now);
        return left == null
            ? 'Happening now'
            : '${formatShortDuration(left)} left';
      case ClassPhase.completed:
        return 'Completed';
      case ClassPhase.upcoming:
        final Duration? until = occurrence.startsInAt(now);
        return until == null
            ? 'Scheduled'
            : 'Starts in ${formatShortDuration(until)}';
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: cs.onSecondaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final String text = (value ?? '').trim().isEmpty ? '—' : value!.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(text, style: tt.bodyLarge?.copyWith(color: cs.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
