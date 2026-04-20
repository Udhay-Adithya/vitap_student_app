import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/common/widget/app_tab_bar.dart';

/// A reusable tab bar widget for filtering between Theory and Lab courses
class CourseTypeTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;

  const CourseTypeTabBar({super.key, required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppTabBar(controller: controller, tabs: const ['Theory', 'Lab']);
  }
}
