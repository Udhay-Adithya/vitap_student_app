import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
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

/// Provides the "Demo Login" experience used for App Store review and product
/// demonstrations.
///
/// When the predefined demo credentials are entered on the login screen, the
/// app bypasses the entire VTOP authentication flow (including OTP) and seeds
/// itself from a locally bundled, fully sanitized dataset
/// (`assets/demo/demo_dataset.json`). No real student data is ever exposed and
/// no network request reaches VTOP while demo mode is active.
///
/// [isDemoMode] is cached in memory (so it can be read synchronously from hot
/// paths like [VtopClientService.getClient] and feature view models) and
/// persisted in [SharedPreferences] so the demo survives app restarts. Call
/// [init] once during dependency setup to hydrate the cached flag.
class DemoService {
  DemoService._();

  static final DemoService instance = DemoService._();

  /// Registration number reviewers enter to trigger the demo experience.
  static const String demoRegistrationNumber = '21BCE7625';

  /// Password reviewers enter to trigger the demo experience.
  static const String demoPassword = 'Demo@1234';

  /// Placeholder semester id stored alongside the demo credentials.
  static const String demoSemesterId = 'DEMOSEM2526';

  static const String _prefsKey = 'is_demo_mode';
  static const String _assetPath = 'assets/demo/demo_dataset.json';

  bool _isDemoMode = false;
  Map<String, dynamic>? _cache;

  /// Whether the app is currently running as the demo account.
  static bool get isDemoMode => instance._isDemoMode;

  /// Hydrate the cached demo flag from persistent storage. Safe to call once
  /// during app initialization.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    instance._isDemoMode = prefs.getBool(_prefsKey) ?? false;
  }

  /// Returns true when the supplied credentials match the demo account.
  bool isDemoCredentials(String username, String password) =>
      username.trim().toUpperCase() == demoRegistrationNumber &&
      password.trim() == demoPassword;

  /// Credentials persisted for the demo session so the rest of the app treats
  /// the demo user like any other logged-in user.
  Credentials get credentials => Credentials(
        registrationNumber: demoRegistrationNumber,
        password: demoPassword,
        semSubId: demoSemesterId,
      );

  /// Enable or disable demo mode, updating both the cached flag and persistent
  /// storage. Disabling also drops the in-memory dataset cache.
  Future<void> setDemoMode(bool value) async {
    _isDemoMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
    if (!value) _cache = null;
  }

  Future<Map<String, dynamic>> _dataset() async {
    _cache ??= json.decode(await rootBundle.loadString(_assetPath))
        as Map<String, dynamic>;
    return _cache!;
  }

  Future<T> _section<T>(
    String key,
    T Function(Object? value) parse,
  ) async {
    final data = await _dataset();
    return parse(data[key]);
  }

  // --- Primary data (seeded into the User at login) -------------------------

  /// The full demo [User] used to seed local storage at login. Screens read
  /// profile, timetable, attendance, marks and exam schedule from this.
  Future<User> loadDemoUser() =>
      _section('user', (v) => User.fromJson(v as Map<String, dynamic>));

  // --- Secondary read-only feature data -------------------------------------

  Future<List<AttendanceDetail>> detailedAttendance() => _section(
        'detailed_attendance',
        (v) => (v as List<dynamic>)
            .map((e) => AttendanceDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<List<Biometric>> biometric() => _section(
        'biometric',
        (v) => (v as List<dynamic>)
            .map((e) => Biometric.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<List<PendingPayment>> pendingPayments() => _section(
        'pending_payments',
        (v) => (v as List<dynamic>)
            .map((e) => PendingPayment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<List<PaymentReceipt>> paymentReceipts() => _section(
        'payment_receipts',
        (v) => (v as List<dynamic>)
            .map((e) => PaymentReceipt.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<List<GeneralOutingReport>> generalOutingReports() => _section(
        'general_outing_reports',
        (v) => (v as List<dynamic>)
            .map((e) => GeneralOutingReport.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<List<WeekendOutingReport>> weekendOutingReports() => _section(
        'weekend_outing_reports',
        (v) => (v as List<dynamic>)
            .map((e) => WeekendOutingReport.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<FacultyDetails> facultyDetails() => _section(
        'faculty_details',
        (v) => FacultyDetails.fromJson(v as Map<String, dynamic>),
      );

  Future<CoursesResponseModel> courses() => _section(
        'courses',
        (v) => CoursesResponseModel.fromJson(v as Map<String, dynamic>),
      );

  Future<SlotsResponseModel> slots() => _section(
        'slots',
        (v) => SlotsResponseModel.fromJson(v as Map<String, dynamic>),
      );

  Future<CoursePageDetailModel> courseDetail() => _section(
        'course_detail',
        (v) => CoursePageDetailModel.fromJson(v as Map<String, dynamic>),
      );

  Future<List<DigitalAssignment>> digitalAssignments() => _section(
        'digital_assignments',
        (v) => (v as List<dynamic>)
            .map((e) => DigitalAssignment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
