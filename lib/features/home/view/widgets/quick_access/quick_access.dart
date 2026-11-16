import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/academic_calendar/view/pages/academic_calendar_page.dart';
import 'package:vit_ap_student_app/features/course_page/view/pages/course_page.dart';
import 'package:vit_ap_student_app/features/digital_assignment/view/pages/digital_assignment_page.dart';
import 'package:vit_ap_student_app/features/home/view/pages/biometric_page.dart';
import 'package:vit_ap_student_app/features/home/view/pages/exam_schedule_page.dart';
import 'package:vit_ap_student_app/features/home/view/pages/faculty_page.dart';
import 'package:vit_ap_student_app/features/home/view/pages/grade_history_page.dart';
import 'package:vit_ap_student_app/features/home/view/pages/marks_page.dart';
import 'package:vit_ap_student_app/features/home/view/pages/mentor_page.dart';
import 'package:vit_ap_student_app/features/home/view/pages/outing/outing_page.dart';
import 'package:vit_ap_student_app/features/home/view/pages/payments_page.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/quick_access/quick_access_icon.dart';
import 'package:vit_ap_student_app/features/vtop_webview/view/pages/vtop_webview_page.dart';

/// The Quick Access shortcut grid on the home page.
///
/// Lays out as a [Wrap] of fixed-width cells with
/// the column count derived from the available width. Two rows show while
/// collapsed; if the items do not all fit, the last visible cell becomes a
/// More control that springs the rest open in place.
class QuickAccess extends ConsumerStatefulWidget {
  const QuickAccess({super.key});

  @override
  ConsumerState<QuickAccess> createState() => _QuickAccessState();
}

class _QuickAccessState extends ConsumerState<QuickAccess> {
  /// Rows visible before the grid is expanded.
  static const int _collapsedRows = 2;

  /// Horizontal gap between cells. The vertical gap is larger so the rows read
  /// as rows rather than as an undifferentiated field of pills.
  static const double _spacing = 8;
  static const double _runSpacing = 2;

  bool _expanded = false;

  static const List<_QuickAccessItem> _items = <_QuickAccessItem>[
    _QuickAccessItem(
      icon: Iconsax.finger_scan_copy,
      label: 'Biometric',
      feature: 'biometric',
      builder: _biometricPage,
    ),
    _QuickAccessItem(
      icon: Iconsax.global_copy,
      label: 'VTOP',
      feature: 'vtop',
      builder: _vtopWebViewPage,
    ),
    _QuickAccessItem(
      icon: Iconsax.calendar_2_copy,
      label: 'Exams',
      feature: 'exams',
      builder: _examSchedulePage,
    ),
    _QuickAccessItem(
      icon: Iconsax.calendar_1_copy,
      label: 'Calendar',
      feature: 'academic_calendar',
      builder: _academicCalendarPage,
    ),
    _QuickAccessItem(
      icon: Iconsax.route_square_copy,
      label: 'Outing',
      feature: 'outing',
      builder: _outingPage,
    ),

    _QuickAccessItem(
      icon: Iconsax.document_upload_copy,
      label: 'Assignments',
      feature: 'digital_assignments',
      builder: _digitalAssignmentPage,
    ),
    _QuickAccessItem(
      icon: Iconsax.book_copy,
      label: 'Course Page',
      feature: 'course_page',
      builder: _coursePage,
    ),
    _QuickAccessItem(
      icon: Iconsax.receipt_item_copy,
      label: 'Payments',
      feature: 'payments',
      builder: _paymentsPage,
    ),
    _QuickAccessItem(
      icon: Iconsax.teacher_copy,
      label: 'Faculties',
      feature: 'faculties',
      builder: _facultiesPage,
    ),

    _QuickAccessItem(
      icon: Iconsax.chart_square_copy,
      label: 'Marks',
      feature: 'marks',
      builder: _marksPage,
    ),
    _QuickAccessItem(
      icon: Iconsax.graph_copy,
      label: 'Grades',
      feature: 'grades',
      builder: _gradeHistoryPage,
    ),
    _QuickAccessItem(
      icon: Iconsax.user_octagon_copy,
      label: 'Mentor',
      feature: 'mentor',
      builder: _mentorPage,
    ),
  ];

