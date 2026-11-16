import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/app_tab_bar.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/models/attendance.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/attendance/model/attendance_detail.dart';
import 'package:vit_ap_student_app/features/attendance/viewmodel/detailed_attendance_viewmodel.dart';
import 'package:wave/wave.dart';

void showAttendanceBottomSheet(BuildContext context, Attendance subjectInfo) {
  final String attendanceStr = subjectInfo.attendancePercentage;
  final double attendancePercentage = double.tryParse(attendanceStr) ?? 0.0;

  // Analytics tracking
  ProviderScope.containerOf(context, listen: false)
      .read(analyticsServiceProvider)
      .logEvent(AnalyticsEvents.attendanceDetailOpened, {
        AnalyticsParams.courseCode: subjectInfo.courseCode,
        AnalyticsParams.courseType: subjectInfo.courseType,
        'attendance_percentage': attendancePercentage,
      });

  showModalBottomSheet<dynamic>(
    showDragHandle: true,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, child) {
          return DefaultTabController(
            length: 2,
            child: Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);

                // Listen to tab changes and fetch data when Day-wise tab is selected
                tabController.addListener(() {
                  if (tabController.index == 1) {
                    // Day-wise tab
                    final detailedAttendanceState = ref.read(
                      detailedAttendanceViewmodelProvider,
                    );

                    // Only fetch if we don't have data yet
                    if (detailedAttendanceState == null) {
                      ref
                          .read(detailedAttendanceViewmodelProvider.notifier)
                          .fetchDetailedAttendance(
                            courseId: subjectInfo.courseId,
                            courseType: subjectInfo.courseTypeCode,
                          );
                    }
                  }
                });

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.85,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        const AppTabBar(tabs: ['Summary', 'Day-wise']),
                        // Tab Views
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Summary Tab
                              _buildSummaryTab(
                                context,
                                subjectInfo,
                                attendancePercentage,
                              ),
                              // Detailed Tab
                              _buildDetailedTab(context, subjectInfo, ref),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}

Widget _buildSummaryTab(
  BuildContext context,
  Attendance subjectInfo,
  double attendancePercentage,
) {
  final String attendanceStr = subjectInfo.attendancePercentage;
  final double waveHeight = ((attendancePercentage) / 100) == 1
      ? 1
      : ((attendancePercentage) / 100);

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
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: WaveWidget(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        waveAmplitude: 0,
                        config: CustomConfig(
                          gradients: [
                            [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.4),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                            ],
                            [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.7),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.5),
                            ],
                            [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.8),
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
                          value: '$attendanceStr%',
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        _buildSummaryCard(
                          context,
                          title: 'Recent Attendance',
                          value: '${subjectInfo.betweenAttendancePercentage}%',
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryCard(
                          context,
                          title: 'Attended Classes',
                          value:
                              '${subjectInfo.attendedClasses}/${subjectInfo.totalClasses}',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildCourseInfoSection(context, subjectInfo),
      ],
    ),
  );
}

Widget _buildSummaryCard(
  BuildContext context, {
  required String title,
  required String value,
}) {
  return Container(
    height: 94,
    width: MediaQuery.sizeOf(context).width - 181,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.centerRight,
        colors: [
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          Theme.of(context).colorScheme.primary,
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
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildCourseInfoSection(BuildContext context, Attendance subjectInfo) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context, 'Course Name', subjectInfo.courseName),
              _buildInfoRow(context, 'Course Code', subjectInfo.courseCode),
              _buildInfoRow(context, 'Course Slot', subjectInfo.courseSlot),
              _buildInfoRow(context, 'Course Type', subjectInfo.courseType),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildInfoRow(BuildContext context, String label, String value) {
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
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetailedTab(
  BuildContext context,
  Attendance subjectInfo,
  WidgetRef ref,
) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with refresh button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Day-wise Attendance',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            Consumer(
              builder: (context, ref, child) {
                final detailedAttendanceState = ref.watch(
                  detailedAttendanceViewmodelProvider,
                );

                return IconButton.filled(
                  onPressed: () {
                    ref
                        .read(analyticsServiceProvider)
                        .logEvent(AnalyticsEvents.refreshInitiated, {
                          AnalyticsParams.dataType: 'attendance_detail',
                          AnalyticsParams.courseType:
                              subjectInfo.courseType.contains('Theory')
                              ? 'ETH'
                              : 'ELA',
                        });
                    ref
                        .read(detailedAttendanceViewmodelProvider.notifier)
                        .fetchDetailedAttendance(
                          courseId: subjectInfo.courseId,
                          courseType: subjectInfo.courseTypeCode,
                        );
                  },
                  icon: detailedAttendanceState?.isLoading == true
                      ? const Loader()
                      : const Icon(Icons.refresh_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Attendance table
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final detailedAttendanceState = ref.watch(
                detailedAttendanceViewmodelProvider,
              );

              if (detailedAttendanceState == null) {
                // Show loading immediately since data will be fetched when tab is accessed
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Loader(),
                      SizedBox(height: 16),
                      Text('Loading detailed attendance...'),
                    ],
                  ),
                );
              }

              return detailedAttendanceState.when(
                data: (attendanceDetails) =>
                    _buildAttendanceTable(context, attendanceDetails),
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Loader(),
                      SizedBox(height: 16),
                      Text('Loading detailed attendance...'),
                    ],
                  ),
                ),
                error: (error, stackTrace) =>
                    _buildErrorState(context, error.toString(), () {
                      ref
                          .read(detailedAttendanceViewmodelProvider.notifier)
                          .fetchDetailedAttendance(
                            courseId: subjectInfo.courseId,
                            courseType: subjectInfo.courseTypeCode,
                          );
                    }),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildEmptyState(BuildContext context, VoidCallback onRefresh) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_view_day_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          'No detailed attendance data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the refresh button to load day-wise attendance',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Load Data'),
        ),
      ],
    ),
  );
}

Widget _buildErrorState(
  BuildContext context,
  String error,
  VoidCallback onRetry,
) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Failed to load data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}

Widget _buildAttendanceTable(
  BuildContext context,
  List<AttendanceDetail> attendanceDetails,
) {
  if (attendanceDetails.isEmpty) {
    return _buildEmptyState(context, () {});
  }

  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  'SNo.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '  Date',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Day/Time',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // Table Body
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: attendanceDetails.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
            itemBuilder: (context, index) {
              final detail = attendanceDetails[index];
              final isPresent = detail.status.toLowerCase() == 'present';
              final isAbsent = detail.status.toLowerCase() == 'absent';

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: index.isEven
                      ? Theme.of(context).colorScheme.surfaceContainerHigh
                      : Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        ' ${index + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatDate(detail.date),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail.dayTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPresent
                              ? Colors.green
                              : isAbsent
                              ? Colors.red
                              : Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

String _formatDate(String dateStr) {
  try {
    // Assuming the date format from VTOP, adjust as needed
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      final day = parts[0];
      final month = parts[1];
      final year = parts[2];
      return '$day/$month/$year';
    }
    return dateStr;
  } catch (e) {
    return dateStr;
  }
}
