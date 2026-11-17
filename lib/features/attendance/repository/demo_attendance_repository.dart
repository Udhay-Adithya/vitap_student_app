import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/models/attendance.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/attendance/model/attendance_detail.dart';
import 'package:vit_ap_student_app/features/attendance/repository/attendance_remote_repository.dart';

/// Attendance for the demo account, from the bundled dataset.
class DemoAttendanceRepository implements AttendanceRemoteRepository {
  DemoAttendanceRepository(this._demo);

  final DemoService _demo;

  @override
  Future<Either<Failure, AttendanceFetch>> fetchAttendance({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) => serveDemo(() async {
    final user = await _demo.loadDemoUser();
    return (
      attendances: user.attendance.toList(),
      capstone: user.capstoneAttendance.target,
    );
  });

  @override
  Future<Either<Failure, List<AttendanceDetail>>> fetchDetailedAttendance({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String courseId,
    required String courseType,
  }) => serveDemo(_demo.detailedAttendance);

  @override
  Future<Either<Failure, List<Attendance>>> fetchAttendanceLegacy({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) => serveDemo(() async => (await _demo.loadDemoUser()).attendance.toList());
}
