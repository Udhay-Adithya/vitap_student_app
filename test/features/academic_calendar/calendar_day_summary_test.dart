import 'package:flutter_test/flutter_test.dart';
import 'package:objectbox/objectbox.dart';
import 'package:vit_ap_student_app/core/models/academic_calendar.dart';
import 'package:vit_ap_student_app/features/academic_calendar/model/calendar_day_summary.dart';

CalendarEvent event(String description, [String label = '']) =>
    CalendarEvent(description: description, label: label);

CalendarDay day(List<CalendarEvent> events) => CalendarDay(
  date: '2026-08-01',
  day: 1,
  weekday: 'Saturday',
  events: ToMany<CalendarEvent>(items: [...events]),
);

void main() {
  group('summariseCalendarEvent', () {
    /// Every description ends with the class group it belongs to. It is the
    /// same on every entry, so it says nothing and only crowds the row.
    test('drops the class group suffix', () {
      final summary = summariseCalendarEvent(
        event('Instructional Day - General (Semester)', 'WorkingDay'),
      );

      expect(summary.headline, 'Instructional Day');
      expect(summary.kind, CalendarDayKind.working);
    });

    /// "CAT - I - General (Semester)" has a dash of its own. Splitting on the
    /// first one would leave "CAT" and lose which CAT it is.
    test('keeps a dash that belongs to the name', () {
      final summary = summariseCalendarEvent(
        event('CAT - I - General (Semester)', 'Exam Days'),
      );

      expect(summary.headline, 'CAT - I');
      expect(summary.kind, CalendarDayKind.exam);
    });

    /// A named holiday is the one case where the label carries the headline and
    /// the description stays generic — the reverse of an exam.
    test('a named holiday is named by its label', () {
      final summary = summariseCalendarEvent(
        event('Holiday - General (Semester)', 'Independence Day'),
      );

      expect(summary.headline, 'Independence Day');
      // Still a holiday: the kind comes from the description, which does not
      // change when the day has a name.
      expect(summary.kind, CalendarDayKind.holiday);
    });

    test('an unnamed holiday falls back to the description', () {
      final summary = summariseCalendarEvent(
        event('Holiday - General (Semester)', 'Holiday'),
      );

      expect(summary.headline, 'Holiday');
      expect(summary.kind, CalendarDayKind.holiday);
    });

    test('reads a no-instruction day', () {
      final summary = summariseCalendarEvent(
        event(
          'No Instructional Day - General (Semester)',
          'No Instructional Day',
        ),
      );

      expect(summary.headline, 'No Instructional Day');
      expect(summary.kind, CalendarDayKind.noInstruction);
    });

    test('an unrecognised entry is shown as sent, not dropped', () {
      final summary = summariseCalendarEvent(event('Convocation', ''));

      expect(summary.headline, 'Convocation');
      expect(summary.kind, CalendarDayKind.other);
    });

    test('leaves a description with no class group suffix alone', () {
      expect(
        summariseCalendarEvent(event('Convocation Day')).headline,
        'Convocation Day',
      );
      expect(summariseCalendarEvent(event('CAT - I')).headline, 'CAT - I');
    });
  });

  group('calendarDayKind', () {
    test('is the kind of the only entry', () {
      expect(
        calendarDayKind(
          day([event('Holiday - General (Semester)', 'Holiday')]),
        ),
        CalendarDayKind.holiday,
      );
    });

    /// A day carrying both is worth seeing as an exam day: that is the part a
    /// student is scanning for.
    test('takes the most notable of several entries', () {
      final mixed = day([
        event('Instructional Day - General (Semester)', 'WorkingDay'),
        event('CAT - I - General (Semester)', 'Exam Days'),
      ]);

      expect(calendarDayKind(mixed), CalendarDayKind.exam);
    });

    test('a day VTOP listed nothing for is not mistaken for a working day', () {
      expect(calendarDayKind(day([])), CalendarDayKind.other);
    });
  });
}
