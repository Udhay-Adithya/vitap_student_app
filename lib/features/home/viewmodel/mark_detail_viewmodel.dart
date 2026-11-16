import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/mark.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/grade_view/model/grade_view_detail.dart';
import 'package:vit_ap_student_app/features/grade_view/repository/grade_view_remote_repository.dart';

part 'mark_detail_viewmodel.g.dart';

/// Drives the class-statistics section of the mark detail page.
///
/// The letter grade and grand total already live on the [Mark] (merged in when
/// marks are refreshed). The class statistics (mean, SD, grade cutoffs) are
/// heavier — one request per course — so they are fetched lazily the first time
/// a course's detail page is opened, then cached onto the Mark so reopening the
/// page never refetches.
@riverpod
class MarkDetailViewModel extends _$MarkDetailViewModel {
  late GradeViewRemoteRepository _gradeViewRemoteRepository;

  @override
  AsyncValue<GradeStatisticsModel?>? build() {
    _gradeViewRemoteRepository = ref.watch(gradeViewRemoteRepositoryProvider);
    return null;
  }

  /// Ensures the class statistics for [mark] are available.
  ///
  /// Resolves immediately from cache when present, yields `null` for a course
  /// with no published grade, and otherwise fetches once and caches.
  Future<void> loadStats(Mark mark) async {
    // Already cached from a previous open.
    if (mark.gradeStatsJson != null) {
      state = AsyncValue.data(_decode(mark.gradeStatsJson!));
      return;
    }

    // Not graded yet (mid-semester), or no id to fetch with: no stats to show.
    if (mark.grade == null ||
        mark.gradeCourseId == null ||
        mark.gradeCourseId!.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();

    if (DemoService.isDemoMode) {
      final detail = await DemoService.instance.gradeViewDetail();
      mark.gradeStatsJson = jsonEncode(detail.statistics.toJson());
      state = AsyncValue.data(detail.statistics);
      return;
    }

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

    final res = await _gradeViewRemoteRepository.fetchGradeViewDetail(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
      courseId: mark.gradeCourseId!,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final detail)) {
      // Cache onto the Mark and persist, so the next open reads from cache.
      mark.gradeStatsJson = jsonEncode(detail.statistics.toJson());
      if (user != null) {
        await userNotifier.updateUser(user.copyWith(marks: user.marks));
      }
      state = AsyncValue.data(detail.statistics);
    }
  }

  GradeStatisticsModel _decode(String jsonStr) => GradeStatisticsModel.fromJson(
    json.decode(jsonStr) as Map<String, dynamic>,
  );
}
