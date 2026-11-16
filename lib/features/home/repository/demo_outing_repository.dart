import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/home/model/general_outing_report.dart';
import 'package:vit_ap_student_app/features/home/model/weekend_outing_report.dart';
import 'package:vit_ap_student_app/features/home/repository/outing_remote_repository.dart';

/// Outings for the demo account. Reports come from the bundled dataset;
/// applying, cancelling and downloading would need VTOP and are refused.
class DemoOutingRepository implements OutingRemoteRepository {
  DemoOutingRepository(this._demo);

  final DemoService _demo;

  @override
  Future<Either<Failure, List<GeneralOutingReport>>> fetchGeneralOutingReports({
    required String registrationNumber,
    required String password,
  }) => serveDemo(_demo.generalOutingReports);

  @override
  Future<Either<Failure, List<WeekendOutingReport>>> fetchWeekendOutingReports({
    required String registrationNumber,
    required String password,
  }) => serveDemo(_demo.weekendOutingReports);

  @override
  Future<Either<Failure, Uint8List>> downloadWeekendOutingReport({
    required String registrationNumber,
    required String password,
    required String leaveId,
  }) => unavailableInDemo();

  @override
  Future<Either<Failure, Uint8List>> downloadGeneralOutingReport({
    required String registrationNumber,
    required String password,
    required String leaveId,
  }) => unavailableInDemo();

  @override
  Future<Either<Failure, String>> submitGeneralOutingForm({
    required String registrationNumber,
    required String password,
    required String outPlace,
    required String purposeOfVisit,
    required String outingDate,
    required String outTime,
    required String inDate,
    required String inTime,
  }) => unavailableInDemo();

  @override
  Future<Either<Failure, String>> submitWeekendOutingForm({
    required String registrationNumber,
    required String password,
    required String outPlace,
    required String purposeOfVisit,
    required String outingDate,
    required String outTime,
    required String contactNumber,
  }) => unavailableInDemo();

  @override
  Future<Either<Failure, String>> deleteGeneralOuting({
    required String registrationNumber,
    required String password,
    required String leaveId,
  }) => unavailableInDemo();

  @override
  Future<Either<Failure, String>> deleteWeekendOuting({
    required String registrationNumber,
    required String password,
    required String bookingId,
  }) => unavailableInDemo();
}
