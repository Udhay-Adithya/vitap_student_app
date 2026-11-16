import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/utils/get_classes.dart';
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

    final List<Day> classes = getClassesForDay(timetable, day);
    if (classes.isEmpty) return const EmptySchedule();

    classes.sort((a, b) {
      final timeA = _parseStartTime(a.startTime);
      final timeB = _parseStartTime(b.startTime);
      return timeA.compareTo(timeB);
    });

    return ListView.builder(
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
          const SizedBox(height: 2),
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
