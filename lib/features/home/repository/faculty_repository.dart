import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/exceptions.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/home/model/faculty.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/types/faculty.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/vtop_errors.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'faculty_repository.g.dart';

@riverpod
FacultyRepository facultyRepository(Ref ref) {
  final vtopService = serviceLocator<VtopClientService>();
  return FacultyRepository(vtopService);
}

class FacultyRepository {
  final VtopClientService _vtopService;

  FacultyRepository(this._vtopService);

  /// Loads the full list of faculty members from the bundled asset file
  /// (`assets/faculty_list.json`). No network request is needed.
  Future<Either<Failure, List<FacultyListItem>>> fetchFacultyList() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/faculty_list.json');
      return Right(facultyListFromJson(jsonStr));
    } on FormatException catch (e) {
      debugPrint('Faculty list JSON parsing failed: ${e.toString()}');
      return Left(Failure('Invalid faculty list data'));
    } catch (e) {
      debugPrint('Error loading faculty list from assets: ${e.toString()}');
      return Left(Failure('Could not load faculty list. Please try again.'));
    }
  }

  /// Fetches full profile details for a single faculty member by their
  /// employee ID. Call this when the user taps on a faculty list item.
  Future<Either<Failure, FacultyDetails>> fetchFacultyDetails({
    required String registrationNumber,
    required String password,
    required String empId,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: '',
      );
      final result = await _vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) =>
            vtop.fetchFacultyData(client: client, empId: empId),
      );
      return Right(result);
    } on SocketException {
      return Left(Failure('No internet connection'));
    } on VtopError catch (rustError) {
      final msg = await VtopException.getFailureMessage(rustError);
      return Left(Failure(msg));
    } catch (e) {
      debugPrint('Error fetching faculty details: ${e.toString()}');
      return Left(Failure('An unexpected error occurred. Please try again.'));
    }
  }
}
