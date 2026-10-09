import 'package:flutter_test/flutter_test.dart';
import 'package:objectbox/objectbox.dart';
import 'package:vit_ap_student_app/core/models/academic_calendar.dart';
import 'package:vit_ap_student_app/features/academic_calendar/model/non_instructional_days.dart';
import 'package:vit_ap_student_app/features/academic_calendar/repository/academic_calendar_repository.dart';

/// One day, shaped the way VTOP sends it.
///
/// A named holiday is the awkward case: the description stays generic
/// ("Holiday - General (Semester)") and the *label* carries the name.
CalendarDay day(String date, {required String description, String label = ''}) =>
    CalendarDay(
      date: date,
      day: int.parse(date.split('-').last),
      weekday: 'Monday',
      events: ToMany<CalendarEvent>(
        items: [CalendarEvent(description: description, label: label)],
      ),
    );

AcademicCalendar calendarOf(List<CalendarDay> days) => AcademicCalendar(
  semesterId: 'AP2026272',
  classGroupId: defaultClassGroup,
  months: ToMany<CalendarMonthRef>(items: []),
  days: ToMany<CalendarDay>(items: days),
);

const _working = 'Instructional Day - General (Semester)';
const _holiday = 'Holiday - General (Semester)';
const _noInstruction = 'No Instructional Day - General (Semester)';
const _exam = 'CAT - I - General (Semester)';

void main() {
  group('NonInstructionalDays.fromCalendar', () {
    test('picks up holidays and non-instructional days', () {
      final days = NonInstructionalDays.fromCalendar(
        calendarOf([
          day('2026-09-07', description: _working, label: 'WorkingDay'),
          day('2026-09-08', description: _holiday, label: 'Holiday'),
          day('2026-09-09', description: _noInstruction, label: 'No Instructional Day'),
        ]),
      );

      expect(days.contains(DateTime(2026, 9, 7)), isFalse);
      expect(days.contains(DateTime(2026, 9, 8)), isTrue);
      expect(days.contains(DateTime(2026, 9, 9)), isTrue);
      expect(days.length, 2);
    });

    // Exams are not classes, but suppressing a class reminder is not the same
    // as suppressing an exam reminder, so they are deliberately left out.
    test('does not treat an exam day as non-instructional', () {
      final days = NonInstructionalDays.fromCalendar(
        calendarOf([day('2026-09-10', description: _exam, label: 'Exam Days')]),
      );

      expect(days.contains(DateTime(2026, 9, 10)), isFalse);
      expect(days.isEmpty, isTrue);
    });

    test('uses the holiday name when VTOP gives one', () {
      final days = NonInstructionalDays.fromCalendar(
        calendarOf([
          day('2026-08-15', description: _holiday, label: 'Independence Day'),
        ]),
      );

      expect(days.reasonFor(DateTime(2026, 8, 15)), 'Independence Day');
    });

    test('falls back to the generic wording for an unnamed holiday', () {
      final days = NonInstructionalDays.fromCalendar(
        calendarOf([day('2026-09-08', description: _holiday, label: 'Holiday')]),
      );

      expect(days.reasonFor(DateTime(2026, 9, 8)), isNotEmpty);
    });

    test('a null calendar suppresses nothing', () {
      final days = NonInstructionalDays.fromCalendar(null);

      expect(days.isEmpty, isTrue);
      expect(days.contains(DateTime(2026, 9, 8)), isFalse);
    });

    test('a calendar with no days suppresses nothing', () {
      expect(NonInstructionalDays.fromCalendar(calendarOf([])).isEmpty, isTrue);
    });

    // A misread date would suppress a reminder on the wrong day, so anything
    // unparseable is dropped rather than guessed at.
    test('ignores a day whose date cannot be parsed', () {
      final days = NonInstructionalDays.fromCalendar(
        calendarOf([
          CalendarDay(
            date: 'not-a-date',
            day: 1,
            weekday: 'Monday',
            events: ToMany<CalendarEvent>(
              items: [CalendarEvent(description: _holiday, label: 'Holiday')],
            ),
          ),
        ]),
      );

      expect(days.isEmpty, isTrue);
    });

    test('a day carrying both a holiday and a working entry counts as off', () {
      final days = NonInstructionalDays.fromCalendar(
        calendarOf([
          CalendarDay(
            date: '2026-09-08',
            day: 8,
            weekday: 'Monday',
            events: ToMany<CalendarEvent>(
              items: [
                CalendarEvent(description: _working, label: 'WorkingDay'),
                CalendarEvent(description: _holiday, label: 'Onam'),
              ],
            ),
          ),
        ]),
      );

      expect(days.contains(DateTime(2026, 9, 8)), isTrue);
      expect(days.reasonFor(DateTime(2026, 9, 8)), 'Onam');
    });
  });

  group('lookup', () {
    final days = NonInstructionalDays.fromDates({
      DateTime(2026, 9, 8): 'Independence Day',
    });

    test('ignores the time of day', () {
      expect(days.contains(DateTime(2026, 9, 8, 23, 59)), isTrue);
      expect(days.contains(DateTime(2026, 9, 8, 0, 0)), isTrue);
    });

    test('does not bleed into the days either side', () {
      expect(days.contains(DateTime(2026, 9, 7, 23, 59)), isFalse);
      expect(days.contains(DateTime(2026, 9, 9, 0, 1)), isFalse);
    });

    test('reasonFor is null on an ordinary day', () {
      expect(days.reasonFor(DateTime(2026, 9, 9)), isNull);
    });

    test('single-digit months and days match', () {
      final january = NonInstructionalDays.fromDates({
        DateTime(2027, 1, 1): 'New Year',
      });

      expect(january.contains(DateTime(2027, 1, 1)), isTrue);
      expect(january.reasonFor(DateTime(2027, 1, 1)), 'New Year');
    });
  });

  test('empty is a usable default', () {
    expect(NonInstructionalDays.empty.isEmpty, isTrue);
    expect(NonInstructionalDays.empty.contains(DateTime(2026, 9, 8)), isFalse);
    expect(NonInstructionalDays.empty.reasonFor(DateTime(2026, 9, 8)), isNull);
  });
}
