import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/course_page/model/course_page_detail.dart';
import 'package:vit_ap_student_app/features/course_page/model/courses_response.dart';
import 'package:vit_ap_student_app/features/course_page/model/slots_response.dart';
import 'package:vit_ap_student_app/features/course_page/repository/course_page_remote_repository.dart';

/// Course pages for the demo account. The listings come from the bundled
/// dataset; downloads would need VTOP and are refused.
class DemoCoursePageRepository implements CoursePageRemoteRepository {
  DemoCoursePageRepository(this._demo);

  final DemoService _demo;

  @override
  Future<Either<Failure, CoursesResponseModel>> fetchCoursesForCoursePage({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) => serveDemo(_demo.courses);

  @override
  Future<Either<Failure, SlotsResponseModel>> fetchSlotsForCoursePage({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String classId,
  }) => serveDemo(_demo.slots);

  @override
  Future<Either<Failure, CoursePageDetailModel>> fetchCourseDetail({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String erpId,
    required String classId,
  }) => serveDemo(_demo.courseDetail);

  @override
  Future<Either<Failure, Uint8List>> downloadCourseMaterial({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String downloadPath,
  }) => unavailableInDemo();

  @override
  Future<Either<Failure, Uint8List>> downloadAllCourseMaterials({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String downloadPath,
  }) => unavailableInDemo();

  @override
  Future<Either<Failure, Uint8List>> downloadCourseSyllabus({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String courseId,
    required String courseType,
  }) => unavailableInDemo();
}