  static Widget _biometricPage(BuildContext _) => const BiometricPage();
  static Widget _marksPage(BuildContext _) => const MarksPage();
  static Widget _gradeHistoryPage(BuildContext _) => const GradeHistoryPage();
  static Widget _examSchedulePage(BuildContext _) => const ExamSchedulePage();
  static Widget _academicCalendarPage(BuildContext _) =>
      const AcademicCalendarPage();
  static Widget _outingPage(BuildContext _) => const OutingPage();
  static Widget _paymentsPage(BuildContext _) => const PaymentsPage();
  static Widget _digitalAssignmentPage(BuildContext _) =>
      const DigitalAssignmentPage();
  static Widget _coursePage(BuildContext _) => const CoursePage();
  static Widget _facultiesPage(BuildContext _) => const FacultiesPage();
  static Widget _mentorPage(BuildContext _) => const MentorPage();
  static Widget _vtopWebViewPage(BuildContext _) => const VtopWebViewPage();

  void _open(_QuickAccessItem item) {
    ref.read(analyticsServiceProvider).logEvent(
      AnalyticsEvents.quickAccessUsed,
      {AnalyticsParams.feature: item.feature},
    );

    final WidgetBuilder? builder = item.builder;
    if (builder == null) return;

    Navigator.push(context, MaterialPageRoute<void>(builder: builder));
  }

  void _toggleExpanded(int hiddenCount) {
    setState(() => _expanded = !_expanded);
    ref
        .read(analyticsServiceProvider)
        .logEvent(AnalyticsEvents.quickAccessUsed, {
          AnalyticsParams.feature: _expanded ? 'more_expand' : 'more_collapse',
          AnalyticsParams.count: hiddenCount,
        });
  }

  /// Largest column count whose cells stay at least [QuickAccessIcon.pillWidth]
  /// wide. Clamped so a very narrow phone still gets a grid and a tablet does
  /// not stretch the cells into a single thin line.
  int _columnsFor(double maxWidth) {
    const double minCell = QuickAccessIcon.pillWidth;
    final int fits = ((maxWidth + _spacing) / (minCell + _spacing)).floor();
    return fits.clamp(3, 6);
  }

  @override
  Widget build(BuildContext context) {
    // No gutter of its own — the home page supplies one, and this widget having
    // a second, narrower one is why the grid used to sit 8pt wider than the
    // "Quick Access" heading above it.
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = _columnsFor(constraints.maxWidth);
        final double cellWidth =
            (constraints.maxWidth - _spacing * (columns - 1)) / columns;

        final int capacity = columns * _collapsedRows;
        // A More cell is only worth its slot when it actually reveals
        // something; when everything fits, the grid is just the grid.
        final bool needsToggle = _items.length > capacity;
        final int collapsedCount = needsToggle ? capacity - 1 : _items.length;
        final int visibleCount = _expanded ? _items.length : collapsedCount;

        return AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubicEmphasized,
          alignment: Alignment.topCenter,
          child: Wrap(
            spacing: _spacing,
            runSpacing: _runSpacing,
            children: <Widget>[
              for (final item in _items.take(visibleCount))
                QuickAccessIcon(
                  width: cellWidth,
                  icon: item.icon,
                  text: item.label,
                  onPressed: () => _open(item),
                ),
              if (needsToggle)
                QuickAccessIcon(
                  width: cellWidth,
                  icon: Iconsax.arrow_down_1_copy,
                  text: _expanded ? 'Less' : 'More',
                  emphasized: true,
                  iconTurns: _expanded ? 0.5 : 0,
                  onPressed: () =>
                      _toggleExpanded(_items.length - collapsedCount),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A single Quick Access destination.
///
/// [feature] is the analytics key and must stay stable — it is the value
/// reported under [AnalyticsParams.feature], so renaming the label is free but
/// renaming this splits the metric.
class _QuickAccessItem {
  const _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.feature,
    required this.builder,
  });

  final IconData icon;
  final String label;
  final String feature;

  /// Page to push, or null for a destination that isn't built yet.
  final WidgetBuilder? builder;
}
