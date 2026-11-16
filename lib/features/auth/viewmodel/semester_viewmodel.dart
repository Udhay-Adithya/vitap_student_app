import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/network/connection_checker.dart';
import 'package:vit_ap_student_app/features/auth/repository/auth_local_repository.dart';
import 'package:vit_ap_student_app/features/auth/repository/auth_remote_repository.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/types/semester.dart';

part 'semester_viewmodel.g.dart';

@riverpod
class SemesterViewModel extends _$SemesterViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;
  late ConnectionChecker _connectionChecker;

  @override
  AsyncValue<List<SemesterInfo>>? build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _connectionChecker = serviceLocator<ConnectionChecker>();
    return null;
  }

  Future<void> fetchSemesters({
    required String registrationNumber,
    required String password,
    bool needsUpdate = false,
  }) async {
    state = const AsyncValue.loading();

    // Check internet connectivity
    final hasInternet = await _connectionChecker.isConnected;

    // If no internet, return cached data
    if (!hasInternet) {
      final cachedResult = await _authLocalRepository.getSemesters();
      switch (cachedResult) {
        case Left(value: final l):
          state = AsyncValue.error(l.message, StackTrace.current);
        case Right(value: final r):
          state = AsyncValue.data(r);
      }
      return;
    }

    // If internet is available, check for local data
    final hasCachedData = _authLocalRepository.hasCachedSemesters();

    if (hasCachedData) {
      // Return cached data immediately
      final cachedResult = await _authLocalRepository.getSemesters();
      switch (cachedResult) {
        case Left(value: final _):
          // If cache fails, continue to fetch from remote
          break;
        case Right(value: final r):
          state = AsyncValue.data(r);
      }

      // Fetch fresh data in the background and update silently when needed
      if (needsUpdate) {
        final remoteRes = await _authRemoteRepository.fetchSemesters(
          registrationNumber: registrationNumber,
          password: password,
        );
        switch (remoteRes) {
          case Left(value: final _):
            // Silent failure - keep showing cached data
            break;
          case Right(value: final r):
            // Update cache
            await _authLocalRepository.saveSemesters(r);
            // Update state with fresh data
            state = AsyncValue.data(r);
        }
      }
    } else {
      // No cached data, fetch from remote
      final remoteRes = await _authRemoteRepository.fetchSemesters(
        registrationNumber: registrationNumber,
        password: password,
      );

      switch (remoteRes) {
        case Left(value: final l):
          state = AsyncValue.error(l.message, StackTrace.current);
        case Right(value: final r):
          // Save to cache
          await _authLocalRepository.saveSemesters(r);
          state = AsyncValue.data(r);
      }
    }
  }

  /// Get selected semester from cache
  Future<SemesterInfo?> getSelectedSemester() async {
    final result = await _authLocalRepository.getSelectedSemester();
    return result.fold((l) => null, (r) => r);
  }

  /// Set selected semester in cache
  Future<void> setSelectedSemester(String semesterId) async {
    await _authLocalRepository.setSelectedSemester(semesterId);
  }

  /// Fetch semesters for login - only validates credentials and returns data
  /// Does not use cache, does not update state - used only during login
  Future<void> fetchSemestersForLogin({
    required String registrationNumber,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final remoteRes = await _authRemoteRepository.fetchSemesters(
      registrationNumber: registrationNumber,
      password: password,
    );

    switch (remoteRes) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
      case Right(value: final r):
        // Save to cache
        await _authLocalRepository.saveSemesters(r);
        state = AsyncValue.data(r);
    }
  }
}
