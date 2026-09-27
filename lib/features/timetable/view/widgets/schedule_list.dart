import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/utils/get_classes.dart';
import 'package:vit_ap_student_app/core/utils/weekday_date.dart';
import 'package:vit_ap_student_app/features/academic_calendar/model/non_instructional_days.dart';
import 'package:vit_ap_student_app/features/academic_calendar/viewmodel/non_instructional_days_provider.dart';
import 'package:vit_ap_student_app/features/timetable/view/widgets/schedule_timeline.dart';

class ScheduleList extends ConsumerWidget {
  final String day;

  const ScheduleList({super.key, required this.day});

  // Helper method to parse start time from "15:00 - 15:50" format for comparison
  int _parseStartTime(String? startTime) {
    if (startTime == null || startTime.isEmpty) return 0;

    try {
      // Extract start time from "15:00" format
      final timeParts = startTime.split(':');
      final hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);

      // Convert to minutes for easy comparison
      return hours * 60 + minutes;
    } catch (e) {
      debugPrint('Error parsing time: $startTime');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final Timetable? timetable = user?.timetable.target;

    if (timetable == null) return const EmptySchedule();

    // Null until the student has opened the calendar page at least once, in
    // which case nothing is known about holidays and the day reads as normal.
    final holidayReason = ref
        .watch(nonInstructionalDaysProvider)
        .maybeWhen(
          data: (days) => _holidayReasonFor(day, days),
          orElse: () => null,
        );

    final List<Day> classes = getClassesForDay(timetable, day);
    if (classes.isEmpty) {
      return holidayReason == null
          ? const EmptySchedule()
          : HolidayNotice(reason: holidayReason);
    }

    classes.sort((a, b) {
      final timeA = _parseStartTime(a.startTime);
      final timeB = _parseStartTime(b.startTime);
      return timeA.compareTo(timeB);
    });

    // The classes still render underneath. VTOP's timetable does not change on
    // a holiday, and showing the day empty would look like the timetable had
    // failed to load rather than like a day off.
    return Column(
      children: [
        if (holidayReason != null) HolidayBanner(reason: holidayReason),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final Day classItem = classes[index];
              return ScheduleTimeline(
                classInfo: classItem,
                isFirst: index == 0,
                isLast: index == classes.length - 1,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Why [weekdayName] has no classes, or null when it is an ordinary day.
  static String? _holidayReasonFor(
    String weekdayName,
    NonInstructionalDays days,
  ) {
    final date = dateForWeekdayInWeekOf(weekdayName, DateTime.now());
    if (date == null) return null;
    return days.reasonFor(date);
  }
}

/// Shown above a day's classes when the calendar says it is not a working day.
class HolidayBanner extends StatelessWidget {
  final String reason;

  const HolidayBanner({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration_outlined, size: 20, color: colors.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reason,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onTertiaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The empty-day view, when the day off is a known holiday rather than simply a
/// day with nothing timetabled.
class HolidayNotice extends StatelessWidget {
  final String reason;

  const HolidayNotice({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/cat_sleep.json', width: 150),
          Text(
            reason,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'No classes today 🎉',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptySchedule extends StatelessWidget {
  const EmptySchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/cat_sleep.json', width: 150),
          Text(
            'No classes found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            'Seems like a day off 😪',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
