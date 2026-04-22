import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/exceptions.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/types/semester.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/vtop_errors.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'auth_remote_repository.g.dart';

@riverpod
AuthRemoteRepository authRemoteRepository(Ref ref) {
  final vtopService = serviceLocator<VtopClientService>();
  return AuthRemoteRepository(vtopService);
}

class AuthRemoteRepository {
  final VtopClientService vtopService;

  AuthRemoteRepository(this.vtopService);

  Future<Either<Failure, User>> login({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) async {
    try {
      final client = await vtopService.getClient(
        username: registrationNumber,
        password: password,
      );

      final response = await vtop.fetchAllData(
        client: client,
        semesterId: semSubId,
      );

      final resBodyMap = jsonDecode(response) as Map<String, dynamic>;
      return Right(User.fromJson(resBodyMap));
    } on SocketException {
      return Left(Failure('No internet connection'));
    } on VtopError catch (rustError) {
      final failureMessage = await VtopException.getFailureMessage(rustError);
      return Left(Failure(failureMessage));
    } on FormatException catch (e) {
      debugPrint('JSON parsing failed: ${e.toString()}');
      return Left(Failure('Invalid response format from server'));
    } catch (e) {
      debugPrint('Login failed: ${e.toString()}');
      return Left(Failure('An unexpected error occurred. Please try again.'));
    }
  }

  Future<Either<Failure, List<SemesterInfo>>> fetchSemesters({
    required String registrationNumber,
    required String password,
  }) async {
    try {
      final client = await vtopService.getClient(
        username: registrationNumber,
        password: password,
      );

      final response = await vtop.fetchSemesters(
        client: client,
      );
      return Right((response.semesters));
    } on SocketException {
      return Left(Failure('No internet connection'));
    } on VtopError catch (rustError) {
      final failureMessage = await VtopException.getFailureMessage(rustError);
      return Left(Failure(failureMessage));
    } on FormatException catch (e) {
      debugPrint('JSON parsing failed: ${e.toString()}');
      return Left(Failure('Invalid response format from server'));
    } catch (e) {
      debugPrint('Login failed: ${e.toString()}');
      return Left(Failure('An unexpected error occurred. Please try again.'));
    }
  }

  Future<Either<Failure, void>> submitLoginOtp(String otpCode) async {
    try {
      await vtopService.submitLoginOtp(otpCode);
      return const Right(null);
    } on VtopError catch (rustError) {
      final failureMessage = await VtopException.getFailureMessage(rustError);
      return Left(Failure(failureMessage));
    } catch (e) {
      debugPrint('OTP submit failed: ${e.toString()}');
      return Left(Failure('Failed to verify OTP. Please try again.'));
    }
  }

  Future<Either<Failure, void>> resendLoginOtp() async {
    try {
      await vtopService.resendLoginOtp();
      return const Right(null);
    } on OtpResendException catch (e) {
      return Left(Failure(e.message));
    } on VtopError catch (rustError) {
      final failureMessage = await VtopException.getFailureMessage(rustError);
      return Left(Failure(failureMessage));
    } catch (e) {
      debugPrint('OTP resend failed: ${e.toString()}');
      return Left(Failure('Failed to resend OTP. Please try again.'));
    }
  }
}
