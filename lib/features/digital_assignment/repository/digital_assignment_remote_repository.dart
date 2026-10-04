import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/error/failure_from.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/vtop_errors.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'digital_assignment_remote_repository.g.dart';

@riverpod
DigitalAssignmentRemoteRepository digitalAssignmentRemoteRepository(Ref ref) {
  final vtopService = serviceLocator<VtopClientService>();
  return DigitalAssignmentRemoteRepository(vtopService);
}

class DigitalAssignmentRemoteRepository {
  final VtopClientService vtopService;

  DigitalAssignmentRemoteRepository(this.vtopService);

  /// Fetch all digital assignments for a semester
  Future<Either<Failure, List<DigitalAssignment>>> fetchDigitalAssignments({
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

      final jsonString = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchDigitalAssignments(
          client: client,
          semesterId: semSubId,
        ),
      );

      log(jsonString);

      return Right(digitalAssignmentsFromJson(jsonString));
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to fetch digital assignments: $error',
        ),
      );
    }
  }

  /// Upload a digital assignment file
  Future<Either<Failure, String>> uploadDigitalAssignment({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String classId,
    required String mode,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );

      final result = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.uploadDigitalAssignment(
          client: client,
          classId: classId,
          mode: mode,
          fileName: fileName,
          fileBytes: fileBytes,
        ),
      );

      return Right(result);
    } on VtopError_DigitalAssignmentUploadOtpRequired {
      // Not a failure: the upload flow asks for the OTP when it sees this.
      return Left(Failure('OTP_REQUIRED'));
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to upload assignment: $error',
        ),
      );
    }
  }

  /// Complete upload with OTP verification
  Future<Either<Failure, String>> uploadDigitalAssignmentWithOtp({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String otpEmail,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );

      final result = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.uploadDigitalAssignmentWithOtp(
          client: client,
          otpEmail: otpEmail,
        ),
      );

      return Right(result);
    } on VtopError_DigitalAssignmentUploadIncorrectOtp {
      return Left(Failure('Incorrect OTP. Please try again.'));
    } catch (e) {
      return Left(
        failureFrom(e, unexpected: (error) => 'Failed to verify OTP: $error'),
      );
    }
  }

  /// Download a digital assignment file (question paper or submitted document)
  Future<Either<Failure, Uint8List>> downloadAssignmentFile({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String downloadPath,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );

      final bytes = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.downloadDigitalAssignment(
          client: client,
          downloadUrl: downloadPath,
        ),
      );

      return Right(bytes);
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to download file: $error',
        ),
      );
    }
  }
}
