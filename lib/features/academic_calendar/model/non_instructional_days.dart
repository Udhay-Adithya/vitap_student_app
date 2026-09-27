import 'package:vit_ap_student_app/core/models/academic_calendar.dart';
import 'package:vit_ap_student_app/features/academic_calendar/model/calendar_day_summary.dart';

/// The dates a semester has no classes on, read off the academic calendar.
///
/// VTOP has no "is this a holiday" field. What it does have is a calendar entry
/// per day, which [calendarDayKind] already reduces to a kind — so this is that
/// classification, indexed by date so a caller can ask about one day without
/// walking the whole semester.
///
/// Exam days are **not** included. There are no classes then either, but exams
/// are their own thing and suppressing a class reminder is not the same as
/// suppressing an exam reminder.
class NonInstructionalDays {
  /// Keyed by `YYYY-MM-DD`, which is the form VTOP already stores.
  final Map<String, String> _reasonByDate;

  const NonInstructionalDays._(this._reasonByDate);

  /// Nothing is a holiday. Used when no calendar has been fetched yet, so the
  /// app behaves exactly as it did before rather than guessing.
  static const NonInstructionalDays empty = NonInstructionalDays._({});

  /// Reads the non-instructional days out of a stored calendar.
  ///
  /// A null calendar gives [empty]: the student has never opened the calendar
  /// page, and assuming a day is a working day is the safe default — a reminder
  /// that should not have fired is a smaller harm than one that never did.
  factory NonInstructionalDays.fromCalendar(AcademicCalendar? calendar) {
    if (calendar == null) return empty;

    final reasons = <String, String>{};
    for (final day in calendar.days) {
      final kind = calendarDayKind(day);
      if (kind != CalendarDayKind.holiday &&
          kind != CalendarDayKind.noInstruction) {
        continue;
      }

      final key = _normalise(day.date);
      if (key == null) continue;

      reasons[key] = _headlineFor(day, kind);
    }

    return NonInstructionalDays._(reasons);
  }

  /// Builds a lookup directly from dates. For tests and for callers that
  /// already know the days, without going through a stored calendar.
  factory NonInstructionalDays.fromDates(Map<DateTime, String> reasons) {
    return NonInstructionalDays._({
      for (final entry in reasons.entries) _keyOf(entry.key): entry.value,
    });
  }

  /// Whether classes are off on [date]. The time of day is ignored.
  bool contains(DateTime date) => _reasonByDate.containsKey(_keyOf(date));

  /// What the day is called — "Independence Day", "No Instructional Day" —
  /// or null when it is an ordinary day.
  String? reasonFor(DateTime date) => _reasonByDate[_keyOf(date)];

  /// True when no calendar has been read, so nothing can be suppressed.
  bool get isEmpty => _reasonByDate.isEmpty;

  int get length => _reasonByDate.length;

  /// The most useful line for a day: a named holiday says its name in the
  /// label, so prefer the summary's headline and fall back to the kind.
  static String _headlineFor(CalendarDay day, CalendarDayKind kind) {
    final summaries = summariseCalendarDay(day);
    for (final entry in summaries) {
      if (entry.kind == kind && entry.headline.trim().isNotEmpty) {
        return entry.headline.trim();
      }
    }
    return kind == CalendarDayKind.holiday ? 'Holiday' : 'No Instructional Day';
  }

  /// VTOP stores `YYYY-MM-DD`. Anything else is ignored rather than guessed at,
  /// because a misread date would suppress a reminder on the wrong day.
  static String? _normalise(String date) {
    final parsed = DateTime.tryParse(date.trim());
    if (parsed == null) return null;
    return _keyOf(parsed);
  }

  static String _keyOf(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
