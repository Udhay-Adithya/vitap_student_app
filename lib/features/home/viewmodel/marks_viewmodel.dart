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

      if (user != null) {
        for (final newMark in newMarks) {
          try {
            final oldMark = user.marks.firstWhere(
                    (m) => m.courseCode == newMark.courseCode && m.courseType == newMark.courseType
            );
            newMark.gradeStatsJson = oldMark.gradeStatsJson;
          } catch (_) {}
        }
      }

      final gradeRes = await _gradeViewRemoteRepository.fetchGradeView(
        registrationNumber: credentials.registrationNumber,
        password: credentials.password,
        semSubId: credentials.semSubId,
      );

      gradeRes.match(
            (_) => _purgeGrades(newMarks),
            (courses) {
          if (courses.isEmpty) {
            _purgeGrades(newMarks);
          } else {
            _mergeGrades(newMarks, courses);
          }
        },
      );

      state = AsyncValue.data(newMarks);
      if (user != null) {
        await userNotifier.updateUser(
          user.copyWith(marks: ToMany<Mark>(items: newMarks)),
        );
      }
    }
  }

  void _purgeGrades(List<Mark> marks) {
    for (final mark in marks) {
      mark.grade = null;
      mark.grandTotal = null;
      mark.gradeCourseId = null;
      mark.gradeStatsJson = null;
    }
  }

  void _mergeGrades(List<Mark> marks, List<GradeViewCourseModel> courses) {
    final Map<String, List<GradeViewCourseModel>> groupedCourses = {};
    for (final c in courses) {
      groupedCourses.putIfAbsent(c.courseCode.trim(), () => []).add(c);
    }

    for (final mark in marks) {
      final matchGroup = groupedCourses[mark.courseCode.trim()];
      if (matchGroup != null) {
        final validGrade = matchGroup.firstWhere(
              (c) => c.grade.trim().isNotEmpty && c.grade != '-',
          orElse: () => matchGroup.first,
        );
        final validId = matchGroup.firstWhere(
              (c) => c.courseId.trim().isNotEmpty,
          orElse: () => matchGroup.first,
        );
        final validTotal = matchGroup.firstWhere(
              (c) => c.grandTotal.trim().isNotEmpty && c.grandTotal != '-',
          orElse: () => matchGroup.first,
        );

        mark.grade = validGrade.grade.trim().isEmpty || validGrade.grade == '-' ? null : validGrade.grade;
        mark.grandTotal = validTotal.grandTotal.trim().isEmpty || validTotal.grandTotal == '-' ? null : validTotal.grandTotal;
        mark.gradeCourseId = validId.courseId.trim().isEmpty ? null : validId.courseId;
      } else {
        mark.grade = null;
        mark.grandTotal = null;
        mark.gradeCourseId = null;
        mark.gradeStatsJson = null;
      }
    }
  }

  /// Groups raw database rows into buckets by course code for the UI
  static List<List<Mark>> groupMarks(List<Mark> rawMarks) {
    final Map<String, List<Mark>> groupedMap = {};
    for (final mark in rawMarks) {
      groupedMap.putIfAbsent(mark.courseCode, () => []).add(mark);
    }

    final groupedLists = groupedMap.values.toList();

    // Sort courses alphabetically
    groupedLists.sort((a, b) => a.first.courseCode.compareTo(b.first.courseCode));

    // Enforce internal Theory -> Lab -> Project sort order for each card
    for (final components in groupedLists) {
      components.sort((a, b) {
        int weight(String type) {
          final t = type.toLowerCase();
          if (t.contains('theory')) return 1;
          if (t.contains('lab')) return 2;
          if (t.contains('project')) return 3;
          return 4;
        }
        return weight(a.courseType).compareTo(weight(b.courseType));
      });
    }

    return groupedLists;
  }
}