import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/grade_view/model/grade_view_course.dart';
import 'package:vit_ap_student_app/features/grade_view/repository/grade_view_remote_repository.dart';

part 'grade_view_viewmodel.g.dart';

@riverpod
class GradeViewViewmodel extends _$GradeViewViewmodel {
  late GradeViewRemoteRepository _repository;

  @override
  AsyncValue<List<GradeViewCourseModel>>? build() {
    _repository = ref.watch(gradeViewRemoteRepositoryProvider);
    return null;
  }

  /// Fetches the graded courses for [semesterId]. The user picks the semester
  /// from the grade view dropdown, so it is passed in rather than taken from
  /// the saved credentials (grades are usually viewed for a past semester).
  Future<void> fetchGrades({required String semesterId}) async {
    state = const AsyncValue.loading();

    // Demo mode: serve bundled sample grades.
    if (DemoService.isDemoMode) {
      state = AsyncValue.data(await DemoService.instance.gradeView());
      return;
    }

    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
        'User not found. Please Logout and Login.',
        StackTrace.current,
      );
      return;
    }

    final res = await _repository.fetchGradeView(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: semesterId,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final courses)) {
      state = AsyncValue.data(courses);
    }
  }

  void reset() {
    state = null;
  }
}
