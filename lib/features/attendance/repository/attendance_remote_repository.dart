import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/error/failure_from.dart';
import 'package:vit_ap_student_app/core/models/attendance.dart';
import 'package:vit_ap_student_app/core/models/capstone_attendance.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/attendance/model/attendance_detail.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'attendance_remote_repository.g.dart';

/// What one attendance fetch yields.
///
/// The two arrive together because a single load of the attendance page decides
/// both: the page itself says whether the student has a capstone, and only then
/// is the capstone request made.
typedef AttendanceFetch = ({
  List<Attendance> attendances,
  CapstoneAttendance? capstone,
});

@riverpod
AttendanceRemoteRepository attendanceRemoteRepository(Ref ref) {
  final vtopService = serviceLocator<VtopClientService>();
  return AttendanceRemoteRepository(vtopService);
}

class AttendanceRemoteRepository {
  final VtopClientService vtopService;

  AttendanceRemoteRepository(this.vtopService);

  /// Fetch attendance data with automatic session management and retry
  /// This method demonstrates the new robust approach to handling VTOP requests
  Future<Either<Failure, AttendanceFetch>> fetchAttendance({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );

      // Use the new executeWithRetry method for robust session handling
      final attendanceRecords = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchAttendanceWithCapstone(
          client: client,
          semesterId: semSubId,
        ),
      );

      final payload = json.decode(attendanceRecords) as Map<String, dynamic>;
      final capstone = payload['capstone'] as Map<String, dynamic>?;

      return Right((
        attendances: (payload['records'] as List<dynamic>)
            .map((dynamic e) => Attendance.fromJson(e as Map<String, dynamic>))
            .toList(),
        // Null for the majority of students, who have no capstone registration.
        capstone:
            capstone == null ? null : CapstoneAttendance.fromJson(capstone),
      ));
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to fetch attendance: $error',
        ),
      );
    }
  }

  /// Fetch detailed attendance with automatic session management and retry
  Future<Either<Failure, List<AttendanceDetail>>> fetchDetailedAttendance({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String courseId,
    required String courseType,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );

      // Use the new executeWithRetry method for robust session handling
      final attendanceRecords = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchAttendanceDetail(
          client: client,
          semesterId: semSubId,
          courseId: courseId,
          courseType: courseType,
        ),
      );

      debugPrint(attendanceRecords);
      return Right(attendanceDetailFromJson(attendanceRecords));
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to fetch detailed attendance: $error',
        ),
      );
    }
  }

  /// Legacy method - kept for backward compatibility but marked for migration
  /// @deprecated Use fetchAttendance instead which has better session handling
  @Deprecated('Use fetchAttendance with the new session management')
  Future<Either<Failure, List<Attendance>>> fetchAttendanceLegacy({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );

      // Use the new executeWithRetry method for robust session handling
      final attendanceRecords = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchAttendance(
          client: client,
          semesterId: semSubId,
        ),
      );
      return Right(attendanceFromJson(attendanceRecords));
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to fetch attendance: $error',
        ),
      );
    }
  }
}
