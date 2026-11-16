import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/upcoming_classes/class_occurrence.dart';

/// 2026-08-03 is a Monday, so the weekday lookup in [classesOn] is deterministic.
final DateTime monday = DateTime(2026, 8, 3);

Map<String, dynamic> slot(
  String start,
  String end,
  String name, {
  String venue = 'AB-1',
}) => <String, dynamic>{
  'start_time': start,
  'end_time': end,
  'course_name': name,
  'slot': 'A1',
  'venue': venue,
  'faculty': 'Some Faculty',
  'course_code': 'CSE1001',
  'course_type': 'ETH',
};

Timetable timetableWith({
  List<Map<String, dynamic>> monday = const <Map<String, dynamic>>[],
}) => Timetable.fromJson(<String, dynamic>{
  'Monday': monday,
  'Tuesday': const <Map<String, dynamic>>[],
  'Wednesday': const <Map<String, dynamic>>[],
  'Thursday': const <Map<String, dynamic>>[],
  'Friday': const <Map<String, dynamic>>[],
  'Saturday': const <Map<String, dynamic>>[],
  'Sunday': const <Map<String, dynamic>>[],
});

ClassOccurrence occurrence(String start, String end) =>
    ClassOccurrence.on(monday, Day.fromJson(slot(start, end, 'NoSQL')));

void main() {
  group('ClassOccurrence.phaseAt', () {
    final ClassOccurrence tenToEleven = occurrence('10:00', '11:00');

    test('is upcoming before the start time', () {
      expect(
        tenToEleven.phaseAt(DateTime(2026, 8, 3, 9, 59)),
        ClassPhase.upcoming,
      );
    });

    test('is ongoing between start and end', () {
      expect(
        tenToEleven.phaseAt(DateTime(2026, 8, 3, 10, 30)),
        ClassPhase.ongoing,
      );
    });

    test('is ongoing exactly on the boundaries', () {
      expect(tenToEleven.phaseAt(DateTime(2026, 8, 3, 10)), ClassPhase.ongoing);
      expect(tenToEleven.phaseAt(DateTime(2026, 8, 3, 11)), ClassPhase.ongoing);
    });

    test('is completed after the end time', () {
      expect(
        tenToEleven.phaseAt(DateTime(2026, 8, 3, 11, 1)),
        ClassPhase.completed,
      );
    });

    // A slot VTOP gave no usable time for must not be treated as finished — it
    // would collapse into the "done earlier" group where nobody would find it.
    test('treats an unparseable slot as upcoming, never completed', () {
      final ClassOccurrence unknown = occurrence('-', '-');
      expect(unknown.phaseAt(DateTime(2026, 8, 3, 23)), ClassPhase.upcoming);
    });
  });

  group('ClassOccurrence durations', () {
    final ClassOccurrence tenToEleven = occurrence('10:00', '11:00');

    test('remainingAt counts down and clamps at zero', () {
      expect(
        tenToEleven.remainingAt(DateTime(2026, 8, 3, 10, 38)),
        const Duration(minutes: 22),
      );
      expect(tenToEleven.remainingAt(DateTime(2026, 8, 3, 14)), Duration.zero);
    });

    test('startsInAt counts down and clamps at zero', () {
      expect(
        tenToEleven.startsInAt(DateTime(2026, 8, 3, 9, 15)),
        const Duration(minutes: 45),
      );
      expect(
        tenToEleven.startsInAt(DateTime(2026, 8, 3, 10, 30)),
        Duration.zero,
      );
    });

    test('progressAt reports the fraction elapsed, clamped to 0..1', () {
      expect(tenToEleven.progressAt(DateTime(2026, 8, 3, 10, 30)), 0.5);
      expect(tenToEleven.progressAt(DateTime(2026, 8, 3, 9)), 0.0);
      expect(tenToEleven.progressAt(DateTime(2026, 8, 3, 13)), 1.0);
    });

    test('progressAt is null when the slot has no usable time', () {
      expect(occurrence('-', '-').progressAt(DateTime(2026, 8, 3, 10)), isNull);
    });
  });

  group('classesOn', () {
    // The stored timetable keeps VTOP's row order, not chronological order, so
    // the stack depends on this sort to read top-to-bottom as a day.
    test('orders a day chronologically regardless of stored order', () {
      final Timetable timetable = timetableWith(
        monday: <Map<String, dynamic>>[
          slot('15:00', '15:50', 'Late'),
          slot('08:00', '08:50', 'Early'),
          slot('11:00', '11:50', 'Middle'),
        ],
      );

      expect(
        classesOn(
          timetable,
          monday,
        ).map((ClassOccurrence c) => c.info.courseName).toList(),
        <String>['Early', 'Middle', 'Late'],
      );
    });

    test('sorts slots with no usable time last', () {
      final Timetable timetable = timetableWith(
        monday: <Map<String, dynamic>>[
          slot('-', '-', 'Unknown'),
          slot('09:00', '09:50', 'Known'),
        ],
      );

      expect(
        classesOn(
          timetable,
          monday,
        ).map((ClassOccurrence c) => c.info.courseName).toList(),
        <String>['Known', 'Unknown'],
      );
    });

    test('returns an empty list for a day with nothing scheduled', () {
      expect(classesOn(timetableWith(), monday), isEmpty);
    });
  });

  group('formatShortDuration', () {
    test('formats minutes, hours and both', () {
      expect(formatShortDuration(const Duration(minutes: 45)), '45m');
      expect(formatShortDuration(const Duration(hours: 1)), '1h');
      expect(
        formatShortDuration(const Duration(hours: 2, minutes: 15)),
        '2h 15m',
      );
    });

    test('collapses sub-minute durations', () {
      expect(formatShortDuration(const Duration(seconds: 20)), '<1m');
    });
  });
}
