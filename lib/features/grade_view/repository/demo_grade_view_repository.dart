import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/grade_view/model/grade_view_course.dart';
import 'package:vit_ap_student_app/features/grade_view/model/grade_view_detail.dart';
import 'package:vit_ap_student_app/features/grade_view/repository/grade_view_remote_repository.dart';

/// Grades for the demo account. The dataset carries one detail page, served
/// for whichever course is asked for.
class DemoGradeViewRepository implements GradeViewRemoteRepository {
  DemoGradeViewRepository(this._demo);

  final DemoService _demo;

  @override
  Future<Either<Failure, List<GradeViewCourseModel>>> fetchGradeView({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) => serveDemo(_demo.gradeView);

  @override
  Future<Either<Failure, GradeViewDetailModel>> fetchGradeViewDetail({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String courseId,
  }) => serveDemo(_demo.gradeViewDetail);
}
