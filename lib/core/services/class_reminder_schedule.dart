import 'package:flutter/material.dart' show TimeOfDay;
import 'package:vit_ap_student_app/features/academic_calendar/model/non_instructional_days.dart';

/// How far ahead class reminders are scheduled.
///
/// Reminders used to be a single weekly-repeating notification per class, which
/// the OS repeated forever. That cannot skip a holiday: there is no way to drop
/// one occurrence of a repeating alarm.
///
/// So each occurrence is now scheduled individually, which means there has to
/// be a horizon. Four weeks is a trade: long enough that a student who does not
/// open the app for a while keeps getting reminders, short enough that the
/// pending-alarm count stays modest — roughly five classes a day over six days
/// is about 120 alarms, well inside Android's limit.
///
/// Every call to schedule rebuilds the window, and the app schedules on launch,
/// on sync and whenever the preference changes, so in practice the horizon is
/// refreshed long before it runs out.
const int classReminderHorizonWeeks = 4;

/// One reminder to be scheduled: when it fires, and which occurrence it is for.
typedef ClassReminderOccurrence = ({DateTime classStart, DateTime notifyAt});

/// The dates a weekly class actually happens on, within the horizon.
///
/// Pure on purpose. The scheduling itself needs a live plugin and a timezone
/// database, so the part worth testing — which days are picked, which are
/// skipped, and when the reminder fires — is separated out.
///
/// [weekday] follows `DateTime.monday`..`DateTime.sunday` (1–7).
/// Occurrences whose reminder time has already passed are dropped, so calling
/// this twice in a day does not schedule something for the past.
List<ClassReminderOccurrence> classReminderOccurrences({
  required DateTime from,
  required int weekday,
  required TimeOfDay startTime,
  required int delayMinutes,
  NonInstructionalDays nonInstructionalDays = NonInstructionalDays.empty,
  int horizonWeeks = classReminderHorizonWeeks,
}) {
  if (weekday < DateTime.monday || weekday > DateTime.sunday) return const [];
  if (horizonWeeks <= 0) return const [];

  final occurrences = <ClassReminderOccurrence>[];

  // The first time this weekday comes round, today included.
  final daysAhead = (weekday - from.weekday) % 7;
  var date = DateTime(from.year, from.month, from.day + daysAhead);

  for (var week = 0; week < horizonWeeks; week++) {
    final classStart = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    final notifyAt = classStart.subtract(Duration(minutes: delayMinutes));

    // Skipped for two different reasons, and both matter:
    //   * the reminder is already in the past — scheduling it would either fire
    //     immediately or be dropped by the OS
    //   * the day has no classes, which is the whole point of this change
    final alreadyPassed = !notifyAt.isAfter(from);
    if (!alreadyPassed && !nonInstructionalDays.contains(date)) {
      occurrences.add((classStart: classStart, notifyAt: notifyAt));
    }

    date = DateTime(date.year, date.month, date.day + 7);
  }

  return occurrences;
}

/// A stable id for one occurrence, so rescheduling replaces rather than
/// duplicates, and two classes on the same day do not collide.
///
/// Kept inside 32 bits because the notification plugin ids are Android ints.
int classReminderNotificationId({
  required int slotId,
  required DateTime classStart,
}) {
  final day = classStart.year * 10000 + classStart.month * 100 + classStart.day;
  final minuteOfDay = classStart.hour * 60 + classStart.minute;
  return Object.hash(slotId, day, minuteOfDay) & 0x7fffffff;
}
