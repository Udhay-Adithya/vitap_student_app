import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/utils/format_to_12_hour.dart';

class ScheduleTimeline extends StatelessWidget {
  final Day classInfo;
  final bool isFirst;
  final bool isLast;
  final int index;

  const ScheduleTimeline({
    super.key,
    required this.classInfo,
    required this.isFirst,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = classInfo.startTime?.trim();

    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.05,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: _buildIndicatorStyle(context),
      beforeLineStyle: _buildLineStyle(context),
      endChild: _buildClassDetails(context, startTime),
    );
  }

  IndicatorStyle _buildIndicatorStyle(BuildContext context) {
    return IndicatorStyle(
      iconStyle: IconStyle(
        fontSize: 5.0,
        iconData: Icons.circle,
        color: Theme.of(context).colorScheme.surface,
      ),
      indicatorXY: 0.13,
      width: 12,
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 5),
    );
  }

  LineStyle _buildLineStyle(BuildContext context) {
    return LineStyle(
      color: Theme.of(context).colorScheme.secondaryContainer,
      thickness: 1.5,
    );
  }

  Widget _buildClassDetails(BuildContext context, String? startTime) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeRange(context, startTime),
              const SizedBox(width: 8),
              _buildClassInfoCard(context),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTimeRange(BuildContext context, String? startTime) {
    final endLabel = formatTo12Hour(classInfo.endTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatTo12Hour(startTime),
          style: const TextStyle(fontSize: 16),
        ),
        if (endLabel.isNotEmpty)
          Text(
            endLabel,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildClassInfoCard(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 10, top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoText(classInfo.courseName, context, isTitle: true),
              const SizedBox(
                height: 8,
              ),
              _buildInfoText(classInfo.faculty, context),
              _buildInfoText(
                  '${classInfo.courseCode} - ${classInfo.courseType}', context),
              _buildInfoText(classInfo.venue, context),
              _buildInfoText(classInfo.slot?.split('-').first, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String? text, BuildContext context,
      {bool isTitle = false}) {
    return Text(
      text ?? 'N/A',
      style: TextStyle(
        fontSize: isTitle ? 16 : 14,
        color: isTitle
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSecondaryContainer,
        fontWeight: isTitle ? FontWeight.w500 : FontWeight.normal,
      ),
    );
  }
}
