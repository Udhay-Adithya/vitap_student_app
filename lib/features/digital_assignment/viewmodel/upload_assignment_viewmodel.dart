import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/assignment_reminder_store.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/digital_assignment_remote_repository.dart';

part 'upload_assignment_viewmodel.g.dart';

@riverpod
class UploadAssignmentViewModel extends _$UploadAssignmentViewModel {
  late DigitalAssignmentRemoteRepository _repository;

  /// The assignment being uploaded. The OTP step that may follow doesn't
  /// carry it, but its success still needs to silence that one's reminders.
  ({String classId, String mcode})? _target;

  @override
  AsyncValue<String>? build() {
    _repository = ref.watch(digitalAssignmentRemoteRepositoryProvider);
    return null;
  }

  Future<void> uploadAssignment({
    required String classId,
    required String mode,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    state = const AsyncValue.loading();
    _target = (classId: classId, mcode: mode);
    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error(
          'User not found. Please Logout and Login.', StackTrace.current);
      return;
    }

    final res = await _repository.uploadDigitalAssignment(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
      classId: classId,
      mode: mode,
      fileName: fileName,
      fileBytes: fileBytes,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final result)) {
      state = AsyncValue.data(result);
      await _stopReminders();
    }
  }

  Future<void> submitOtp({required String otpEmail}) async {
    state = const AsyncValue.loading();
    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error(
          'User not found. Please Logout and Login.', StackTrace.current);
      return;
    }

    final res = await _repository.uploadDigitalAssignmentWithOtp(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
      otpEmail: otpEmail,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final result)) {
      state = AsyncValue.data(result);
      await _stopReminders();
    }
  }

  Future<void> _stopReminders() async {
    final target = _target;
    if (target == null) return;
    try {
      await const AssignmentReminderStore().markSubmitted(
        classId: target.classId,
        mcode: target.mcode,
      );
    } catch (e) {
      debugPrint('Failed to cancel assignment reminders: $e');
    }
  }
}
