import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/common/widget/app_tab_bar.dart';

/// A dynamic tab bar widget that handles all course types
/// Including: Theory, Lab, Project, and any other course types
class DynamicCourseTypeTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController controller;
  final List<String> courseTypes;

  const DynamicCourseTypeTabBar({
    super.key,
    required this.controller,
    required this.courseTypes,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppTabBar(
      controller: controller,
      tabs: courseTypes,
      isScrollable: courseTypes.length > 3,
    );
  }
}

/// Utility class to categorize and extract course types from marks data
class CourseTypeHelper {
  /// Standard course type categories
  static const String theory = 'Theory';
  static const String lab = 'Lab';
  static const String project = 'Project';

  /// Extracts the main category from a course type string
  /// Handles both full names (e.g., "Embedded Theory") and abbreviations (e.g., "ETH", "TH")
  static String getCourseCategory(String courseType) {
    final lowerCaseType = courseType.toLowerCase().trim();
    final upperCaseType = courseType.toUpperCase().trim();

    // Check abbreviated codes first
    if (upperCaseType == 'ETH' || upperCaseType == 'TH') {
      return theory;
    } else if (upperCaseType == 'ELA' || upperCaseType == 'LO') {
      return lab;
    } else if (upperCaseType == 'EPJ' || upperCaseType == 'PJ') {
      return project;
    }

    // Check full names
    if (lowerCaseType.contains('theory')) {
      return theory;
    } else if (lowerCaseType.contains('lab')) {
      return lab;
    } else if (lowerCaseType.contains('project')) {
      return project;
    }

    // Return the original type if no match found
    return courseType;
  }

  /// Gets unique course categories from a list of course types
  static List<String> getUniqueCourseCategories(List<String> courseTypes) {
    final Set<String> categories = {};

    for (final type in courseTypes) {
      categories.add(getCourseCategory(type));
    }

    // Return in a consistent order: Theory, Lab, Project, then others
    final orderedCategories = <String>[];

    if (categories.contains(theory)) {
      orderedCategories.add(theory);
      categories.remove(theory);
    }
    if (categories.contains(lab)) {
      orderedCategories.add(lab);
      categories.remove(lab);
    }
    if (categories.contains(project)) {
      orderedCategories.add(project);
      categories.remove(project);
    }

    // Add any remaining categories
    orderedCategories.addAll(categories.toList()..sort());

    return orderedCategories;
  }

  /// Checks if a course type belongs to a specific category
  static bool matchesCategory(String courseType, String category) {
    return getCourseCategory(courseType) == category;
  }
}
