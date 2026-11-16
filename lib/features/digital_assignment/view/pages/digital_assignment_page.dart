import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vit_ap_student_app/core/common/widget/empty_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
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
    ref.read(analyticsServiceProvider).logScreen('DigitalAssignmentPage');
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

  /// Rebuilds the tabs when the set of course categories changes.
  ///
  /// Called from a listener rather than from `build`, where it used to dispose
  /// the live controller and construct a replacement mid-frame — while the
  /// `TabBar` and `TabBarView` of that same frame still held the old one. The
  /// old controller is now released a frame later, once nothing references it.
  void _syncTabs(List<String> categories) {
    final bool unchanged =
        _courseCategories.length == categories.length &&
        _courseCategories.every(categories.contains);
    if (unchanged || categories.isEmpty) return;

    final TabController? previous = _tabController;
    setState(() {
      _courseCategories = categories;
      _tabController = TabController(length: categories.length, vsync: this);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => previous?.dispose());
  }

  List<String> _categoriesOf(List<DigitalAssignment> assignments) =>
      CourseTypeHelper.getUniqueCourseCategories(
        assignments.map((a) => a.courseType).toList(),
      );

  Future<void> _refreshData({bool silentRefresh = false}) async {
    ref.read(analyticsServiceProvider).logEvent(
      AnalyticsEvents.refreshInitiated,
      {AnalyticsParams.dataType: 'digital_assignment'},
    );
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

    // Failures surface in the body, which persists and explains, rather than
    // also as a snackbar that disappears — the page used to do both.
    ref.listen(digitalAssignmentViewModelProvider, (_, next) {
      next?.whenOrNull(data: (data) => _syncTabs(_categoriesOf(data)));
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
              'Digital Assignments',
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
        primaryText: 'No assignments loaded',
        secondaryText: 'Pull down to refresh',
      );
    }

    return asyncAssignments.when(
      data: (assignments) {
        // Filter assignments based on course type category
        final filtered = assignments.where((a) {
          if (courseTypeFilter.isEmpty) return true;
          return CourseTypeHelper.matchesCategory(
            a.courseType,
            courseTypeFilter,
          );
        }).toList();

        if (filtered.isEmpty) {
          return EmptyContentView(
            primaryText: courseTypeFilter.isEmpty
                ? 'No Digital Assignments'
                : 'No $courseTypeFilter Assignments',
            secondaryText: 'No assignments found for this semester 🎉',
          );
        }

        // The empty state promised pull-to-refresh that did not exist; now it
        // does, on the list as well.
        return RefreshIndicator(
          onRefresh: () => _refreshData(silentRefresh: true),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                AssignmentCourseCard(assignment: filtered[index]),
          ),
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
