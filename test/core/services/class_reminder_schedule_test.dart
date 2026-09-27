import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/services/class_reminder_schedule.dart';
import 'package:vit_ap_student_app/features/academic_calendar/model/non_instructional_days.dart';

/// A Monday, well before any class time so nothing is filtered as past.
final _monday = DateTime(2026, 9, 7, 6, 0);

List<DateTime> _dates(List<ClassReminderOccurrence> occurrences) =>
    occurrences
        .map((o) => DateTime(o.classStart.year, o.classStart.month, o.classStart.day))
        .toList();

void main() {
  group('classReminderOccurrences', () {
    test('schedules one occurrence per week across the horizon', () {
      final occurrences = classReminderOccurrences(
        from: _monday,
        weekday: DateTime.monday,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        delayMinutes: 15,
        horizonWeeks: 4,
      );

      expect(occurrences, hasLength(4));
      expect(_dates(occurrences), [
        DateTime(2026, 9, 7),
        DateTime(2026, 9, 14),
        DateTime(2026, 9, 21),
        DateTime(2026, 9, 28),
      ]);
    });

    test('fires the reminder the configured number of minutes early', () {
      final occurrences = classReminderOccurrences(
        from: _monday,
        weekday: DateTime.monday,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        delayMinutes: 15,
        horizonWeeks: 1,
      );

      expect(occurrences.single.classStart, DateTime(2026, 9, 7, 9, 0));
      expect(occurrences.single.notifyAt, DateTime(2026, 9, 7, 8, 45));
    });

    test('finds the next matching weekday when today is a different day', () {
      // From Monday, the Thursday class is three days out.
      final occurrences = classReminderOccurrences(
        from: _monday,
        weekday: DateTime.thursday,
        startTime: const TimeOfDay(hour: 11, minute: 0),
        delayMinutes: 10,
        horizonWeeks: 2,
      );

      expect(_dates(occurrences), [DateTime(2026, 9, 10), DateTime(2026, 9, 17)]);
    });

    // The whole point of the change: a repeating weekly alarm cannot skip a
    // single week, so each occurrence is scheduled on its own and the holiday
    // is simply left out.
    test('skips a week whose date is a holiday', () {
      final holidays = NonInstructionalDays.fromDates({
        DateTime(2026, 9, 14): 'Independence Day',
      });

      final occurrences = classReminderOccurrences(
        from: _monday,
        weekday: DateTime.monday,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        delayMinutes: 15,
        nonInstructionalDays: holidays,
        horizonWeeks: 4,
      );

      expect(_dates(occurrences), [
        DateTime(2026, 9, 7),
        DateTime(2026, 9, 21),
        DateTime(2026, 9, 28),
      ]);
    });

    test('skips every holiday, not just the first', () {
      final holidays = NonInstructionalDays.fromDates({
        DateTime(2026, 9, 7): 'Holiday',
        DateTime(2026, 9, 21): 'Holiday',
      });

      final occurrences = classReminderOccurrences(
        from: _monday,
        weekday: DateTime.monday,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        delayMinutes: 15,
        nonInstructionalDays: holidays,
        horizonWeeks: 4,
      );

      expect(_dates(occurrences), [DateTime(2026, 9, 14), DateTime(2026, 9, 28)]);
    });

    test('returns nothing when every week in the horizon is a holiday', () {
      final holidays = NonInstructionalDays.fromDates({
        for (var week = 0; week < 4; week++)
          DateTime(2026, 9, 7 + week * 7): 'Holiday',
      });

      expect(
        classReminderOccurrences(
          from: _monday,
          weekday: DateTime.monday,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          delayMinutes: 15,
          nonInstructionalDays: holidays,
          horizonWeeks: 4,
        ),
        isEmpty,
      );
    });

    test('with no calendar read, nothing is suppressed', () {
      final occurrences = classReminderOccurrences(
        from: _monday,
        weekday: DateTime.monday,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        delayMinutes: 15,
        horizonWeeks: 4,
      );

      expect(occurrences, hasLength(4));
    });

    // Scheduling something for the past either fires at once or is dropped, so
    // today's class is only included if its reminder has not already gone.
    test("drops today's occurrence once the reminder time has passed", () {
      final afterTheReminder = DateTime(2026, 9, 7, 8, 50);

      final occurrences = classReminderOccurrences(
        from: afterTheReminder,
        weekday: DateTime.monday,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        delayMinutes: 15,
        horizonWeeks: 2,
      );

      expect(_dates(occurrences), [DateTime(2026, 9, 14)]);
    });

    test("keeps today's occurrence when the reminder is still ahead", () {
      final beforeTheReminder = DateTime(2026, 9, 7, 8, 40);

      final occurrences = classReminderOccurrences(
        from: beforeTheReminder,
        weekday: DateTime.monday,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        delayMinutes: 15,
        horizonWeeks: 1,
      );

      expect(_dates(occurrences), [DateTime(2026, 9, 7)]);
    });

    test('a reminder delay that crosses midnight lands on the previous day', () {
      final occurrences = classReminderOccurrences(
        from: DateTime(2026, 9, 6),
        weekday: DateTime.monday,
        startTime: const TimeOfDay(hour: 0, minute: 30),
        delayMinutes: 60,
        horizonWeeks: 1,
      );

      expect(occurrences.single.notifyAt, DateTime(2026, 9, 6, 23, 30));
    });

    test('crossing a month boundary keeps a weekly cadence', () {
      final occurrences = classReminderOccurrences(
        from: DateTime(2026, 9, 28, 6, 0),
        weekday: DateTime.monday,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        delayMinutes: 15,
        horizonWeeks: 3,
      );

      expect(_dates(occurrences), [
        DateTime(2026, 9, 28),
        DateTime(2026, 10, 5),
        DateTime(2026, 10, 12),
      ]);
    });

    test('rejects a weekday outside 1..7 rather than scheduling nonsense', () {
      for (final weekday in [0, 8, -1]) {
        expect(
          classReminderOccurrences(
            from: _monday,
            weekday: weekday,
            startTime: const TimeOfDay(hour: 9, minute: 0),
            delayMinutes: 15,
          ),
          isEmpty,
          reason: 'weekday $weekday should produce nothing',
        );
      }
    });

    test('a non-positive horizon produces nothing', () {
      expect(
        classReminderOccurrences(
          from: _monday,
          weekday: DateTime.monday,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          delayMinutes: 15,
          horizonWeeks: 0,
        ),
        isEmpty,
      );
    });
  });

  group('classReminderNotificationId', () {
    test('is stable for the same slot and occurrence', () {
      int idFor() => classReminderNotificationId(
        slotId: 42,
        classStart: DateTime(2026, 9, 7, 9, 0),
      );

      expect(idFor(), idFor());
    });

    // Every occurrence used to share one id, which is what made a per-day
    // reminder impossible to replace independently.
    test('differs between two occurrences of the same class', () {
      expect(
        classReminderNotificationId(slotId: 42, classStart: DateTime(2026, 9, 7, 9, 0)),
        isNot(
          classReminderNotificationId(slotId: 42, classStart: DateTime(2026, 9, 14, 9, 0)),
        ),
      );
    });

    test('differs between two classes on the same day', () {
      expect(
        classReminderNotificationId(slotId: 1, classStart: DateTime(2026, 9, 7, 9, 0)),
        isNot(
          classReminderNotificationId(slotId: 2, classStart: DateTime(2026, 9, 7, 9, 0)),
        ),
      );
    });

    test('differs between two classes at different times on one day', () {
      expect(
        classReminderNotificationId(slotId: 1, classStart: DateTime(2026, 9, 7, 9, 0)),
        isNot(
          classReminderNotificationId(slotId: 1, classStart: DateTime(2026, 9, 7, 11, 0)),
        ),
      );
    });

    // Android notification ids are 32-bit signed ints.
    test('stays inside a positive 32-bit int', () {
      final id = classReminderNotificationId(
        slotId: -98765432,
        classStart: DateTime(2026, 12, 31, 23, 59),
      );

      expect(id, greaterThanOrEqualTo(0));
      expect(id, lessThanOrEqualTo(0x7fffffff));
    });
  });
}
