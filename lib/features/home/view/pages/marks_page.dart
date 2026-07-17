import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vit_ap_student_app/core/common/widget/empty_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/error_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/marks/dynamic_course_type_tab_bar.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/marks_detail_bottom_sheet.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/marks_viewmodel.dart';

class MarksPage extends ConsumerStatefulWidget {
  const MarksPage({super.key});

  @override
  ConsumerState<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends ConsumerState<MarksPage>
    with SingleTickerProviderStateMixin {
  DateTime? lastSynced;
  TabController? _tabController;
  List<String> _courseCategories = [];

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('MarksPage');
    loadLastSynced();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initTabController(List<String> categories) {
    if (_courseCategories.length != categories.length ||
        !_courseCategories.every((e) => categories.contains(e))) {
      _tabController?.dispose();
      _courseCategories = categories;
      _tabController = TabController(length: categories.length, vsync: this);
    }
  }

  Future<void> loadLastSynced() async {
    final prefs = ref.read(userPreferencesProvider);
    final DateTime? lastSyncedString = prefs.marksLastSync;
    if (lastSyncedString != null) {
      setState(() {
        lastSynced = lastSyncedString;
      });
    }
  }

  Future<void> saveLastSynced() async {
    final prefs = ref.read(userPreferencesProvider);
    await ref
        .read(userPreferencesProvider.notifier)
        .updatePreferences(prefs.copyWith(marksLastSync: lastSynced!));
  }

  Future<void> refreshMarksData() async {
    await ref.read(marksViewModelProvider.notifier).refreshMarks();
    await AnalyticsService.logEvent('refresh_marks');
    // Only stamp "last synced" when the refresh actually succeeded.
    final state = ref.read(marksViewModelProvider);
    if (state != null && !state.hasError) {
      lastSynced = DateTime.now();
      await saveLastSynced();
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = ref.watch(currentUserProvider);

    final isLoading = ref.watch(
      marksViewModelProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(marksViewModelProvider, (_, next) {
      next?.when(
        data: (data) {},
        loading: () {},
        error: (error, st) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });

    // Extract unique course categories from user marks
    final courseTypes = user?.marks.map((m) => m.courseType).toList() ?? [];
    final categories = CourseTypeHelper.getUniqueCourseCategories(courseTypes);

    // Initialize tab controller if categories changed
    if (categories.isNotEmpty) {
      _initTabController(categories);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Marks',
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
              refreshMarksData();
            },
            tooltip: 'Refresh',
          ),
        ],
        bottom: _tabController != null && _courseCategories.isNotEmpty
            ? DynamicCourseTypeTabBar(
                controller: _tabController!,
                courseTypes: _courseCategories,
              )
            : null,
      ),
      body: isLoading
          ? const Loader()
          : RefreshIndicator(
              onRefresh: refreshMarksData,
              notificationPredicate: (notification) => notification.depth == 1,
              child: _tabController != null && _courseCategories.isNotEmpty
                  ? TabBarView(
                      controller: _tabController,
                      children: _courseCategories
                          .map((category) => _buildBody(user, category))
                          .toList(),
                    )
                  : _buildBody(user, ''),
            ),
    );
  }

  Widget _buildBody(User? user, String courseTypeFilter) {
    if (user == null) {
      return const ErrorContentView(error: 'User not found!');
    }

    final marks = user.marks;

    // Filter marks based on course type category
    final filteredMarks = marks.where((mark) {
      if (courseTypeFilter.isEmpty) return true;
      return CourseTypeHelper.matchesCategory(
        mark.courseType,
        courseTypeFilter,
      );
    }).toList();

    if (filteredMarks.isEmpty) {
      return EmptyContentView(
        primaryText: 'No $courseTypeFilter Courses found',
        secondaryText: 'Keep calm and come back later! 🕒😌',
      );
    }

    return ListView.builder(
      itemCount: filteredMarks.length,
      itemBuilder: (context, index) {
        final course = filteredMarks[index];

        double totalWeightage = 0;
        double maxWeightage = 0;
        for (var detail in course.details) {
          totalWeightage += double.tryParse(detail.weightageMark) ?? 0;
          maxWeightage += double.tryParse(detail.weightage) ?? 0;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  course.courseTitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  course.faculty,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  course.courseCode,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: totalWeightage.toStringAsFixed(0),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '/',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: maxWeightage.toStringAsFixed(0),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              showMarksDetailBottomSheet(course, context);
            },
          ),
        );
      },
    );
  }
}
