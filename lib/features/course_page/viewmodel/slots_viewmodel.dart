import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/course_page/model/slots_response.dart';
import 'package:vit_ap_student_app/features/course_page/repository/course_page_remote_repository.dart';

part 'slots_viewmodel.g.dart';

@riverpod
class SlotsViewmodel extends _$SlotsViewmodel {
  late CoursePageRemoteRepository _repository;

  @override
  AsyncValue<SlotsResponseModel>? build() {
    _repository = ref.watch(coursePageRemoteRepositoryProvider);
    return null;
  }

  Future<void> fetchSlots({required String classId}) async {
    state = const AsyncValue.loading();

    // Demo mode: serve bundled sample slots.
    if (DemoService.isDemoMode) {
      state = AsyncValue.data(await DemoService.instance.slots());
      return;
    }

    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
          'User not found. Please Logout and Login.', StackTrace.current);
      return;
    }

    final res = await _repository.fetchSlotsForCoursePage(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
      classId: classId,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final slotsResponse)) {
      state = AsyncValue.data(slotsResponse);
    }
  }

  void reset() {
    state = null;
  }
}
