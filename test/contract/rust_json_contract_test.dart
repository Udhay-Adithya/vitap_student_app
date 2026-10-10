/// The Dart half of the bridge's JSON contract.
///
/// Most VTOP data crosses the bridge as a JSON string: Rust serializes a
/// struct, Dart decodes it here. Nothing in either language checks that the
/// two agree, so a renamed field compiles on both sides and reaches a student
/// as "Invalid response format from server".
///
/// These read the same committed fixtures as `rust/tests/json_contract_test.rs`
/// and decode them with the app's own models. Rename a field on either side
/// and that side's test fails in the pull request that did it.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/models/attendance.dart';
import 'package:vit_ap_student_app/core/models/capstone_attendance.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/features/home/model/general_outing_report.dart';
import 'package:vit_ap_student_app/features/home/model/weekend_outing_report.dart';

/// Raw text, so the decoders the app actually calls can be used as-is.
String fixtureText(String name) {
  final file = File('test_fixtures/contract/$name');
  if (!file.existsSync()) {
    fail(
      'Missing ${file.path}. It is shared with rust/tests/json_contract_test.rs '
      'and is meant to be committed.',
    );
  }
  return file.readAsStringSync();
}

Map<String, dynamic> fixtureObject(String name) =>
    jsonDecode(fixtureText(name)) as Map<String, dynamic>;

