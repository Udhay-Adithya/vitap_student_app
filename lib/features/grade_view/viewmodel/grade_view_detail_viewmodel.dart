import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/features/grade_view/model/grade_view_detail.dart';
import 'package:vit_ap_student_app/features/grade_view/repository/grade_view_remote_repository.dart';

part 'grade_view_detail_viewmodel.g.dart';

@riverpod
class GradeViewDetailViewmodel extends _$GradeViewDetailViewmodel {
  late GradeViewRemoteRepository _repository;

  @override
  AsyncValue<GradeViewDetailModel>? build() {
    _repository = ref.watch(gradeViewRemoteRepositoryProvider);
    return null;
  }

  /// Fetches the mark breakdown and class statistics for [courseId] in
  /// [semesterId]. This is the data behind an expanded grade tile.
  Future<void> fetchDetail({
    required String semesterId,
    required String courseId,
  }) async {
    state = const AsyncValue.loading();

    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
        'User not found. Please Logout and Login.',
        StackTrace.current,
      );
      return;
    }

    final res = await _repository.fetchGradeViewDetail(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: semesterId,
      courseId: courseId,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final detail)) {
      state = AsyncValue.data(detail);
    }
  }

  void reset() {
    state = null;
  }
}
