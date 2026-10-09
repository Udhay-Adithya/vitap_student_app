import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/utils/weekday_date.dart';

void main() {
  group('dateForWeekdayInWeekOf', () {
    // 2026-09-10 is a Thursday.
    final thursday = DateTime(2026, 9, 10, 14, 30);

    test('resolves every weekday in the week containing the given date', () {
      expect(dateForWeekdayInWeekOf('Monday', thursday), DateTime(2026, 9, 7));
      expect(dateForWeekdayInWeekOf('Tuesday', thursday), DateTime(2026, 9, 8));
      expect(dateForWeekdayInWeekOf('Wednesday', thursday), DateTime(2026, 9, 9));
      expect(dateForWeekdayInWeekOf('Thursday', thursday), DateTime(2026, 9, 10));
      expect(dateForWeekdayInWeekOf('Friday', thursday), DateTime(2026, 9, 11));
      expect(dateForWeekdayInWeekOf('Saturday', thursday), DateTime(2026, 9, 12));
      expect(dateForWeekdayInWeekOf('Sunday', thursday), DateTime(2026, 9, 13));
    });

    // The timetable shows the current week, not the next seven days, so on a
    // Thursday the Monday tab is the Monday just gone.
    test('a weekday earlier in the week resolves to the past, not next week', () {
      expect(
        dateForWeekdayInWeekOf('Monday', thursday),
        DateTime(2026, 9, 7),
      );
    });

    test('drops the time of day', () {
      final result = dateForWeekdayInWeekOf('Friday', thursday)!;
      expect(result.hour, 0);
      expect(result.minute, 0);
    });

    test('is case and whitespace insensitive', () {
      final expected = DateTime(2026, 9, 7);
      expect(dateForWeekdayInWeekOf('monday', thursday), expected);
      expect(dateForWeekdayInWeekOf('MONDAY', thursday), expected);
      expect(dateForWeekdayInWeekOf('  Monday  ', thursday), expected);
    });

    test('crosses a month boundary correctly', () {
      // 2026-10-01 is a Thursday, so its Monday is in September.
      expect(
        dateForWeekdayInWeekOf('Monday', DateTime(2026, 10, 1)),
        DateTime(2026, 9, 28),
      );
    });

    test('crosses a year boundary correctly', () {
      // 2027-01-01 is a Friday; that week starts on 2026-12-28.
      expect(
        dateForWeekdayInWeekOf('Monday', DateTime(2027, 1, 1)),
        DateTime(2026, 12, 28),
      );
    });

    test('handles a leap day without shifting', () {
      // 2028-02-29 is a Tuesday.
      expect(
        dateForWeekdayInWeekOf('Tuesday', DateTime(2028, 2, 29)),
        DateTime(2028, 2, 29),
      );
    });

    // A wrong date here would put a holiday notice on the wrong day, so
    // anything unrecognised returns null instead of a guess.
    test('returns null for anything that is not a weekday name', () {
      for (final input in ['', 'Mon', 'Funday', 'monday1', '1']) {
        expect(
          dateForWeekdayInWeekOf(input, thursday),
          isNull,
          reason: '$input should not resolve to a date',
        );
      }
    });

    test('a Sunday resolves to itself, not the following week', () {
      // 2026-09-13 is a Sunday, the last day of its week.
      expect(
        dateForWeekdayInWeekOf('Sunday', DateTime(2026, 9, 13)),
        DateTime(2026, 9, 13),
      );
    });
  });
}
