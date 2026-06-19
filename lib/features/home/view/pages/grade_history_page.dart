import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/common/widget/empty_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/error_content_view.dart';
import 'package:vit_ap_student_app/core/models/grade_history.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/grade_utils.dart';
import 'package:vit_ap_student_app/core/utils/open_cgpa_calculator.dart';
import 'package:vit_ap_student_app/core/utils/share_utils.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/grade_card.dart';

class GradeHistoryPage extends ConsumerStatefulWidget {
  const GradeHistoryPage({super.key});

  @override
  ConsumerState<GradeHistoryPage> createState() => _GradeHistoryPageState();
}

class _GradeHistoryPageState extends ConsumerState<GradeHistoryPage> {
  String selectedFilter = 'All';
  String searchQuery = '';
  bool showFilters = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('GradeHistoryPage');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getUniqueExamMonths(GradeHistory gradeHistory) {
    final months = gradeHistory.courses
        .map((course) => course.examMonth)
        .toSet()
        .toList();
    months.sort();
    return ['All', ...months];
  }

  List<Course> _getFilteredCourses(GradeHistory gradeHistory) {
    List<Course> courses = gradeHistory.courses.toList();

    // Apply month filter
    if (selectedFilter != 'All') {
      courses = courses
          .where((course) => course.examMonth == selectedFilter)
          .toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      courses = courses
          .where(
            (course) =>
                course.courseTitle.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                course.courseCode.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                course.grade.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                course.examMonth.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return courses;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final gradeHistory = user?.profile.target?.gradeHistory.target;

    return Scaffold(
      floatingActionButton:
          (gradeHistory != null && gradeHistory.courses.isNotEmpty)
          ? FloatingActionButton.extended(
              onPressed: () {
                try {
                  openCgpaCalculator(gradeHistory);
                } catch (e) {
                  if (mounted) {
                    showSnackBar(
                      context,
                      'Failed to open CGPA calculator',
                      SnackBarType.error,
                    );
                  }
                }
              },
              icon: const Icon(Iconsax.calculator_copy),
              label: const Text('Calculate CGPA'),
              tooltip: 'Calculate CGPA using external tool',
              backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: true,
            expandedHeight: 75,
            centerTitle: false,
            actions: (gradeHistory != null && gradeHistory.courses.isNotEmpty)
                ? [
                    IconButton(
                      onPressed: () async {
                        try {
                          final cgpaUrl = generateCgpaCalculatorUrl(
                            gradeHistory,
                          );
                          await ShareUtils.instance.shareCgpaCalculator(
                            cgpaUrl,
                            context,
                          );
                          await AnalyticsService.logEvent(
                            'cgpa_calculator_shared',
                            {
                              'from': 'GradeHistoryPage',
                              'timestamp': DateTime.now().toIso8601String(),
                            },
                          );
                        } catch (e) {
                          if (mounted) {
                            showSnackBar(
                              context,
                              'Failed to share CGPA calculator',
                              SnackBarType.error,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.share_rounded),
                      tooltip: 'Share CGPA Calculator',
                    ),
                  ]
                : null,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grade History',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (gradeHistory != null && gradeHistory.courses.isNotEmpty)
                  Text(
                    '${_getFilteredCourses(gradeHistory).length} courses',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
          if (user == null)
            const SliverFillRemaining(
              child: ErrorContentView(error: 'User not found!'),
            )
          else if (gradeHistory == null || gradeHistory.courses.isEmpty)
            const SliverFillRemaining(
              child: EmptyContentView(
                primaryText: 'No grades available',
                secondaryText:
                    'Your grade history will appear here once available.',
              ),
            )
          else ...[
            // Search bar with filter button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search courses...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () {
                        setState(() {
                          showFilters = !showFilters;
                        });
                      },
                      icon: Icon(
                        showFilters ? Icons.filter_list_off : Icons.filter_list,
                        color: showFilters
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Filter chips (conditional)
            if (showFilters)
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _getUniqueExamMonths(gradeHistory).length,
                    itemBuilder: (context, index) {
                      final filter = _getUniqueExamMonths(gradeHistory)[index];
                      final isSelected = selectedFilter == filter;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            // Course list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final courses = _getFilteredCourses(gradeHistory);
                    if (courses.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No courses found',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filter criteria',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    final course = courses[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: GradeCard(
                        course: course,
                        gradeColor: getGradeColor(course.grade),
                      ),
                    );
                  },
                  childCount: _getFilteredCourses(gradeHistory).isEmpty
                      ? 1
                      : _getFilteredCourses(gradeHistory).length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
