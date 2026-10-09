import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/common/widget/app_tab_bar.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/models/capstone_attendance.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/attendance/utils/capstone_punch_order.dart';
import 'package:vit_ap_student_app/features/attendance/view/widgets/capstone_attendance_card.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:wave/wave.dart';

/// The capstone/SDP detail sheet.
///
/// Unlike the course sheet this fetches nothing: VTOP returns the registration
/// details, the tally and the whole punch calendar in the one response the
/// attendance refresh already made, so both tabs are instant.
void showCapstoneAttendanceSheet(
  BuildContext context,
  CapstoneAttendance capstone,
) {
  serviceLocator<AnalyticsService>()
      .logEvent(AnalyticsEvents.attendanceDetailOpened, {
        AnalyticsParams.courseType: 'capstone',
        'attendance_percentage': capstone.percentageValue ?? -1,
      });

  showModalBottomSheet<dynamic>(
    showDragHandle: true,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return DefaultTabController(
        length: 2,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                const AppTabBar(tabs: ['Summary', 'Day-wise']),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSummaryTab(context, capstone),
                      _buildCalendarTab(context, capstone),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildSummaryTab(BuildContext context, CapstoneAttendance capstone) {
  final colorScheme = Theme.of(context).colorScheme;
  final percentage = capstone.percentageValue;
  final waveHeight = ((percentage ?? 0) / 100).clamp(0.0, 1.0);

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Summary',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: WaveWidget(
                    backgroundColor: colorScheme.primaryContainer,
                    waveAmplitude: 0,
                    config: CustomConfig(
                      gradients: [
                        [
                          colorScheme.primary.withValues(alpha: 0.4),
                          colorScheme.primary.withValues(alpha: 0.2),
                        ],
                        [
                          colorScheme.primary.withValues(alpha: 0.7),
                          colorScheme.primary.withValues(alpha: 0.5),
                        ],
                        [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ],
                      gradientBegin: Alignment.bottomLeft,
                      gradientEnd: Alignment.topRight,
                      durations: [8000, 10000, 12000],
                      heightPercentages: [
                        1 - waveHeight,
                        1 - waveHeight + 0.02,
                        1 - waveHeight + 0.05,
                      ],
                      blur: const MaskFilter.blur(BlurStyle.solid, 0),
                    ),
                    size: const Size(125, 300),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    _buildSummaryCard(
                      context,
                      title: 'Overall Attendance',
                      value: percentage == null
                          ? '--'
                          : '${capstone.percentage}%',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryCard(
                      context,
                      title: 'Days Attended',
                      value:
                          '${capstone.presentDays + capstone.onDutyDays}/${capstone.totalDays}',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryCard(
                      context,
                      title: 'Days Absent',
                      value: '${capstone.absentDays}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CapstoneTallyRow(capstone: capstone),
                const SizedBox(height: 12),
                // Only the fields VTOP actually filled in are shown; an empty
                // row is worse than no row.
                ..._buildInfoRows(context, capstone),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

List<Widget> _buildInfoRows(BuildContext context, CapstoneAttendance capstone) {
  final rows = <(String, String)>[
    ('Project', capstone.title),
    ('Guide Evaluation Status', capstone.guideEvaluationStatus),
    ('Registered On', capstone.dateOfRegistration),
  ].where((row) => row.$2.isNotEmpty);

  return [
    for (final (label, value) in rows) _buildInfoRow(context, label, value),
  ];
}

Widget _buildSummaryCard(
  BuildContext context, {
  required String title,
  required String value,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    height: 94,
    width: MediaQuery.sizeOf(context).width - 181,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.centerRight,
        colors: [
          colorScheme.primary.withValues(alpha: 0.8),
          colorScheme.primary,
        ],
      ),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 32,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 3.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoRow(BuildContext context, String label, String value) {
  final colorScheme = Theme.of(context).colorScheme;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

Widget _buildCalendarTab(BuildContext context, CapstoneAttendance capstone) {
  final colorScheme = Theme.of(context).colorScheme;
  final punches = newestPunchesFirst(capstone.punches);

  if (punches.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_view_day_outlined,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No day-wise attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'VTOP has not published a punch calendar for this registration yet',
              style: TextStyle(fontSize: 14, color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Day-wise Attendance',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: _headerCell(context, 'Date')),
                      Expanded(
                        flex: 3,
                        child: _headerCell(context, 'Day Type'),
                      ),
                      Expanded(
                        flex: 2,
                        child: _headerCell(
                          context,
                          'Status',
                          align: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _headerCell(
                          context,
                          'Punch',
                          align: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: punches.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    itemBuilder: (context, index) =>
                        _buildPunchRow(context, punches[index], index),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _headerCell(
  BuildContext context,
  String label, {
  TextAlign align = TextAlign.start,
}) {
  return Text(
    label,
    textAlign: align,
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onPrimary,
      fontSize: 14,
    ),
  );
}

Widget _buildPunchRow(BuildContext context, CapstonePunch punch, int index) {
  final colorScheme = Theme.of(context).colorScheme;

  // A day with no status is a holiday or a day not yet reached, not an absence.
  final status = punch.status;
  final statusColor = switch (status.toLowerCase()) {
    'present' => colorScheme.primary,
    'absent' => colorScheme.error,
    'on duty' || 'od' => colorScheme.tertiary,
    _ => colorScheme.onSurfaceVariant,
  };

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    color: index.isEven
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainer,
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                punch.date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (punch.day.isNotEmpty)
                Text(
                  _titleCase(punch.day),
                  style: TextStyle(fontSize: 11, color: colorScheme.outline),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            punch.dayType,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            status.isEmpty ? '—' : status,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            punch.punchTime.isEmpty ? '—' : punch.punchTime,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    ),
  );
}

/// VTOP shouts the weekday ("SATURDAY"); this is only ever a supporting line
/// under the date, so it is toned down.
String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}