void main() {
  group('attendance', () {
    /// Mirrors how `AttendanceRemoteRepository.fetchAttendance` unpacks the
    /// payload: by hand, reading these two keys off the top level.
    test('decodes the records Rust sends', () {
      final payload = fixtureObject('attendance.json');

      final records = (payload['records'] as List<dynamic>)
          .map((dynamic e) => Attendance.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(records, hasLength(1));
      final record = records.single;
      expect(record.courseCode, 'CSE3009');
      expect(record.courseName, 'NoSQL Databases');
      expect(record.courseType, 'Embedded Theory');
      expect(record.courseTypeCode, 'ETH');
      expect(record.classNumber, 'AP2026272000101');
      expect(record.courseSlot, 'C1+TCC1');
      expect(record.faculty, 'Test Faculty - SCOPE');
      expect(record.attendedClasses, '23');
      expect(record.totalClasses, '25');
      expect(record.attendancePercentage, '92');
      expect(record.courseId, 'AM_CSE3009_00200');
      expect(record.debarStatus, '-');
    });

    /// `attendance_between_percentage` on the wire, `betweenAttendancePercentage`
    /// in Dart — the one field whose two names differ, so the mapping is the
    /// only thing holding it together.
    test('maps the between-percentage field across its rename', () {
      final payload = fixtureObject('attendance.json');
      final record = Attendance.fromJson(
        (payload['records'] as List<dynamic>).first as Map<String, dynamic>,
      );

      expect(record.betweenAttendancePercentage, '0');
    });

    /// Rust keeps the capstone in two nested structs and flattens it on the
    /// wire. The Dart model is flat, so a lost `#[serde(flatten)]` would leave
    /// every field here empty.
    test('decodes the flat capstone Rust sends', () {
      final payload = fixtureObject('attendance.json');

      final capstone = CapstoneAttendance.fromJson(
        payload['capstone'] as Map<String, dynamic>,
      );

      expect(capstone.title, 'A capstone project');
      expect(capstone.guideEvaluationStatus, 'Registered');
      expect(capstone.dateOfRegistration, '2026-07-06 00:00:00.0');
      expect(capstone.present, '14');
      expect(capstone.onDuty, '4');
      expect(capstone.absent, '2');
      expect(capstone.percentage, '90');
    });

    test('decodes the capstone punch calendar', () {
      final payload = fixtureObject('attendance.json');

      final capstone = CapstoneAttendance.fromJson(
        payload['capstone'] as Map<String, dynamic>,
      );

      expect(capstone.punches, hasLength(1));
      final punch = capstone.punches.first;
      expect(punch.serial, '1');
      expect(punch.date, '17-07-2026');
      expect(punch.day, 'FRIDAY');
      expect(punch.dayType, 'Instructional');
      expect(punch.status, 'Present');
      expect(punch.punchTime, '09:05');
    });
  });

  group('timetable', () {
    /// Rust renames its lowercase fields to `Monday`..`Sunday` to match the
    /// Dart model's keys. Lose that and every day decodes as empty.
    test('decodes the capitalised day keys Rust sends', () {
      final timetable = Timetable.fromJson(fixtureObject('timetable.json'));

      expect(timetable.monday, hasLength(1));
      expect(timetable.thursday, hasLength(1));
      expect(timetable.tuesday, isEmpty);
      expect(timetable.sunday, isEmpty);
    });

    test('decodes a class', () {
      final timetable = Timetable.fromJson(fixtureObject('timetable.json'));

      final slot = timetable.monday.single;
      expect(slot.startTime, '09:00');
      expect(slot.endTime, '09:50');
      expect(slot.courseName, 'NoSQL Databases');
      expect(slot.slot, 'C1');
      expect(slot.venue, '430');
      expect(slot.faculty, 'Test Faculty');
      expect(slot.courseCode, 'CSE3009');
      expect(slot.courseType, 'Embedded Theory');
    });
  });

  group('outing reports', () {
    test('decodes a general outing through the app decoder', () {
      final reports = generalOutingReportFromJson(
        fixtureText('general_outing.json'),
      );

      expect(reports, hasLength(1));
      final report = reports.single;
      expect(report.serial, '1');
      expect(report.registrationNumber, '23BCE0001');
      expect(report.placeOfVisit, 'Vijayawada');
      expect(report.purposeOfVisit, 'Shopping');
      expect(report.fromDate, '2026-01-12 00:00:00.0');
      expect(report.fromTime, '12:00 PM');
      expect(report.toDate, '2026-01-12 00:00:00.0');
      expect(report.toTime, '07:00 PM');
      expect(report.status, 'Leave Request Accepted');
      expect(report.leaveId, 'L2000001');
      expect(report.canDownload, isTrue);
    });

    test('decodes a weekend outing through the app decoder', () {
      final reports = weekendOutingReportFromJson(
        fixtureText('weekend_outing.json'),
      );

      expect(reports, hasLength(1));
      final report = reports.single;
      expect(report.serial, '1');
      expect(report.registrationNumber, '23BCE0001');
      expect(report.hostelBlock, 'MH-1');
      expect(report.roomNumber, '101');
      expect(report.placeOfVisit, 'Vijayawada');
      expect(report.purposeOfVisit, 'Shopping');
      expect(report.time, '10:30 AM- 4:30PM');
      expect(report.date, DateTime(2026, 7, 26));
      expect(report.bookingId, 'W26000000001');
      expect(report.status, 'Outing Request Accepted');
      expect(report.canDownload, isTrue);
    });

    /// The weekend `date` is the one field Dart does not keep as a string: the
    /// model parses it into a `DateTime`. So Rust has to keep sending a date
    /// `DateTime.parse` understands — VTOP's own `dd-MM-yyyy`, which it uses
    /// everywhere else, would throw inside the decode.
    test('sends a weekend date Dart can parse', () {
      final raw =
          jsonDecode(fixtureText('weekend_outing.json')) as List<dynamic>;
      final date = (raw.single as Map<String, dynamic>)['date'] as String;

      expect(DateTime.tryParse(date), isNotNull, reason: '$date is not ISO');
      expect(DateTime.parse(date), DateTime(2026, 7, 26));
    });

    /// The eleven-column weekend layout carries no contact numbers, so Rust
    /// sends empty strings and the Dart model has defaults for them.
    test('accepts a weekend outing with no contact numbers', () {
      final reports = weekendOutingReportFromJson(
        fixtureText('weekend_outing.json'),
      );

      expect(reports.single.contactNumber, '');
      expect(reports.single.parentContactNumber, '');
    });
  });
}
