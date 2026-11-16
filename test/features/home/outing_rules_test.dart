import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/features/home/utils/outing_rules.dart';

/// 2026-08-09 is a Sunday, so 08-10 is the Monday after it and 08-07/08-08 are
/// the Friday and Saturday that carry their deadlines.
final DateTime sunday = DateTime(2026, 8, 9);
final DateTime monday = DateTime(2026, 8, 10);

void main() {
  group('isOutingTimeAllowed', () {
    test('accepts the window and its boundaries', () {
      expect(isOutingTimeAllowed(const TimeOfDay(hour: 6, minute: 0)), isTrue);
      expect(
        isOutingTimeAllowed(const TimeOfDay(hour: 13, minute: 30)),
        isTrue,
      );
      expect(isOutingTimeAllowed(const TimeOfDay(hour: 22, minute: 0)), isTrue);
    });

    test('rejects outside the window', () {
      expect(
        isOutingTimeAllowed(const TimeOfDay(hour: 5, minute: 59)),
        isFalse,
      );
      expect(
        isOutingTimeAllowed(const TimeOfDay(hour: 22, minute: 1)),
        isFalse,
      );
      expect(isOutingTimeAllowed(const TimeOfDay(hour: 0, minute: 0)), isFalse);
    });
  });

  group('weekendOutingDeadline', () {
    test('closes two days before, at the end of that day', () {
      expect(weekendOutingDeadline(sunday), DateTime(2026, 8, 7, 23, 59, 59));
      expect(weekendOutingDeadline(monday), DateTime(2026, 8, 8, 23, 59, 59));
    });

    test('is null for a day that is not an outing day', () {
      expect(weekendOutingDeadline(DateTime(2026, 8, 11)), isNull);
    });
  });

  group('isWeekendOutingOpen', () {
    test('is open right up to the deadline', () {
      expect(
        isWeekendOutingOpen(sunday, now: DateTime(2026, 8, 7, 23, 59, 59)),
        isTrue,
      );
      expect(isWeekendOutingOpen(sunday, now: DateTime(2026, 8, 5, 9)), isTrue);
    });

    test('is closed once the deadline passes', () {
      expect(
        isWeekendOutingOpen(sunday, now: DateTime(2026, 8, 8, 0, 0, 1)),
        isFalse,
      );
    });

    // Regression: the old rule compared against a computed "upcoming" day and
    // returned "not passed" for anything that did not match it, so applying for
    // today's Monday outing bypassed the Saturday deadline entirely.
    test('is closed for an outing today, on the day itself', () {
      expect(isWeekendOutingOpen(monday, now: monday), isFalse);
      expect(isWeekendOutingOpen(sunday, now: sunday), isFalse);
    });

    test('is closed for a day that is not an outing day', () {
      expect(
        isWeekendOutingOpen(DateTime(2026, 8, 11), now: DateTime(2026, 8, 5)),
        isFalse,
      );
    });
  });

  group('isSelectableWeekendOutingDate', () {
    test('offers only Sundays and Mondays that are still open', () {
      final DateTime now = DateTime(2026, 8, 5, 12);
      expect(isSelectableWeekendOutingDate(sunday, now: now), isTrue);
      expect(isSelectableWeekendOutingDate(monday, now: now), isTrue);
      expect(
        isSelectableWeekendOutingDate(DateTime(2026, 8, 11), now: now),
        isFalse,
      );
    });

    test('bypass lifts the deadline but not the weekday rule', () {
      expect(
        isSelectableWeekendOutingDate(monday, now: monday, bypass: true),
        isTrue,
      );
      expect(
        isSelectableWeekendOutingDate(
          DateTime(2026, 8, 11),
          now: monday,
          bypass: true,
        ),
        isFalse,
      );
    });
  });

  group('isWeekendOutingFormOpen', () {
    // VTOP only renders the form Tue 00:00 → Sat 23:59; outside that it returns
    // the page without the student fields at all.
    test('is open Tuesday through Saturday', () {
      expect(isWeekendOutingFormOpen(now: DateTime(2026, 8, 4)), isTrue);
      expect(isWeekendOutingFormOpen(now: DateTime(2026, 8, 5)), isTrue);
      expect(isWeekendOutingFormOpen(now: DateTime(2026, 8, 6)), isTrue);
      expect(isWeekendOutingFormOpen(now: DateTime(2026, 8, 7)), isTrue);
      expect(
        isWeekendOutingFormOpen(now: DateTime(2026, 8, 8, 23, 59)),
        isTrue,
      );
    });

    test('is closed on Sunday and Monday', () {
      expect(isWeekendOutingFormOpen(now: sunday), isFalse);
      expect(isWeekendOutingFormOpen(now: monday), isFalse);
    });

    // Saturday has to be open or a Monday outing could never be applied for on
    // its own deadline day.
    test('covers the Saturday deadline for a Monday outing', () {
      final DateTime saturday = DateTime(2026, 8, 8, 20);
      expect(isWeekendOutingFormOpen(now: saturday), isTrue);
      expect(isWeekendOutingOpen(monday, now: saturday), isTrue);
    });
  });

  group('nextWeekendOutingFormOpening', () {
    test('points at the coming Tuesday', () {
      expect(
        nextWeekendOutingFormOpening(now: DateTime(2026, 8, 8, 14)),
        DateTime(2026, 8, 11),
      );
      expect(nextWeekendOutingFormOpening(now: monday), DateTime(2026, 8, 11));
    });

    test('skips to next week when already Tuesday', () {
      expect(
        nextWeekendOutingFormOpening(now: DateTime(2026, 8, 4, 9)),
        DateTime(2026, 8, 11),
      );
    });
  });

  group('validateOutingSpan', () {
    test('accepts a return after the departure', () {
      expect(
        validateOutingSpan(
          fromDate: sunday,
          fromTime: '09:00',
          toDate: sunday,
          toTime: '18:00',
        ),
        isNull,
      );
      expect(
        validateOutingSpan(
          fromDate: sunday,
          fromTime: '20:00',
          toDate: monday,
          toTime: '08:00',
        ),
        isNull,
      );
    });

    // Regression: nothing related the two halves, so this submitted happily and
    // was only rejected by VTOP a round trip later.
    test('rejects a return before the departure', () {
      expect(
        validateOutingSpan(
          fromDate: monday,
          fromTime: '09:00',
          toDate: sunday,
          toTime: '18:00',
        ),
        isNotNull,
      );
    });

    test('rejects a return at the same moment as the departure', () {
      expect(
        validateOutingSpan(
          fromDate: sunday,
          fromTime: '09:00',
          toDate: sunday,
          toTime: '09:00',
        ),
        isNotNull,
      );
    });

    test('stays quiet while the form is still incomplete', () {
      expect(
        validateOutingSpan(
          fromDate: sunday,
          fromTime: null,
          toDate: null,
          toTime: null,
        ),
        isNull,
      );
    });
  });
}
