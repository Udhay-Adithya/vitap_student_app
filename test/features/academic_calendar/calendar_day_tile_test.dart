import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:objectbox/objectbox.dart';
import 'package:vit_ap_student_app/core/models/academic_calendar.dart';
import 'package:vit_ap_student_app/features/academic_calendar/view/widgets/calendar_day_tile.dart';

CalendarDay day({
  required List<CalendarEvent> events,
  String date = '2026-08-15',
  int number = 15,
  String weekday = 'SATURDAY',
}) => CalendarDay(
  date: date,
  day: number,
  weekday: weekday,
  events: ToMany<CalendarEvent>(items: [...events]),
);

CalendarEvent event(String description, String label) =>
    CalendarEvent(description: description, label: label);

Future<void> pumpTile(WidgetTester tester, CalendarDay value) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: CalendarDayTile(day: value)),
    ),
  );
}

void main() {
  testWidgets('shows an exam by name, not by its generic label', (
    tester,
  ) async {
    await pumpTile(
      tester,
      day(events: [event('CAT - I - General (Semester)', 'Exam Days')]),
    );

    // "CAT - I" is the thing worth seeing; "Exam Days" is on every exam day.
    expect(find.text('CAT - I'), findsOneWidget);
    expect(find.text('Exam Days'), findsNothing);
  });

  testWidgets('names a named holiday', (tester) async {
    await pumpTile(
      tester,
      day(events: [event('Holiday - General (Semester)', 'Independence Day')]),
    );

    expect(find.text('Independence Day'), findsOneWidget);
  });

  testWidgets('never shows the class group suffix', (tester) async {
    await pumpTile(
      tester,
      day(
        events: [event('Instructional Day - General (Semester)', 'WorkingDay')],
      ),
    );

    expect(find.text('Instructional Day'), findsOneWidget);
    expect(find.textContaining('General (Semester)'), findsNothing);
  });

  testWidgets('shows the day number and a short weekday', (tester) async {
    await pumpTile(
      tester,
      day(events: [event('Holiday - General (Semester)', 'Holiday')]),
    );

    expect(find.text('15'), findsOneWidget);
    // VTOP shouts "SATURDAY"; the column has room for three letters.
    expect(find.text('Sat'), findsOneWidget);
  });

  testWidgets('says so when VTOP listed nothing for a day', (tester) async {
    await pumpTile(tester, day(events: []));

    expect(find.text('Nothing listed'), findsOneWidget);
  });

  testWidgets('shows every entry on a day that has more than one', (
    tester,
  ) async {
    await pumpTile(
      tester,
      day(
        events: [
          event('Instructional Day - General (Semester)', 'WorkingDay'),
          event('CAT - I - General (Semester)', 'Exam Days'),
        ],
      ),
    );

    expect(find.text('Instructional Day'), findsOneWidget);
    expect(find.text('CAT - I'), findsOneWidget);
  });
}
