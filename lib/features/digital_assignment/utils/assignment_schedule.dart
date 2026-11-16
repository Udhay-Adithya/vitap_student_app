/// Reading and ordering assignment deadlines.
///
/// "When is this due" is the question the whole screen exists to answer, and it
/// used to be answered with the raw `25-Jul-2026` string VTOP sends — which
/// tells you nothing about whether that is tomorrow or last month without doing
/// the arithmetic yourself.
library;

import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';

/// The format VTOP uses for `due_date`, e.g. `25-Jul-2026`.
final DateFormat _dueDateFormat = DateFormat('dd-MMM-yyyy');

/// How pressing a deadline is, once the submission state is taken into account.
enum DueUrgency {
  /// Already submitted — the deadline no longer matters.
  done,

  /// The deadline passed without a submission.
  missed,

  /// Still open, but the date is behind us.
  overdue,

  /// Due today or tomorrow.
  imminent,

  /// Due within the week.
  soon,

  /// Further out, or no usable date.
  later,
}

/// Parses a `dd-MMM-yyyy` due date, or `null` when VTOP sends something else.
///
/// Never throws: this is read inside list builders, where one malformed row
/// would otherwise take down the whole screen.
DateTime? parseAssignmentDueDate(String? rawDueDate) {
  final String value = (rawDueDate ?? '').trim();
  if (value.isEmpty) return null;
  try {
    return _dueDateFormat.parseStrict(value);
  } on FormatException {
    return null;
  }
}

/// Whole days from today until the deadline. Negative once it has passed.
int? daysUntilDue(String? rawDueDate, {DateTime? now}) {
  final DateTime? due = parseAssignmentDueDate(rawDueDate);
  if (due == null) return null;
  final DateTime today = _dayOf(now ?? DateTime.now());
  return _dayOf(due).difference(today).inDays;
}

DueUrgency assignmentUrgency(AssignmentDetail detail, {DateTime? now}) {
  switch (getSubmissionState(detail.submissionStatus)) {
    case SubmissionState.submitted:
      return DueUrgency.done;
    case SubmissionState.missed:
      return DueUrgency.missed;
    case SubmissionState.pending:
      final int? days = daysUntilDue(detail.dueDate, now: now);
      if (days == null) return DueUrgency.later;
      if (days < 0) return DueUrgency.overdue;
      if (days <= 1) return DueUrgency.imminent;
      if (days <= 7) return DueUrgency.soon;
      return DueUrgency.later;
  }
}

/// The deadline in words: `Due tomorrow`, `Overdue by 3 days`, `Due 25 Jul`.
///
/// Falls back to the raw string when the date cannot be parsed, so an unexpected
/// format degrades to what the screen used to show rather than to nothing.
String dueLabel(String? rawDueDate, {DateTime? now}) {
  final int? days = daysUntilDue(rawDueDate, now: now);
  if (days == null) {
    final String raw = (rawDueDate ?? '').trim();
    return raw.isEmpty ? 'No due date' : 'Due $raw';
  }

  if (days < 0) {
    final int overdue = -days;
    return overdue == 1 ? 'Overdue by 1 day' : 'Overdue by $overdue days';
  }
  if (days == 0) return 'Due today';
  if (days == 1) return 'Due tomorrow';
  if (days <= 7) return 'Due in $days days';

  final DateTime due = parseAssignmentDueDate(rawDueDate)!;
  final DateTime today = _dayOf(now ?? DateTime.now());
  return due.year == today.year
      ? 'Due ${DateFormat('d MMM').format(due)}'
      : 'Due ${DateFormat('d MMM yyyy').format(due)}';
}

/// Soonest deadline first, with unparseable dates last rather than first.
int compareByDueDate(AssignmentDetail a, AssignmentDetail b) {
  final DateTime? left = parseAssignmentDueDate(a.dueDate);
  final DateTime? right = parseAssignmentDueDate(b.dueDate);
  if (left == null && right == null) return 0;
  if (left == null) return 1;
  if (right == null) return -1;
  return left.compareTo(right);
}

/// [details] ordered for reading: still-actionable work first, by deadline, then
/// everything already dealt with.
List<AssignmentDetail> sortedForDisplay(List<AssignmentDetail> details) {
  final List<AssignmentDetail> sorted = List<AssignmentDetail>.of(details);
  sorted.sort((AssignmentDetail a, AssignmentDetail b) {
    final bool aDone =
        getSubmissionState(a.submissionStatus) == SubmissionState.submitted;
    final bool bDone =
        getSubmissionState(b.submissionStatus) == SubmissionState.submitted;
    if (aDone != bDone) return aDone ? 1 : -1;
    return compareByDueDate(a, b);
  });
  return sorted;
}

/// The next thing actually requiring action in a course, or `null` when
/// everything is submitted or already missed.
///
/// This is what a course card should lead with — the counts alone told you *how
/// many* were outstanding but never *when*.
AssignmentDetail? nextActionable(List<AssignmentDetail> details) {
  final List<AssignmentDetail> pending =
      details
          .where(
            (AssignmentDetail d) =>
                getSubmissionState(d.submissionStatus) ==
                SubmissionState.pending,
          )
          .toList()
        ..sort(compareByDueDate);
  return pending.isEmpty ? null : pending.first;
}

DateTime _dayOf(DateTime date) => DateTime(date.year, date.month, date.day);
