import 'package:fpdart/fpdart.dart';
import 'package:objectbox/objectbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/mark.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/grade_view/model/grade_view_course.dart';
import 'package:vit_ap_student_app/features/grade_view/repository/grade_view_remote_repository.dart';
import 'package:vit_ap_student_app/features/home/repository/home_remote_repository.dart';

part 'marks_viewmodel.g.dart';

@riverpod
class MarksViewModel extends _$MarksViewModel {
  late HomeRemoteRepository _homeRemoteRepository;
  late GradeViewRemoteRepository _gradeViewRemoteRepository;

  @override
  AsyncValue<List<Mark>>? build() {
    _homeRemoteRepository = ref.watch(homeRemoteRepositoryProvider);
    _gradeViewRemoteRepository = ref.watch(gradeViewRemoteRepositoryProvider);

    return null;
  }

  Future<void> refreshMarks() async {
    // Demo mode: serve the marks seeded into the user at login, with demo
    // grades merged in so the grade UI can be exercised.
    if (DemoService.isDemoMode) {
      final demoUser = ref.read(currentUserProvider);
      final marks = demoUser?.marks.toList() ?? [];
      _mergeGrades(marks, await DemoService.instance.gradeView());
      state = AsyncValue.data(marks);
      return;
    }

    state = const AsyncValue.loading();
    final User? user = ref.read(currentUserProvider);
    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error(
        'User not found. Please Logout and Login.',
        StackTrace.current,
      );
      return;
    }
    final res = await _homeRemoteRepository.fetchMarks(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final newMarks)) {
      // Fetch this semester's grades and merge them onto the marks. Grades are
      // published only at the end of a semester, so mid-semester this returns
      // an empty list and the grade fields stay null. A grade fetch failure is
      // non-fatal — the marks themselves still load.
      final gradeRes = await _gradeViewRemoteRepository.fetchGradeView(
        registrationNumber: credentials.registrationNumber,
        password: credentials.password,
        semSubId: credentials.semSubId,
      );
      gradeRes.match((_) => null, (courses) => _mergeGrades(newMarks, courses));

      state = AsyncValue.data(newMarks);
      if (user != null) {
        await userNotifier.updateUser(
          user.copyWith(marks: ToMany<Mark>(items: newMarks)),
        );
      }
    }
  }

  /// Attaches each course's grade, grand total and grade-view course id onto
  /// the matching [Mark], keyed by course code (one row per course in both).
  /// The class statistics are left for the detail page to fetch lazily.
  void _mergeGrades(List<Mark> marks, List<GradeViewCourseModel> courses) {
    final byCourseCode = {for (final c in courses) c.courseCode: c};
    for (final mark in marks) {
      final match = byCourseCode[mark.courseCode];
      if (match != null) {
        mark.grade = match.grade;
        mark.grandTotal = match.grandTotal;
        mark.gradeCourseId = match.courseId;
      }
    }
  }
}
