import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/error/failure_from.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/home/model/faculty.dart';
import 'package:vit_ap_student_app/features/home/repository/demo_faculty_repository.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/types/faculty.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'faculty_repository.g.dart';

@riverpod
FacultyRepository facultyRepository(Ref ref) {
  final vtopService = ref.watch(vtopClientServiceProvider);
  final live = VtopFacultyRepository(vtopService);
  return ref.watch(demoModeProvider)
      ? DemoFacultyRepository(DemoService.instance, live)
      : live;
}

abstract interface class FacultyRepository {
  /// Loads the full list of faculty members from the bundled asset file
  /// (`assets/faculty_list.json`). No network request is needed.
  Future<Either<Failure, List<FacultyListItem>>> fetchFacultyList();

  /// Fetches full profile details for a single faculty member by their
  /// employee ID. Call this when the user taps on a faculty list item.
  Future<Either<Failure, FacultyDetails>> fetchFacultyDetails({
    required String registrationNumber,
    required String password,
    required String empId,
  });
}

class VtopFacultyRepository implements FacultyRepository {
  final VtopClientService _vtopService;

  VtopFacultyRepository(this._vtopService);

  @override
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

  @override
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
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (_) => 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }
}
