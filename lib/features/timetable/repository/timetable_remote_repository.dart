import 'dart:async';
import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/error/failure_from.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'timetable_remote_repository.g.dart';

@riverpod
TimetableRemoteRepository timetableRemoteRepository(Ref ref) {
  final vtopService = serviceLocator<VtopClientService>();
  return TimetableRemoteRepository(vtopService);
}

class TimetableRemoteRepository {
  final VtopClientService vtopService;

  TimetableRemoteRepository(this.vtopService);

  /// Fetch timetable data with enhanced session management and automatic retry
  Future<Either<Failure, Timetable>> fetchTimetable({
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
      final timetableRecords = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchTimetable(
          client: client,
          semesterId: semSubId,
        ),
      );

      final resBodyMap = jsonDecode(timetableRecords) as Map<String, dynamic>;
      return Right(Timetable.fromJson(resBodyMap));
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to fetch timetable: $error',
        ),
      );
    }
  }
}
