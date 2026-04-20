import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/common/widget/app_tab_bar.dart';

class ExamScheduleTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController tabController;

  const ExamScheduleTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return AppTabBar(
      controller: tabController,
      tabs: const ['CAT - 1', 'CAT - 2', 'FAT'],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
