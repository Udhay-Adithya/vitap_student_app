import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/utils/format_to_12_hour.dart';
import 'package:vit_ap_student_app/core/utils/parse_class_time.dart';

class UpcomingClassCard extends StatelessWidget {
  final Day classInfo;

  const UpcomingClassCard({
    super.key,
    required this.classInfo,
  });

  @override
  Widget build(BuildContext context) {
    final (status, statusColor, textColor) = _getClassStatus(classInfo);

    return Stack(
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: 175,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(9)),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          formatTimeRange(
                              classInfo.startTime, classInfo.endTime),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(9)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  '${classInfo.courseName}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  '${classInfo.faculty}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  '${classInfo.courseCode} - ${classInfo.courseType}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  '${classInfo.venue}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
        (classInfo.courseType ?? '').contains('TH')
            ? Positioned(
                bottom: -26,
                right: -15,
                child: Lottie.asset(
                  'assets/lottie/books.json',
                  width: 165,
                  repeat: false,
                ),
              )
            : Positioned(
                bottom: -24,
                right: -25,
                child: Lottie.asset(
                  'assets/lottie/lab.json',
                  width: 175,
                  repeat: true,
                ),
              ),
      ],
    );
  }

  (String, Color, Color) _getClassStatus(Day classInfo) {
    final now = DateTime.now();

    // Missing or malformed times (e.g. the "-" placeholder) must not throw and
    // crash the card — fall back to a neutral "Scheduled" status instead.
    final parsedStartTime = parseClassTime(classInfo.startTime);
    final parsedEndTime = parseClassTime(classInfo.endTime);
    if (parsedStartTime == null || parsedEndTime == null) {
      return (
        'Scheduled',
        Colors.grey.shade400.withValues(alpha: 0.4),
        Colors.grey.shade700,
      );
    }

    if (now.isBefore(parsedStartTime)) {
      return (
        'Upcoming',
        Colors.blueAccent.shade200.withValues(alpha: 0.5),
        Colors.blue
      );
    } else if (now.isAfter(parsedEndTime)) {
      return (
        'Completed',
        Colors.greenAccent.shade200.withValues(alpha: 0.3),
        Colors.green
      );
    }
    return (
      'Ongoing',
      Colors.orange.shade300.withValues(alpha: 0.5),
      Colors.orange
    );
  }
}
