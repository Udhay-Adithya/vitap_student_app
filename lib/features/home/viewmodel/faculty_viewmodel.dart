import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/features/home/model/faculty.dart';
import 'package:vit_ap_student_app/features/home/repository/faculty_repository.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/types/faculty.dart';

part 'faculty_viewmodel.g.dart';

/// Holds the full list of faculty members loaded from VTOP.
/// State is `null` when not yet fetched, `AsyncLoading` during fetch,
/// `AsyncData` on success, and `AsyncError` on failure.
@riverpod
class FacultyListViewModel extends _$FacultyListViewModel {
  late FacultyRepository _repository;

  @override
  AsyncValue<List<FacultyListItem>>? build() {
    _repository = ref.watch(facultyRepositoryProvider);
    return null;
  }

  Future<void> fetchFacultyList() async {
    state = const AsyncValue.loading();

    final res = await _repository.fetchFacultyList();
    if (!ref.mounted) return;

    state = switch (res) {
      Left(value: final failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      Right(value: final list) => AsyncValue.data(list),
    };
  }
}

/// Holds the details of a single faculty member fetched on demand.
/// State starts as `null` (idle). Call [fetchDetails] when the user taps
/// a faculty list item.
@riverpod
class FacultyDetailsViewModel extends _$FacultyDetailsViewModel {
  late FacultyRepository _repository;

  @override
  AsyncValue<FacultyDetails>? build() {
    _repository = ref.watch(facultyRepositoryProvider);
    return null;
  }

  Future<void> fetchDetails(String empId) async {
    state = const AsyncValue.loading();

    final credentials = await ref
        .read(currentUserProvider.notifier)
        .getSavedCredentials();
    if (!ref.mounted) return;

    if (credentials == null) {
      state = AsyncValue.error(
        'User not found. Please logout and login again.',
        StackTrace.current,
      );
      return;
    }

    final res = await _repository.fetchFacultyDetails(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      empId: empId,
    );
    if (!ref.mounted) return;

    state = switch (res) {
      Left(value: final failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      Right(value: final details) => AsyncValue.data(details),
    };
  }
}
