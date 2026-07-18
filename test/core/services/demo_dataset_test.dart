import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/features/attendance/model/attendance_detail.dart';
import 'package:vit_ap_student_app/features/course_page/model/course_page_detail.dart';
import 'package:vit_ap_student_app/features/course_page/model/courses_response.dart';
import 'package:vit_ap_student_app/features/course_page/model/slots_response.dart';
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/features/home/model/biometric.dart';
import 'package:vit_ap_student_app/features/home/model/general_outing_report.dart';
import 'package:vit_ap_student_app/features/home/model/payment_receipt.dart';
import 'package:vit_ap_student_app/features/home/model/pending_payment.dart';
import 'package:vit_ap_student_app/features/home/model/weekend_outing_report.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/types/faculty.dart';

/// Validates that the bundled demo dataset deserializes cleanly against every
/// model DemoService feeds it into. This is the demo login's contract: if any
/// key drifts from a model's `fromJson`, the reviewer would hit a broken
/// screen, so we fail fast here instead.
void main() {
  late Map<String, dynamic> data;

  setUpAll(() {
    final file = File('assets/demo/demo_dataset.json');
    data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
  });

  test('user (profile/timetable/attendance/marks/exam) parses', () {
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    expect(user.profile.target, isNotNull);
    expect(user.profile.target!.studentName, isNotEmpty);
    expect(user.timetable.target, isNotNull);
    expect(user.attendance, isNotEmpty);
    expect(user.marks, isNotEmpty);
    expect(user.examSchedule, isNotEmpty);
  });

  test('detailed attendance parses', () {
    final list = (data['detailed_attendance'] as List<dynamic>)
        .map((e) => AttendanceDetail.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(list, isNotEmpty);
  });

  test('biometric parses', () {
    final list = (data['biometric'] as List<dynamic>)
        .map((e) => Biometric.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(list, isNotEmpty);
  });

  test('pending payments parse', () {
    final list = (data['pending_payments'] as List<dynamic>)
        .map((e) => PendingPayment.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(list, isNotEmpty);
  });

  test('payment receipts parse', () {
    final list = (data['payment_receipts'] as List<dynamic>)
        .map((e) => PaymentReceipt.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(list, isNotEmpty);
  });

  test('general outing reports parse', () {
    final list = (data['general_outing_reports'] as List<dynamic>)
        .map((e) => GeneralOutingReport.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(list, isNotEmpty);
  });

  test('weekend outing reports parse (incl. DateTime)', () {
    final list = (data['weekend_outing_reports'] as List<dynamic>)
        .map((e) => WeekendOutingReport.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(list, isNotEmpty);
    expect(list.first.date, isA<DateTime>());
  });

  test('faculty details parse', () {
    final details =
        FacultyDetails.fromJson(data['faculty_details'] as Map<String, dynamic>);
    expect(details.name, isNotEmpty);
    expect(details.officeHours, isNotEmpty);
  });

  test('courses parse', () {
    final res =
        CoursesResponseModel.fromJson(data['courses'] as Map<String, dynamic>);
    expect(res.courses, isNotEmpty);
  });

  test('slots parse', () {
    final res =
        SlotsResponseModel.fromJson(data['slots'] as Map<String, dynamic>);
    expect(res.slots, isNotEmpty);
    expect(res.classEntries, isNotEmpty);
  });

  test('course detail parses', () {
    final detail = CoursePageDetailModel.fromJson(
        data['course_detail'] as Map<String, dynamic>);
    expect(detail.courseInfo.courseCode, isNotEmpty);
    expect(detail.lectures, isNotEmpty);
  });

  test('digital assignments parse', () {
    final list = (data['digital_assignments'] as List<dynamic>)
        .map((e) => DigitalAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(list, isNotEmpty);
    expect(list.first.details, isNotEmpty);
  });
}
