import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vit_ap_student_app/core/common/widget/empty_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/features/digital_assignment/view/widgets/assignment_course_card.dart';
import 'package:vit_ap_student_app/features/digital_assignment/viewmodel/digital_assignment_viewmodel.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/marks/dynamic_course_type_tab_bar.dart';

class DigitalAssignmentPage extends ConsumerStatefulWidget {
  const DigitalAssignmentPage({super.key});

  @override
  ConsumerState<DigitalAssignmentPage> createState() =>
      _DigitalAssignmentPageState();
}

class _DigitalAssignmentPageState extends ConsumerState<DigitalAssignmentPage>
    with SingleTickerProviderStateMixin {
  DateTime? lastSynced;
  TabController? _tabController;
  List<String> _courseCategories = [];

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('DigitalAssignmentPage');
    // Auto-fetch on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData(silentRefresh: false);
    });
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

  Future<void> _refreshData({bool silentRefresh = false}) async {
    await AnalyticsService.logEvent('digital_assignment_refresh_initiated', {
      'timestamp': DateTime.now().toIso8601String(),
    });
    await ref
        .read(digitalAssignmentViewModelProvider.notifier)
        .refreshDigitalAssignments(silentRefresh: silentRefresh);
    // Only stamp "last synced" when the refresh actually succeeded.
    final state = ref.read(digitalAssignmentViewModelProvider);
    if (state != null && !state.hasError) {
      setState(() {
        lastSynced = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncAssignments = ref.watch(digitalAssignmentViewModelProvider);
    final isLoading = asyncAssignments?.isLoading == true;

    ref.listen(
      digitalAssignmentViewModelProvider,
      (_, next) {
        next?.when(
          data: (data) {},
          loading: () {},
          error: (error, st) {
            showSnackBar(
              context,
              error.toString(),
              SnackBarType.error,
            );
          },
        );
      },
    );

    // Extract unique course categories from the fetched assignments
    List<String> categories = [];
    if (asyncAssignments != null && asyncAssignments.hasValue) {
      final assignments = asyncAssignments.value ?? [];
      final courseTypes = assignments.map((a) => a.courseType).toList();
      categories = CourseTypeHelper.getUniqueCourseCategories(courseTypes);
      if (categories.isNotEmpty) {
        _initTabController(categories);
      }
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
              'Digital Assignments',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w500),
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
              _refreshData();
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
          : _tabController != null && _courseCategories.isNotEmpty
              ? TabBarView(
                  controller: _tabController,
                  children: _courseCategories
                      .map((category) => _buildBody(asyncAssignments, category))
                      .toList(),
                )
              : _buildBody(asyncAssignments, ''),
    );
  }

  Widget _buildBody(
    AsyncValue<List<DigitalAssignment>>? asyncAssignments,
    String courseTypeFilter,
  ) {
    if (asyncAssignments == null) {
      return const EmptyContentView(
        primaryText: 'No Assignments loaded',
        secondaryText: 'Pull to refresh or tap refresh button',
      );
    }

    return asyncAssignments.when(
      data: (assignments) {
        // Filter assignments based on course type category
        final filtered = assignments.where((a) {
          if (courseTypeFilter.isEmpty) return true;
          return CourseTypeHelper.matchesCategory(
              a.courseType, courseTypeFilter);
        }).toList();

        if (filtered.isEmpty) {
          return EmptyContentView(
            primaryText: courseTypeFilter.isEmpty
                ? 'No Digital Assignments'
                : 'No $courseTypeFilter Assignments',
            secondaryText: 'No assignments found for this semester 🎉',
          );
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final assignment = filtered[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: AssignmentCourseCard(assignment: assignment),
            );
          },
        );
      },
      loading: () => const Loader(),
      error: (error, _) => EmptyContentView(
        primaryText: 'Failed to load assignments',
        secondaryText: error.toString(),
      ),
    );
  }
}
