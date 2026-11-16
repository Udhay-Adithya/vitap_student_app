import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/features/digital_assignment/utils/assignment_reminders.dart';

late tz.Location kolkata;

AssignmentDetail detail({
  required String dueDate,
  String submissionStatus = '',
  String title = 'DA-1',
  String mcode = 'm1',
}) => AssignmentDetail(
  serialNumber: '1',
  assignmentTitle: title,
  maxAssignmentMark: '10',
  assignmentWeightageMark: '10',
  dueDate: dueDate,
  canQpDownload: false,
  qpDownloadUrl: '',
  submissionStatus: submissionStatus,
  canUpdate: true,
  mcode: mcode,
  canDaDownload: false,
  daDownloadUrl: '',
);

DigitalAssignment course(
  List<AssignmentDetail> details, {
  String classId = 'AP1',
}) => DigitalAssignment(
  serialNumber: '1',
  classId: classId,
  courseCode: 'CSE1001',
  courseTitle: 'Problem Solving',
  courseType: 'ETH',
  faculty: 'Dr. X',
  details: details,
);

const Set<ReminderLead> all = {...ReminderLead.values};

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    kolkata = tz.getLocation('Asia/Kolkata');
  });

  tz.TZDateTime at(int y, int m, int d, [int h = 0, int min = 0]) =>
      tz.TZDateTime(kolkata, y, m, d, h, min);

  test('reads the deadline as 11:59 PM on the due date, IST', () {
    final deadline = assignmentDeadline('25-Jul-2026', kolkata)!;
    expect(deadline, at(2026, 7, 25, 23, 59));
    // A device set to another zone must still fire at the IST deadline.
    expect(deadline.toUtc(), DateTime.utc(2026, 7, 25, 18, 29));
    expect(assignmentDeadline('-', kolkata), isNull);
  });

  test('schedules 7 days, 3 days, 1 day and 1 hour before, soonest first', () {
    final planned = planAssignmentReminders(
      [
        course([detail(dueDate: '25-Jul-2026')]),
      ],
      all,
      now: at(2026, 7, 1),
    );
    expect(planned.map((r) => r.fireAt), [
      at(2026, 7, 18, 23, 59),
      at(2026, 7, 22, 23, 59),
      at(2026, 7, 24, 23, 59),
      at(2026, 7, 25, 22, 59),
    ]);
    expect(planned.first.title, '📝 DA-1 due in 7 days');
    expect(planned.last.title, '📝 DA-1 due in 1 hour');
    expect(planned.last.body, contains('Submit before 11:59 PM, Sat 25 Jul'));
  });

  test('only the leads the student picked', () {
    final planned = planAssignmentReminders(
      [
        course([detail(dueDate: '25-Jul-2026')]),
      ],
      {ReminderLead.oneHour},
      now: at(2026, 7, 1),
    );
    expect(planned.single.fireAt, at(2026, 7, 25, 22, 59));
  });

  // An assignment set with less than a week to go must still get the
  // reminders that are ahead of it, not none.
  test('skips only the reminders whose moment has passed', () {
    final planned = planAssignmentReminders(
      [
        course([detail(dueDate: '25-Jul-2026')]),
      ],
      all,
      now: at(2026, 7, 23, 9),
    );
    expect(planned.map((r) => r.title), [
      '📝 DA-1 due tomorrow',
      '📝 DA-1 due in 1 hour',
    ]);
  });

  test('due today leaves just the 1-hour reminder, and none after it', () {
    expect(
      planAssignmentReminders(
        [
          course([detail(dueDate: '25-Jul-2026')]),
        ],
        all,
        now: at(2026, 7, 25, 12),
      ).single.fireAt,
      at(2026, 7, 25, 22, 59),
    );
    expect(
      planAssignmentReminders(
        [
          course([detail(dueDate: '25-Jul-2026')]),
        ],
        all,
        now: at(2026, 7, 25, 23),
      ),
      isEmpty,
    );
  });

  test('nothing for submitted, missed or undated work', () {
    final planned = planAssignmentReminders(
      [
        course([
          detail(
            dueDate: '25-Jul-2026',
            submissionStatus: '24 Jul 2026 11:48 PM',
          ),
          detail(dueDate: '25-Jul-2026', submissionStatus: 'File Not Uploaded'),
          detail(dueDate: '-'),
          detail(dueDate: ''),
        ]),
      ],
      all,
      now: at(2026, 7, 1),
    );
    expect(planned, isEmpty);
  });

  // Rescheduling relies on the same reminder getting the same id, so it
  // replaces rather than duplicates; and two assignments must not collide.
  test('ids are stable per assignment and lead, and distinct across them', () {
    List<int> ids() => planAssignmentReminders(
      [
        course([
          detail(dueDate: '25-Jul-2026', mcode: 'a'),
          detail(dueDate: '25-Jul-2026', mcode: 'b'),
        ]),
        course([detail(dueDate: '25-Jul-2026', mcode: 'a')], classId: 'AP2'),
      ],
      all,
      now: at(2026, 7, 1),
    ).map((r) => r.id).toList();

    expect(ids().toSet(), hasLength(12));
    expect(ids().toSet(), ids().toSet());
    expect(ids().every((id) => id >= 0 && id <= 0x7FFFFFFF), isTrue);
  });
}
