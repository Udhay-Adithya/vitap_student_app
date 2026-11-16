import 'package:flutter_test/flutter_test.dart';
import 'package:objectbox/objectbox.dart';
import 'package:vit_ap_student_app/core/models/academic_calendar.dart';
import 'package:vit_ap_student_app/features/academic_calendar/model/calendar_grouping.dart';

CalendarDay day(String date) => CalendarDay(
  date: date,
  day: int.parse(date.split('-').last),
  weekday: 'Monday',
  events: ToMany<CalendarEvent>(items: []),
);

AcademicCalendar calendar({
  List<String> months = const ['01-JUL-2026', '01-AUG-2026', '01-SEP-2026'],
  List<String> dates = const [],
}) => AcademicCalendar(
  semesterId: 'AP2026272',
  classGroupId: 'COMB',
  months: ToMany<CalendarMonthRef>(
    items: [
      for (final calDate in months)
        CalendarMonthRef(label: calDate.substring(3), calDate: calDate),
    ],
  ),
  days: ToMany<CalendarDay>(items: [for (final date in dates) day(date)]),
);

void main() {
  group('calendarMonthKey', () {
    /// The month buttons carry VTOP's format while the days carry ISO dates,
    /// so one has to be translated to match them up.
    test('translates a calDate into its ISO month', () {
      expect(calendarMonthKey('01-AUG-2026'), '2026-08');
      expect(calendarMonthKey('01-JAN-2027'), '2027-01');
      expect(calendarMonthKey('01-DEC-2026'), '2026-12');
    });

    test('is case insensitive about the month name', () {
      expect(calendarMonthKey('01-aug-2026'), '2026-08');
    });

    test('returns null rather than guessing at something unreadable', () {
      // Guessing would put every day of the month under the wrong heading.
      expect(calendarMonthKey('01-XXX-2026'), isNull);
      expect(calendarMonthKey('nonsense'), isNull);
      expect(calendarMonthKey('01-AUG-YYYY'), isNull);
      expect(calendarMonthKey(''), isNull);
    });
  });

  group('daysOfMonth', () {
    test('takes only the days of the month asked for', () {
      final august = daysOfMonth(
        calendar(
          dates: ['2026-07-31', '2026-08-01', '2026-08-02', '2026-09-01'],
        ),
        '01-AUG-2026',
      );

      expect(august.map((d) => d.date), ['2026-08-01', '2026-08-02']);
    });

    /// A prefix match on "2026-08" alone would also swallow 2026-08 of another
    /// year's calendar if one were ever merged in, and reads as a bug waiting
    /// to happen; the separator keeps it a whole-field match.
    test('does not match a neighbouring month by prefix', () {
      final days = daysOfMonth(
        calendar(dates: ['2026-08-01', '2026-08-10']),
        '01-AUG-2026',
      );

      expect(days, hasLength(2));
    });

    test('comes back in date order whatever order it was stored in', () {
      final days = daysOfMonth(
        calendar(dates: ['2026-08-10', '2026-08-02', '2026-08-31']),
        '01-AUG-2026',
      );

      expect(days.map((d) => d.date), [
        '2026-08-02',
        '2026-08-10',
        '2026-08-31',
      ]);
    });

    test('an unreadable month yields nothing', () {
      expect(daysOfMonth(calendar(dates: ['2026-08-01']), 'nonsense'), isEmpty);
    });
  });

  group('monthToOpen', () {
    /// A calendar is nearly always opened to check something about now, so
    /// landing on July in October means scrolling before the page is any use.
    test('opens on the month containing today', () {
      expect(monthToOpen(calendar(), DateTime(2026, 8, 14)), '01-AUG-2026');
    });

    test(
      'falls back to the first month when today is outside the semester',
      () {
        expect(monthToOpen(calendar(), DateTime(2027, 3, 1)), '01-JUL-2026');
      },
    );

    test('is null when there are no months at all', () {
      expect(monthToOpen(calendar(months: []), DateTime(2026, 8, 14)), isNull);
    });
  });
}
