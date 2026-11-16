import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/schedule_clock.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/upcoming_classes/class_occurrence.dart';

/// "3 left" next to the Today heading.
///
/// How much of the day is still ahead is the question the section exists to
/// answer, and under the old carousel it was only readable by counting indicator
/// dots. Hidden on a day off, where the stack's own label already says so.
class TodayClassCountBadge extends ConsumerWidget {
  const TodayClassCountBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = watchScheduleNow(ref);
    final Timetable? timetable = ref
        .watch(currentUserProvider)
        ?.timetable
        .target;
    if (timetable == null) return const SizedBox.shrink();

    final List<ClassOccurrence> today = classesOn(timetable, now);
    if (today.isEmpty) return const SizedBox.shrink();

    final int remaining = today
        .where((ClassOccurrence c) => c.phaseAt(now) != ClassPhase.completed)
        .length;

    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        remaining == 0 ? 'Done' : '$remaining left',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
