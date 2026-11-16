import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/features/home/model/general_outing_report.dart';
import 'package:vit_ap_student_app/features/home/model/weekend_outing_report.dart';
import 'package:vit_ap_student_app/features/home/repository/outing_local_repository.dart';
import 'package:vit_ap_student_app/features/home/repository/outing_remote_repository.dart';

part 'outing_reports_viewmodel.g.dart';

@riverpod
class GeneralOutingReportsViewModel extends _$GeneralOutingReportsViewModel {
  late OutingRemoteRepository _outingRemoteRepository;
  late OutingLocalRepository _outingLocalRepository;

  @override
  AsyncValue<List<GeneralOutingReport>>? build() {
    _outingRemoteRepository = ref.watch(outingRemoteRepositoryProvider);
    _outingLocalRepository = ref.watch(outingLocalRepositoryProvider);
    return null;
  }

  /// Returns `true` only when a fresh copy was successfully fetched from the
  /// remote. Falling back to cache (offline, or a failed remote fetch while
  /// cache exists) returns `false`, so callers don't advance the "last synced"
  /// timer on a stale result.
  Future<bool> fetchGeneralOutingReports({bool silentRefresh = false}) async {
    // Show the cache while fetching, unless this is a silent refresh.
    if (!silentRefresh) {
      final cachedReports = _outingLocalRepository.getGeneralOutingReports();
      if (cachedReports.isNotEmpty) {
        state = AsyncValue.data(cachedReports);
      } else {
        state = const AsyncValue.loading();
      }
    }

    // Fetch from remote
    final credentials = await ref
        .read(currentUserProvider.notifier)
        .getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error(
        'User credentials not found. Please login again.',
        StackTrace.current,
      );
      return false;
    }

    final res = await _outingRemoteRepository.fetchGeneralOutingReports(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
    );

    switch (res) {
      case Left(value: final failure):
        // Being offline lands here too. Keep what is on screen, or fall back
        // to the cache when a silent refresh had nothing loaded yet.
        if (state?.value == null || state!.value!.isEmpty) {
          final cachedReports = _outingLocalRepository
              .getGeneralOutingReports();
          state = cachedReports.isNotEmpty
              ? AsyncValue.data(cachedReports)
              : AsyncValue.error(failure.message, StackTrace.current);
        }
        return false;
      case Right(value: final reports):
        // Save to cache and update state
        await _outingLocalRepository.saveGeneralOutingReports(reports);
        state = AsyncValue.data(reports);
        return true;
    }
  }
}

@riverpod
class WeekendOutingReportsViewModel extends _$WeekendOutingReportsViewModel {
  late OutingRemoteRepository _outingRemoteRepository;
  late OutingLocalRepository _outingLocalRepository;

  @override
  AsyncValue<List<WeekendOutingReport>>? build() {
    _outingRemoteRepository = ref.watch(outingRemoteRepositoryProvider);
    _outingLocalRepository = ref.watch(outingLocalRepositoryProvider);
    return null;
  }

  Future<bool> fetchWeekendOutingReports({bool silentRefresh = false}) async {
    // Show the cache while fetching, unless this is a silent refresh.
    if (!silentRefresh) {
      final cachedReports = _outingLocalRepository.getWeekendOutingReports();
      if (cachedReports.isNotEmpty) {
        state = AsyncValue.data(cachedReports);
      } else {
        state = const AsyncValue.loading();
      }
    }

    // Fetch from remote
    final credentials = await ref
        .read(currentUserProvider.notifier)
        .getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error(
        'User credentials not found. Please login again.',
        StackTrace.current,
      );
      return false;
    }

    final res = await _outingRemoteRepository.fetchWeekendOutingReports(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
    );

    switch (res) {
      case Left(value: final failure):
        // Being offline lands here too. Keep what is on screen, or fall back
        // to the cache when a silent refresh had nothing loaded yet.
        if (state?.value == null || state!.value!.isEmpty) {
          final cachedReports = _outingLocalRepository
              .getWeekendOutingReports();
          state = cachedReports.isNotEmpty
              ? AsyncValue.data(cachedReports)
              : AsyncValue.error(failure.message, StackTrace.current);
        }
        return false;
      case Right(value: final reports):
        // Save to cache and update state
        await _outingLocalRepository.saveWeekendOutingReports(reports);
        state = AsyncValue.data(reports);
        return true;
    }
  }
}
