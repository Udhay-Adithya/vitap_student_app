import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/digital_assignment_remote_repository.dart';

part 'digital_assignment_viewmodel.g.dart';

@riverpod
class DigitalAssignmentViewModel extends _$DigitalAssignmentViewModel {
  late DigitalAssignmentRemoteRepository _repository;

  @override
  AsyncValue<List<DigitalAssignment>>? build() {
    _repository = ref.watch(digitalAssignmentRemoteRepositoryProvider);
    return null;
  }

  Future<void> refreshDigitalAssignments({bool silentRefresh = false}) async {
    if (!silentRefresh) {
      state = const AsyncValue.loading();
    }

    // Demo mode: serve bundled sample digital assignments.
    if (DemoService.isDemoMode) {
      state = AsyncValue.data(await DemoService.instance.digitalAssignments());
      return;
    }

    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error(
          'User not found. Please Logout and Login.', StackTrace.current);
      return;
    }

    final res = await _repository.fetchDigitalAssignments(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final assignments)) {
      state = AsyncValue.data(assignments);
    }
  }
}
