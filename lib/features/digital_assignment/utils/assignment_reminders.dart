/// Which assignment reminders to schedule, and when.
///
/// VTOP sends a due *date* (`25-Jul-2026`) with no time. Uploads stay open
/// until the end of that day, so the deadline is read as 11:59 PM on it, and
/// every reminder counts back from there.
library;

import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/features/digital_assignment/utils/assignment_schedule.dart';

/// How long before the deadline a reminder fires.
///
/// [name] is what gets persisted, so renaming a value forgets the choice of
/// everyone who picked it.
enum ReminderLead {
  sevenDays(Duration(days: 7), '7 days', 'in 7 days'),
  threeDays(Duration(days: 3), '3 days', 'in 3 days'),
  oneDay(Duration(days: 1), '1 day', 'tomorrow'),
  oneHour(Duration(hours: 1), '1 hour', 'in 1 hour');

  const ReminderLead(this.before, this.label, this.dueIn);

  final Duration before;

  /// Chip text in settings.
  final String label;

  /// How the notification phrases the time left: `Due tomorrow`.
  final String dueIn;
}

/// One notification to be scheduled.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.fireAt,
    required this.title,
    required this.body,
  });

  /// Stable for the same assignment and lead, so rescheduling replaces the
  /// notification rather than stacking a second one beside it.
  final int id;
  final tz.TZDateTime fireAt;
  final String title;
  final String body;
}

/// The moment uploads close: 11:59 PM on the due date, in [location].
tz.TZDateTime? assignmentDeadline(String? rawDueDate, tz.Location location) {
  final DateTime? due = parseAssignmentDueDate(rawDueDate);
  if (due == null) return null;
  return tz.TZDateTime(location, due.year, due.month, due.day, 23, 59);
}

/// Reminders for every assignment still waiting on a submission, soonest
/// first. Submitted and missed work, unparseable dates, and reminders whose
/// moment has already passed are all left out.
List<PlannedReminder> planAssignmentReminders(
  List<DigitalAssignment> assignments,
  Set<ReminderLead> leads, {
  required tz.TZDateTime now,
}) {
  final List<PlannedReminder> planned = [];
  for (final DigitalAssignment course in assignments) {
    for (final AssignmentDetail detail in course.details) {
      if (getSubmissionState(detail.submissionStatus) !=
          SubmissionState.pending) {
        continue;
      }
      final tz.TZDateTime? deadline = assignmentDeadline(
        detail.dueDate,
        now.location,
      );
      if (deadline == null) continue;

      for (final ReminderLead lead in leads) {
        final tz.TZDateTime fireAt = deadline.subtract(lead.before);
        if (!fireAt.isAfter(now)) continue;
        planned.add(
          PlannedReminder(
            id: _idFor(course, detail, lead),
            fireAt: fireAt,
            title: '📝 ${detail.assignmentTitle} due ${lead.dueIn}',
            body:
                '${course.courseCode} · ${course.courseTitle}\n'
                'Submit before 11:59 PM, '
                '${DateFormat('EEE d MMM').format(deadline)}.',
          ),
        );
      }
    }
  }
  planned.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return planned;
}

// Masked to 31 bits: Android rejects notification ids outside a signed int.
int _idFor(
  DigitalAssignment course,
  AssignmentDetail detail,
  ReminderLead lead,
) =>
    'assignment_${course.classId}_${detail.mcode}_${lead.name}'.hashCode &
    0x7FFFFFFF;
