import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/common/widget/course_type_tab_bar.dart';
import 'package:vit_ap_student_app/features/attendance/view/pages/attendance_page.dart';

Future<void> pumpTabBar(WidgetTester tester, List<String> tabs) async {
  await tester.pumpWidget(
    MaterialApp(
      home: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(bottom: CourseTypeTabBar(tabs: tabs)),
          body: TabBarView(
            children: [
              for (final tab in tabs) Center(child: Text('$tab body')),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('attendanceTabs', () {
    test('is just Theory and Lab without a capstone', () {
      expect(attendanceTabs(hasCapstone: false), ['Theory', 'Lab']);
    });

    test('adds a Capstone tab when the student has one', () {
      expect(attendanceTabs(hasCapstone: true), ['Theory', 'Lab', 'Capstone']);
    });

    test('keeps Capstone last so the course tabs never move', () {
      // The tab order is also the order of the TabBarView children; putting
      // Capstone anywhere but last would silently re-point the other tabs.
      expect(
        attendanceTabs(hasCapstone: true).take(2),
        attendanceTabs(hasCapstone: false),
      );
    });
  });

  group('CourseTypeTabBar', () {
    testWidgets('defaults to Theory and Lab', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(bottom: const CourseTypeTabBar()),
              body: const SizedBox(),
            ),
          ),
        ),
      );

      expect(find.text('Theory'), findsOneWidget);
      expect(find.text('Lab'), findsOneWidget);
      expect(find.text('Capstone'), findsNothing);
    });

    testWidgets('shows a Capstone tab that opens the capstone body', (
      tester,
    ) async {
      await pumpTabBar(tester, attendanceTabs(hasCapstone: true));

      expect(find.text('Capstone'), findsOneWidget);

      await tester.tap(find.text('Capstone'));
      await tester.pumpAndSettle();

      expect(find.text('Capstone body'), findsOneWidget);
    });

    testWidgets('a student without a capstone never sees the tab', (
      tester,
    ) async {
      await pumpTabBar(tester, attendanceTabs(hasCapstone: false));

      expect(find.text('Theory'), findsOneWidget);
      expect(find.text('Lab'), findsOneWidget);
      expect(find.text('Capstone'), findsNothing);
    });
  });
}
