import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/error/failure_from.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/providers/http_client.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/home/model/general_outing_report.dart';
import 'package:vit_ap_student_app/features/home/model/weekend_outing_report.dart';
import 'package:vit_ap_student_app/features/home/repository/demo_outing_repository.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'outing_remote_repository.g.dart';

@riverpod
OutingRemoteRepository outingRemoteRepository(Ref ref) {
  final client = ref.watch(httpClientProvider);
  final vtopService = ref.watch(vtopClientServiceProvider);
  if (ref.watch(demoModeProvider)) {
    return DemoOutingRepository(ref.watch(demoServiceProvider));
  }
  return VtopOutingRepository(client, vtopService);
}

abstract interface class OutingRemoteRepository {
  Future<Either<Failure, List<GeneralOutingReport>>> fetchGeneralOutingReports({
    required String registrationNumber,
    required String password,
  });

  Future<Either<Failure, List<WeekendOutingReport>>> fetchWeekendOutingReports({
    required String registrationNumber,
    required String password,
  });

  Future<Either<Failure, Uint8List>> downloadWeekendOutingReport({
    required String registrationNumber,
    required String password,
    required String leaveId,
  });

  Future<Either<Failure, Uint8List>> downloadGeneralOutingReport({
    required String registrationNumber,
    required String password,
    required String leaveId,
  });

  Future<Either<Failure, String>> submitGeneralOutingForm({
    required String registrationNumber,
    required String password,
    required String outPlace,
    required String purposeOfVisit,
    required String outingDate,
    required String outTime,
    required String inDate,
    required String inTime,
  });

  Future<Either<Failure, String>> submitWeekendOutingForm({
    required String registrationNumber,
    required String password,
    required String outPlace,
    required String purposeOfVisit,
    required String outingDate,
    required String outTime,
    required String contactNumber,
  });

  Future<Either<Failure, String>> deleteGeneralOuting({
    required String registrationNumber,
    required String password,
    required String leaveId,
  });

  Future<Either<Failure, String>> deleteWeekendOuting({
    required String registrationNumber,
    required String password,
    required String bookingId,
  });
}

class VtopOutingRepository implements OutingRemoteRepository {
  final http.Client client;
  final VtopClientService vtopService;

  VtopOutingRepository(this.client, this.vtopService);

  @override
  Future<Either<Failure, List<GeneralOutingReport>>> fetchGeneralOutingReports({
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
      final generalOutingRecords = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchGeneralOutingReports(client: client),
      );

      return Right(generalOutingReportFromJson(generalOutingRecords));
    } catch (e) {
      return Left(failureFrom(e));
    }
  }

  @override
  Future<Either<Failure, List<WeekendOutingReport>>> fetchWeekendOutingReports({
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
      final generalOutingRecords = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchWeekendOutingReports(client: client),
      );

      log(generalOutingRecords);

      return Right(weekendOutingReportFromJson(generalOutingRecords));
    } catch (e) {
      return Left(failureFrom(e));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> downloadWeekendOutingReport({
    required String registrationNumber,
    required String password,
    required String leaveId,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: '',
      );

      // Use the new executeWithRetry method for robust session handling
      final weekendOutingReport = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) =>
            vtop.fetchWeekendOutingPdf(client: client, bookingId: leaveId),
      );

      return Right(weekendOutingReport);
    } catch (e) {
      return Left(failureFrom(e));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> downloadGeneralOutingReport({
    required String registrationNumber,
    required String password,
    required String leaveId,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: '',
      );

      // Use the new executeWithRetry method for robust session handling
      final generalOutingReport = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) =>
            vtop.fetchGeneralOutingPdf(client: client, leaveId: leaveId),
      );

      return Right(generalOutingReport);
    } catch (e) {
      return Left(failureFrom(e));
    }
  }

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
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: '',
      );

      final response = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.submitGeneralOutingForm(
          client: client,
          outPlace: outPlace,
          purposeOfVisit: purposeOfVisit,
          outingDate: outingDate,
          outTime: outTime,
          inDate: inDate,
          inTime: inTime,
        ),
      );

      return Right(response);
    } catch (e) {
      return Left(failureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> submitWeekendOutingForm({
    required String registrationNumber,
    required String password,
    required String outPlace,
    required String purposeOfVisit,
    required String outingDate,
    required String outTime,
    required String contactNumber,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: '',
      );

      final response = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.submitWeekendOutingForm(
          client: client,
          outPlace: outPlace,
          purposeOfVisit: purposeOfVisit,
          outingDate: outingDate,
          outTime: outTime,
          contactNumber: contactNumber,
        ),
      );

      return Right(response);
    } catch (e) {
      return Left(failureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> deleteGeneralOuting({
    required String registrationNumber,
    required String password,
    required String leaveId,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: '',
      );

      final response = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) =>
            vtop.deleteGeneralOuting(client: client, leaveId: leaveId),
      );

      return Right(response);
    } catch (e) {
      return Left(failureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> deleteWeekendOuting({
    required String registrationNumber,
    required String password,
    required String bookingId,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: '',
      );

      final response = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) =>
            vtop.deleteWeekendOuting(client: client, bookingId: bookingId),
      );

      return Right(response);
    } catch (e) {
      return Left(failureFrom(e));
    }
  }
}
