import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/error/failure_from.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/exam_schedule.dart';
import 'package:vit_ap_student_app/core/models/mark.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/home/model/biometric.dart';
import 'package:vit_ap_student_app/features/home/model/payment_receipt.dart';
import 'package:vit_ap_student_app/features/home/model/pending_payment.dart';
import 'package:vit_ap_student_app/features/home/model/weather.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'home_remote_repository.g.dart';

@riverpod
HomeRemoteRepository homeRemoteRepository(Ref ref) {
  final client = serviceLocator<http.Client>();
  final vtopService = serviceLocator<VtopClientService>();
  return HomeRemoteRepository(client, vtopService);
}

class HomeRemoteRepository {
  final http.Client client;
  final VtopClientService vtopService;

  HomeRemoteRepository(this.client, this.vtopService);

  Future<Either<Failure, Weather>> fetchWeather() async {
    try {
      final response = await client.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=16.51&longitude=80.51&hourly=temperature_2m,apparent_temperature,rain,weather_code,uv_index&daily=temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=1&models=best_match',
        ),
      );

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(resBodyMap['detail'] as String));
      }

      return Right(Weather.fromJson(resBodyMap));
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<Biometric>>> fetchBiometric({
    required String registrationNumber,
    required String password,
    required String date,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: '', // Not needed for biometric data
      );

      // Use the new executeWithRetry method for robust session handling
      final biometricRecords = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) =>
            vtop.fetchBiometricData(client: client, date: date),
      );

      return Right(biometricFromJson(biometricRecords));
    } catch (e) {
      return Left(failureFrom(e));
    }
  }

  Future<Either<Failure, List<Mark>>> fetchMarks({
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
      final marksRecord = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) =>
            vtop.fetchMarks(client: client, semesterId: semSubId),
      );

      return Right(markFromJson(marksRecord));
    } catch (e) {
      return Left(failureFrom(e));
    }
  }

  Future<Either<Failure, List<ExamSchedule>>> fetchExamSchedule({
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
      final examRecords = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) =>
            vtop.fetchExamShedule(client: client, semesterId: semSubId),
      );

      return Right(examScheduleFromJson(examRecords));
    } catch (e) {
      return Left(failureFrom(e));
    }
  }

  Future<Either<Failure, List<PendingPayment>>> fetchPendingPayments({
    required String registrationNumber,
    required String password,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: '',
      );

      // Use the new executeWithRetry method for robust session handling
      final pendingPaymentRecords = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchPendingPayments(client: client),
      );

      return Right(pendingPaymentFromJson(pendingPaymentRecords));
    } catch (e) {
      return Left(failureFrom(e));
    }
  }

  Future<Either<Failure, List<PaymentReceipt>>> fetchPaymentReceipts({
    required String registrationNumber,
    required String password,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: '',
      );

      // Use the new executeWithRetry method for robust session handling
      final paymentRecords = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchPaymentReceipts(client: client),
      );

      return Right(paymentReceiptFromJson(paymentRecords));
    } catch (e) {
      return Left(failureFrom(e));
    }
  }
}
