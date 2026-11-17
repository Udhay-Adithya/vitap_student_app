import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/digital_assignment_remote_repository.dart';

/// Digital assignments for the demo account. The list comes from the bundled
/// dataset; uploads and downloads would need VTOP and are refused.
class DemoDigitalAssignmentRepository
    implements DigitalAssignmentRemoteRepository {
  DemoDigitalAssignmentRepository(this._demo);

  final DemoService _demo;

  @override
  Future<Either<Failure, List<DigitalAssignment>>> fetchDigitalAssignments({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) => serveDemo(_demo.digitalAssignments);

  @override
  Future<Either<Failure, String>> uploadDigitalAssignment({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String classId,
    required String mode,
    required String fileName,
    required List<int> fileBytes,
  }) => unavailableInDemo();

  @override
  Future<Either<Failure, String>> uploadDigitalAssignmentWithOtp({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String otpEmail,
  }) => unavailableInDemo();

  @override
  Future<Either<Failure, Uint8List>> downloadAssignmentFile({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String downloadPath,
  }) => unavailableInDemo();
}
