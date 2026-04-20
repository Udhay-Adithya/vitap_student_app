import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/app_tab_bar.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/home/view/pages/outing/general_outing_tab.dart';
import 'package:vit_ap_student_app/features/home/view/pages/outing/weekend_outing_tab.dart';

class OutingPage extends ConsumerStatefulWidget {
  const OutingPage({super.key});

  @override
  ConsumerState<OutingPage> createState() => _OutingPageState();
}

class _OutingPageState extends ConsumerState<OutingPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    AnalyticsService.logScreen('OutingPage');

    // Track tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final tabNames = ['Weekend Outing', 'General Outing'];
        AnalyticsService.logEvent('outing_tab_changed', {
          'tab': tabNames[_tabController.index],
          'tab_index': _tabController.index,
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Outing',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          AppTabBar(
            controller: _tabController,
            tabs: const ['Weekend', 'General'],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TabBarView(
                controller: _tabController,
                children: const [WeekendOutingTab(), GeneralOutingTab()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
