import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/error/failure_from.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/grade_view/model/grade_view_course.dart';
import 'package:vit_ap_student_app/features/grade_view/model/grade_view_detail.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'grade_view_remote_repository.g.dart';

@riverpod
GradeViewRemoteRepository gradeViewRemoteRepository(Ref ref) {
  final vtopService = serviceLocator<VtopClientService>();
  return GradeViewRemoteRepository(vtopService);
}

class GradeViewRemoteRepository {
  final VtopClientService vtopService;

  GradeViewRemoteRepository(this.vtopService);

  /// Fetches the graded courses for a semester.
  ///
  /// Grades appear only once a semester has ended; the current semester
  /// returns an empty list until results are published.
  Future<Either<Failure, List<GradeViewCourseModel>>> fetchGradeView({
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

      final coursesJson = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) =>
            vtop.fetchGradeView(client: client, semesterId: semSubId),
      );

      return Right(gradeViewCoursesFromJson(coursesJson));
    } catch (e) {
      return Left(
        failureFrom(e, unexpected: (error) => 'Failed to fetch grades: $error'),
      );
    }
  }

  /// Fetches the mark breakdown and class statistics for a single course.
  Future<Either<Failure, GradeViewDetailModel>> fetchGradeViewDetail({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String courseId,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );

      final detailJson = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchGradeViewDetail(
          client: client,
          semesterId: semSubId,
          courseId: courseId,
        ),
      );

      return Right(gradeViewDetailFromJson(detailJson));
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to fetch grade details: $error',
        ),
      );
    }
  }
}
