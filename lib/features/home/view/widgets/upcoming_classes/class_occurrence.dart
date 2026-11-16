import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/utils/get_classes.dart';
import 'package:vit_ap_student_app/core/utils/parse_class_time.dart';

/// Where a class sits relative to the current moment.
enum ClassPhase { completed, ongoing, upcoming }

/// A timetable [Day] slot resolved against a concrete calendar date.
///
/// The timetable itself only stores `"09:00"`-style strings per weekday, so every
/// question the home schedule asks — is this over, how long is left, which class
/// comes next — needs the slot paired with the date it falls on. Keeping that
/// pairing in one place is what lets the stack point at tomorrow's first class
/// with the same widget it uses for today's.
class ClassOccurrence {
  const ClassOccurrence({
    required this.info,
    required this.date,
    this.start,
    this.end,
  });

  factory ClassOccurrence.on(DateTime date, Day info) => ClassOccurrence(
    info: info,
    date: date,
    start: parseClassTime(info.startTime, onDate: date),
    end: parseClassTime(info.endTime, onDate: date),
  );

  final Day info;

  /// The calendar day this slot was resolved against.
  final DateTime date;

  final DateTime? start;
  final DateTime? end;

  /// Stable identity for animation keys. Slots persisted by ObjectBox have an
  /// id; fall back to the slot's own content for anything not yet stored.
  String get key =>
      '${info.id ?? '${info.courseCode}-${info.slot}'}@${date.day}-${date.month}';

  /// Minutes past midnight, used purely to order a day's slots. Slots VTOP gave
  /// us no usable time for sort last instead of jumping to the top of the list.
  int get sortKey => start == null ? 1 << 30 : start!.hour * 60 + start!.minute;

  ClassPhase phaseAt(DateTime now) {
    // A slot with no usable time can never be "done" — VTOP simply didn't emit
    // one — so treat it as still ahead rather than silently burying it in the
    // completed group where nobody would look for it.
    if (start == null || end == null) return ClassPhase.upcoming;
    if (now.isBefore(start!)) return ClassPhase.upcoming;
    if (now.isAfter(end!)) return ClassPhase.completed;
    return ClassPhase.ongoing;
  }

  /// Time until this class ends, or `null` when it can't be measured.
  Duration? remainingAt(DateTime now) {
    if (end == null) return null;
    final Duration left = end!.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  /// Time until this class starts, or `null` when it can't be measured.
  Duration? startsInAt(DateTime now) {
    if (start == null) return null;
    final Duration until = start!.difference(now);
    return until.isNegative ? Duration.zero : until;
  }

  /// How far through the class we are, `0..1`, or `null` when unmeasurable.
  double? progressAt(DateTime now) {
    if (start == null || end == null) return null;
    final int total = end!.difference(start!).inSeconds;
    if (total <= 0) return null;
    return (now.difference(start!).inSeconds / total).clamp(0.0, 1.0);
  }
}

/// Every class scheduled on [date], ordered by start time.
///
/// The stored timetable preserves VTOP's row order rather than chronological
/// order, so sorting here is what keeps the stack reading top-to-bottom as a day.
List<ClassOccurrence> classesOn(Timetable timetable, DateTime date) {
  final String weekday = DateFormat('EEEE').format(date);
  final List<ClassOccurrence> classes = getClassesForDay(
    timetable,
    weekday,
  ).map((Day day) => ClassOccurrence.on(date, day)).toList();
  classes.sort(
    (ClassOccurrence a, ClassOccurrence b) => a.sortKey.compareTo(b.sortKey),
  );
  return classes;
}

/// Compact duration for the "22m left" / "starts in 1h 15m" readouts.
String formatShortDuration(Duration duration) {
  if (duration.inMinutes < 1) return '<1m';
  final int hours = duration.inHours;
  final int minutes = duration.inMinutes.remainder(60);
  if (hours == 0) return '${minutes}m';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}m';
}
