/// The hostel's rules for when you may leave and when you must be back.
///
/// Pulled out of the form widgets so they can be read, reused and tested. The
/// deadline rule in particular used to live inside a `StatefulWidget` and could
/// only be exercised by driving the UI — which is how it kept a hole in it.
library;

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:vit_ap_student_app/core/utils/parse_class_time.dart';

/// Earliest and latest a general outing may start or end.
const TimeOfDay outingWindowStart = TimeOfDay(hour: 6, minute: 0);
const TimeOfDay outingWindowEnd = TimeOfDay(hour: 22, minute: 0);

/// Whether a general outing may start or end at [time].
///
/// Purely a decision — the old version also raised a snackbar from inside what
/// callers passed as a validator, which is why it could not be reused.
bool isOutingTimeAllowed(TimeOfDay time) {
  final int minutes = time.hour * 60 + time.minute;
  return minutes >= outingWindowStart.hour * 60 + outingWindowStart.minute &&
      minutes <= outingWindowEnd.hour * 60 + outingWindowEnd.minute;
}

/// Weekend outings run on Sundays and Mondays only.
bool isWeekendOutingDay(DateTime date) =>
    date.weekday == DateTime.sunday || date.weekday == DateTime.monday;

/// The moment applications close for an outing on [outingDate] — two days
/// before, at the end of the day. Returns `null` for a date that isn't a
/// weekend outing day at all.
///
/// Derived from the outing date itself rather than from "the upcoming Sunday".
/// The previous version compared against a computed target day and returned
/// "deadline not passed" for anything that didn't match it — so an outing on
/// *today's* Monday skipped the check entirely and stayed applicable long after
/// Saturday night.
DateTime? weekendOutingDeadline(DateTime outingDate) {
  if (!isWeekendOutingDay(outingDate)) return null;
  return DateTime(
    outingDate.year,
    outingDate.month,
    outingDate.day - 2,
    23,
    59,
    59,
  );
}

/// Whether an application for [outingDate] can still be submitted.
///
/// [now] is injectable so the rule can be tested without waiting for a weekend.
bool isWeekendOutingOpen(DateTime outingDate, {DateTime? now}) {
  final DateTime? deadline = weekendOutingDeadline(outingDate);
  if (deadline == null) return false;
  return !(now ?? DateTime.now()).isAfter(deadline);
}

/// Whether the date picker should offer [date] for a weekend outing.
///
/// [bypass] mirrors the developer preference that lifts the restriction.
bool isSelectableWeekendOutingDate(
  DateTime date, {
  DateTime? now,
  bool bypass = false,
}) {
  if (!isWeekendOutingDay(date)) return false;
  return bypass || isWeekendOutingOpen(date, now: now);
}

/// Resolves a picked date plus an `HH:mm` string into one moment.
DateTime? combineDateAndTime(DateTime? date, String? time) {
  if (date == null) return null;
  return parseClassTime(time, onDate: date);
}

/// Checks a general outing's departure against its return.
///
/// Returns the problem, or `null` when the pair is fine. Nothing related the two
/// halves before, so a return date earlier than the departure submitted happily
/// and was only rejected by VTOP a round trip later.
String? validateOutingSpan({
  required DateTime? fromDate,
  required String? fromTime,
  required DateTime? toDate,
  required String? toTime,
}) {
  final DateTime? from = combineDateAndTime(fromDate, fromTime);
  final DateTime? to = combineDateAndTime(toDate, toTime);
  // Individual field validators already report the missing pieces.
  if (from == null || to == null) return null;

  if (!to.isAfter(from)) {
    return 'Return must be after departure';
  }
  return null;
}

/// How far ahead a general outing may be applied for.
///
/// The picker previously fell back to its default 720-day range, so an outing
/// could be requested two years out.
const int generalOutingMaxDaysAhead = 30;

/// Whether the weekend outing form should be offered at all.
///
/// Tuesday 00:00 → Saturday 23:59. Sunday and Monday are shut: VTOP returns the
/// page with the student fields missing entirely, so there is no request that
/// could be built — which is why this gates the UI rather than letting a submit
/// fail.
///
/// Saturday is included so a Monday outing can still be applied for on its own
/// deadline day — [weekendOutingDeadline] puts that at Saturday 23:59:59, and
/// stopping at Friday would have made that deadline unreachable.
bool isWeekendOutingFormOpen({DateTime? now}) {
  final int weekday = (now ?? DateTime.now()).weekday;
  return weekday >= DateTime.tuesday && weekday <= DateTime.saturday;
}

/// When the form next becomes available — the coming Tuesday, at midnight.
DateTime nextWeekendOutingFormOpening({DateTime? now}) {
  final DateTime moment = now ?? DateTime.now();
  final int daysUntilTuesday = (DateTime.tuesday - moment.weekday + 7) % 7;
  return DateTime(
    moment.year,
    moment.month,
    moment.day + (daysUntilTuesday == 0 ? 7 : daysUntilTuesday),
  );
}

/// What to tell a student on a day the app knows the form is shut.
const String weekendOutingFormWindowMessage =
    'Weekend outing applications are open from Tuesday 12:00 AM to '
    'Saturday 11:59 PM.';
