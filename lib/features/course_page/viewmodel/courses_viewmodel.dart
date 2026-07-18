import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/course_page/model/courses_response.dart';
import 'package:vit_ap_student_app/features/course_page/repository/course_page_remote_repository.dart';

part 'courses_viewmodel.g.dart';

@riverpod
class CoursesViewmodel extends _$CoursesViewmodel {
  late CoursePageRemoteRepository _repository;

  @override
  AsyncValue<CoursesResponseModel>? build() {
    _repository = ref.watch(coursePageRemoteRepositoryProvider);
    return null;
  }

  Future<void> fetchCourses() async {
    state = const AsyncValue.loading();

    // Demo mode: serve bundled sample course list.
    if (DemoService.isDemoMode) {
      state = AsyncValue.data(await DemoService.instance.courses());
      return;
    }

    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
          'User not found. Please Logout and Login.', StackTrace.current);
      return;
    }

    final res = await _repository.fetchCoursesForCoursePage(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final coursesResponse)) {
      state = AsyncValue.data(coursesResponse);
    }
  }

  void reset() {
    state = null;
  }
}
