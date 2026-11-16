import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/features/home/repository/outing_remote_repository.dart';

part 'outing_submission_viewmodel.g.dart';

@riverpod
class GeneralOutingSubmission extends _$GeneralOutingSubmission {
  late OutingRemoteRepository _outingRemoteRepository;

  @override
  AsyncValue<String>? build() {
    _outingRemoteRepository = ref.watch(outingRemoteRepositoryProvider);
    return null;
  }

  Future<void> submitGeneralOuting({
    required String outPlace,
    required String purposeOfVisit,
    required String outingDate,
    required String outTime,
    required String inDate,
    required String inTime,
  }) async {
    state = const AsyncValue.loading();

    final credentials = await ref
        .read(currentUserProvider.notifier)
        .getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
        'User credentials not found. Please login again.',
        StackTrace.current,
      );
      return;
    }

    final res = await _outingRemoteRepository.submitGeneralOutingForm(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      outPlace: outPlace,
      purposeOfVisit: purposeOfVisit,
      outingDate: outingDate,
      outTime: outTime,
      inDate: inDate,
      inTime: inTime,
    );

    state = switch (res) {
      Left(value: final failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      Right(value: final response) => AsyncValue.data(response),
    };
  }

  Future<void> deleteGeneralOuting({required String leaveId}) async {
    state = const AsyncValue.loading();

    final credentials = await ref
        .read(currentUserProvider.notifier)
        .getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
        'User credentials not found. Please login again.',
        StackTrace.current,
      );
      return;
    }

    final res = await _outingRemoteRepository.deleteGeneralOuting(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      leaveId: leaveId,
    );

    state = switch (res) {
      Left(value: final failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      Right(value: final response) => AsyncValue.data(response),
    };
  }
}

@riverpod
class WeekendOutingSubmission extends _$WeekendOutingSubmission {
  late OutingRemoteRepository _outingRemoteRepository;

  @override
  AsyncValue<String>? build() {
    _outingRemoteRepository = ref.watch(outingRemoteRepositoryProvider);
    return null;
  }

  Future<void> submitWeekendOuting({
    required String outPlace,
    required String purposeOfVisit,
    required String outingDate,
    required String outTime,
    required String contactNumber,
  }) async {
    state = const AsyncValue.loading();

    final credentials = await ref
        .read(currentUserProvider.notifier)
        .getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
        'User credentials not found. Please login again.',
        StackTrace.current,
      );
      return;
    }

    final res = await _outingRemoteRepository.submitWeekendOutingForm(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      outPlace: outPlace,
      purposeOfVisit: purposeOfVisit,
      outingDate: outingDate,
      outTime: outTime,
      contactNumber: contactNumber,
    );

    state = switch (res) {
      Left(value: final failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      Right(value: final response) => AsyncValue.data(response),
    };
  }

  Future<void> deleteWeekendOuting({required String bookingId}) async {
    state = const AsyncValue.loading();

    final credentials = await ref
        .read(currentUserProvider.notifier)
        .getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
        'User credentials not found. Please login again.',
        StackTrace.current,
      );
      return;
    }

    final res = await _outingRemoteRepository.deleteWeekendOuting(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      bookingId: bookingId,
    );

    state = switch (res) {
      Left(value: final failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      Right(value: final response) => AsyncValue.data(response),
    };
  }
}
