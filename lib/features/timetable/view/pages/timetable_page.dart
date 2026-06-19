import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/core/common/widget/error_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/timetable/view/widgets/schedule_list.dart';
import 'package:vit_ap_student_app/features/timetable/viewmodel/timetable_viewmodel.dart';

class TimetablePage extends ConsumerStatefulWidget {
  const TimetablePage({super.key});

  @override
  ConsumerState<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends ConsumerState<TimetablePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final int currentDayIndex = DateTime.now().weekday % 7;
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: currentDayIndex,
    );

    // Analytics tracking
    AnalyticsService.logScreen('TimetablePage');
    AnalyticsService.logEvent('timetable_page_init', {
      'initial_day_index': currentDayIndex,
      'current_day': DateTime.now().weekday,
    });

    // Track tab changes for analytics
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final dayNames = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];
        AnalyticsService.logEvent('timetable_day_changed', {
          'day': dayNames[_tabController.index],
          'day_index': _tabController.index,
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getTodayClassesCount(Timetable? timetable) {
    final day = DateFormat('EEEE').format(DateTime.now());
    return (timetable?.toJson()[day] as List<dynamic>?)?.length ?? 0;
  }

  Future<void> refresh() async {
    await AnalyticsService.logEvent('timetable_refresh_initiated', {
      'timestamp': DateTime.now().toIso8601String(),
    });
    await ref.read(timetableViewModelProvider.notifier).refreshTimetable();
  }

  Widget _buildTab(String label) {
    return Container(
      height: 40,
      width: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Tab(child: Text(label, style: const TextStyle())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final timetable = user?.timetable;

    final isLoading = ref.watch(
      timetableViewModelProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(timetableViewModelProvider, (_, next) {
      next?.when(
        data: (data) {},
        loading: () {},
        error: (error, st) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });
    return Scaffold(
      body: user == null || timetable == null
          ? const ErrorContentView(error: 'User not found!')
          : RefreshIndicator(
              onRefresh: refresh,
              notificationPredicate: (notification) => notification.depth == 2,
              child: NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      automaticallyImplyLeading: true,
                      expandedHeight: 75,
                      centerTitle: false,
                      actions: [
                        IconButton(
                          icon: Icon(
                            Iconsax.refresh_copy,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            refresh();
                          },
                          tooltip: 'Refresh',
                        ),
                      ],
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Timetable',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _getTodayClassesCount(timetable.target) == 0
                                ? 'No classes today'
                                : 'You have ${_getTodayClassesCount(timetable.target)} classes Today',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: false,
                          dividerColor: Theme.of(context).colorScheme.surface,
                          labelPadding: const EdgeInsets.all(0),
                          splashBorderRadius: BorderRadius.circular(14),
                          labelStyle: const TextStyle(fontSize: 18),
                          unselectedLabelColor: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          labelColor: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          indicator: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          splashFactory: InkRipple.splashFactory,
                          overlayColor: WidgetStateColor.resolveWith(
                            (states) => Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                          ),
                          tabs: [
                            _buildTab('S'),
                            _buildTab('M'),
                            _buildTab('T'),
                            _buildTab('W'),
                            _buildTab('T'),
                            _buildTab('F'),
                            _buildTab('S'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: isLoading
                    ? const Loader()
                    : TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: const [
                          ScheduleList(day: 'Sunday'),
                          ScheduleList(day: 'Monday'),
                          ScheduleList(day: 'Tuesday'),
                          ScheduleList(day: 'Wednesday'),
                          ScheduleList(day: 'Thursday'),
                          ScheduleList(day: 'Friday'),
                          ScheduleList(day: 'Saturday'),
                        ],
                      ),
              ),
            ),
    );
  }
}
