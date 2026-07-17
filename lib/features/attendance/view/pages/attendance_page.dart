import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vit_ap_student_app/core/common/widget/course_type_tab_bar.dart';
import 'package:vit_ap_student_app/core/common/widget/empty_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/error_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/attendance/view/widgets/attendance_course_card.dart';
import 'package:vit_ap_student_app/features/attendance/viewmodel/attendance_viewmodel.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  AttendancePageState createState() => AttendancePageState();
}

class AttendancePageState extends ConsumerState<AttendancePage>
    with SingleTickerProviderStateMixin {
  DateTime? lastSynced;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadLastSynced();
    AnalyticsService.logScreen('AttendancePage');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadLastSynced() async {
    final prefs = ref.read(userPreferencesProvider);
    final DateTime? lastSyncedString = prefs.attendanceLastSync;
    if (lastSyncedString != null) {
      setState(() {
        lastSynced = lastSyncedString;
      });
    }
    // Auto-refresh if last sync was more than 24 hours ago
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shouldRefresh()) {
        refreshAttendanceData(silentRefresh: true);
      }
    });
  }

  Future<void> saveLastSynced() async {
    final prefs = ref.read(userPreferencesProvider);
    await ref
        .read(userPreferencesProvider.notifier)
        .updatePreferences(prefs.copyWith(attendanceLastSync: lastSynced!));
  }

  Future<void> refreshAttendanceData({bool silentRefresh = false}) async {
    await AnalyticsService.logEvent('attendance_refresh_initiated', {
      'timestamp': DateTime.now().toIso8601String(),
    });
    await ref
        .read(attendanceViewModeProvider.notifier)
        .refreshAttendance(silentRefresh: silentRefresh);
    // Only stamp "last synced" when the refresh actually succeeded. The view
    // model swallows failures into its error state (e.g. a cancelled/failed
    // OTP or network error), so advancing the timer unconditionally would lie.
    final state = ref.read(attendanceViewModeProvider);
    if (state != null && !state.hasError) {
      lastSynced = DateTime.now();
      await saveLastSynced();
    }
  }

  bool _shouldRefresh() {
    if (lastSynced == null) return true;
    final difference = DateTime.now().difference(lastSynced!);
    return difference.inHours >= 24;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    final isLoading = ref.watch(
      attendanceViewModeProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(attendanceViewModeProvider, (_, next) {
      next?.when(
        data: (data) {},
        loading: () {},
        error: (error, st) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            if (lastSynced != null)
              Text(
                'Last Synced: ${timeago.format(lastSynced!)} 💾',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.refresh_copy,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              refreshAttendanceData();
            },
            tooltip: 'Refresh',
          ),
        ],
        bottom: CourseTypeTabBar(controller: _tabController),
      ),
      body: isLoading
          ? const Loader()
          : RefreshIndicator(
              onRefresh: () => refreshAttendanceData(),
              notificationPredicate: (notification) => notification.depth == 1,
              child: TabBarView(
                controller: _tabController,
                children: [_buildBody(user, 'Theory'), _buildBody(user, 'Lab')],
              ),
            ),
    );
  }

  Widget _buildBody(User? user, String courseTypeFilter) {
    if (user == null) {
      return const ErrorContentView(error: 'User not found!');
    }

    final attendances = user.attendance.toList();

    // Filter attendances based on course type
    final filteredAttendances = attendances.where((attendance) {
      return attendance.courseType.contains(courseTypeFilter);
    }).toList();

    if (filteredAttendances.isEmpty) {
      return EmptyContentView(
        primaryText: 'No $courseTypeFilter Courses found',
        secondaryText: 'Feels so empty',
      );
    }

    return ListView.builder(
      itemCount: filteredAttendances.length,
      itemBuilder: (context, index) {
        final attendance = filteredAttendances[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: Row(
            children: [
              Flexible(child: AttendanceCourseCard(attendance: attendance)),
            ],
          ),
        );
      },
    );
  }
}
