import 'package:flutter_test/flutter_test.dart';
import 'package:objectbox/objectbox.dart';
import 'package:vit_ap_student_app/core/models/attendance.dart';
import 'package:vit_ap_student_app/core/models/capstone_attendance.dart';
import 'package:vit_ap_student_app/core/models/exam_schedule.dart';
import 'package:vit_ap_student_app/core/models/mark.dart';
import 'package:vit_ap_student_app/core/models/profile.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/user_persistence.dart';

Attendance attendance(String courseCode) => Attendance(
  classNumber: '1',
  faculty: 'Someone',
  courseId: 'AM_$courseCode',
  courseCode: courseCode,
  courseName: 'A course',
  courseType: 'Theory Only',
  courseTypeCode: 'TH',
  courseSlot: 'A1',
  attendedClasses: '10',
  totalClasses: '10',
  attendancePercentage: '100',
  betweenAttendancePercentage: '100',
  debarStatus: '',
);

CapstoneAttendance capstone({String title = 'Capstone'}) => CapstoneAttendance(
  title: title,
  guideEvaluationStatus: 'Registered',
  dateOfRegistration: '2026-07-06 00:00:00.0',
  present: '14',
  onDuty: '4',
  absent: '12',
  percentage: '60',
  punches: ToMany<CapstonePunch>(
    items: [
      CapstonePunch(
        serial: '1',
        date: '17-07-2026',
        day: 'FRIDAY',
        dayType: 'Instructional',
        status: 'Absent',
        punchTime: '',
      ),
    ],
  ),
);

User user({
  List<Attendance> attendances = const [],
  CapstoneAttendance? capstoneAttendance,
  int? id,
}) => User(
  id: id,
  profile: ToOne<Profile>(),
  // Copied into a growable list: a const list makes ToMany unmodifiable.
  attendance: ToMany<Attendance>(items: [...attendances]),
  timetable: ToOne<Timetable>(),
  examSchedule: ToMany<ExamSchedule>(items: []),
  marks: ToMany<Mark>(items: []),
  capstoneAttendance: ToOne<CapstoneAttendance>(target: capstoneAttendance),
);

void main() {
  group('applyRefreshedUser', () {
    /// The bug this locks down: the saved row is built by copying relations
    /// across one by one, and the capstone was missing from that list. It was
    /// written to in-memory state but never to the box, so it survived the
    /// session and vanished on restart.
    test('carries a newly fetched capstone onto the stored row', () {
      final existing = user(id: 1);
      final refreshed = user(capstoneAttendance: capstone());

      applyRefreshedUser(existing, refreshed);

      expect(existing.capstoneAttendance.target, isNotNull);
      expect(existing.capstoneAttendance.target!.title, 'Capstone');
      expect(existing.capstoneAttendance.target!.punches, hasLength(1));
    });

    test('replaces a capstone that was already stored', () {
      final existing = user(id: 1, capstoneAttendance: capstone(title: 'SDP'));
      final refreshed = user(capstoneAttendance: capstone(title: 'Capstone'));

      applyRefreshedUser(existing, refreshed);

      expect(existing.capstoneAttendance.target!.title, 'Capstone');
    });

    test('clears the capstone when the refresh came back without one', () {
      final existing = user(id: 1, capstoneAttendance: capstone());
      final refreshed = user();

      applyRefreshedUser(existing, refreshed);

      // Absent beats stale: the card returns on the next good refresh.
      expect(existing.capstoneAttendance.target, isNull);
    });

    test('replaces the attendance list rather than appending to it', () {
      final existing = user(id: 1, attendances: [attendance('CSE1008')]);
      final refreshed = user(attendances: [attendance('CSE4004')]);

      applyRefreshedUser(existing, refreshed);

      expect(existing.attendance, hasLength(1));
      expect(existing.attendance.first.courseCode, 'CSE4004');
    });

    test('keeps the stored row, so its id is not disturbed', () {
      final existing = user(id: 7);

      applyRefreshedUser(existing, user(capstoneAttendance: capstone()));

      expect(existing.id, 7);
    });
  });
}
