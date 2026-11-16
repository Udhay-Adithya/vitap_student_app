import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/error/failure_from.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/course_page/model/course_page_detail.dart';
import 'package:vit_ap_student_app/features/course_page/model/courses_response.dart';
import 'package:vit_ap_student_app/features/course_page/model/slots_response.dart';
import 'package:vit_ap_student_app/features/course_page/repository/demo_course_page_repository.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'course_page_remote_repository.g.dart';

@riverpod
CoursePageRemoteRepository coursePageRemoteRepository(Ref ref) {
  final vtopService = ref.watch(vtopClientServiceProvider);
  if (ref.watch(demoModeProvider)) {
    return DemoCoursePageRepository(ref.watch(demoServiceProvider));
  }
  return VtopCoursePageRepository(vtopService);
}

abstract interface class CoursePageRemoteRepository {
  /// Fetch courses available for course page
  Future<Either<Failure, CoursesResponseModel>> fetchCoursesForCoursePage({
    required String registrationNumber,
    required String password,
    required String semSubId,
  });

  /// Fetch slots/class entries for a specific course
  Future<Either<Failure, SlotsResponseModel>> fetchSlotsForCoursePage({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String classId,
  });

  /// Fetch course detail with lectures and materials
  Future<Either<Failure, CoursePageDetailModel>> fetchCourseDetail({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String erpId,
    required String classId,
  });

  /// Download course material (PDF, document, etc.)
  Future<Either<Failure, Uint8List>> downloadCourseMaterial({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String downloadPath,
  });

  /// Download all course materials as ZIP
  Future<Either<Failure, Uint8List>> downloadAllCourseMaterials({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String downloadPath,
  });

  /// Download course syllabus
  Future<Either<Failure, Uint8List>> downloadCourseSyllabus({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String courseId,
    required String courseType,
  });
}

class VtopCoursePageRepository implements CoursePageRemoteRepository {
  final VtopClientService vtopService;

  VtopCoursePageRepository(this.vtopService);

  @override
  Future<Either<Failure, CoursesResponseModel>> fetchCoursesForCoursePage({
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
        operation: (client) => vtop.fetchCoursesForCoursePage(
          client: client,
          semesterId: semSubId,
        ),
      );

      return Right(coursesResponseFromJson(coursesJson));
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to fetch courses: $error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, SlotsResponseModel>> fetchSlotsForCoursePage({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String classId,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );

      final slotsJson = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchSlotsForCoursePage(
          client: client,
          semesterId: semSubId,
          classId: classId,
        ),
      );

      return Right(slotsResponseFromJson(slotsJson));
    } catch (e) {
      return Left(
        failureFrom(e, unexpected: (error) => 'Failed to fetch slots: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, CoursePageDetailModel>> fetchCourseDetail({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String erpId,
    required String classId,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );

      final detailJson = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchCourseDetail(
          client: client,
          semesterId: semSubId,
          erpId: erpId,
          classId: classId,
        ),
      );

      return Right(coursePageDetailFromJson(detailJson));
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to fetch course detail: $error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Uint8List>> downloadCourseMaterial({
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
        operation: (client) => vtop.downloadCourseMaterial(
          client: client,
          downloadPath: downloadPath,
        ),
      );

      return Right(bytes);
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to download material: $error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Uint8List>> downloadAllCourseMaterials({
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
        operation: (client) => vtop.downloadAllCourseMaterials(
          client: client,
          downloadPath: downloadPath,
        ),
      );

      return Right(bytes);
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to download materials: $error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Uint8List>> downloadCourseSyllabus({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String courseId,
    required String courseType,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );

      final bytes = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.downloadCourseSyllabus(
          client: client,
          courseId: courseId,
          courseType: courseType,
        ),
      );

      return Right(bytes);
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => 'Failed to download syllabus: $error',
        ),
      );
    }
  }
}
