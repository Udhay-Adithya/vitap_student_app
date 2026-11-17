import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/account/repository/account_remote_repository.dart';

part 'account_viewmodel.g.dart';

@riverpod
class AccountViewModel extends _$AccountViewModel {
  late AccountRemoteRepository _accountRemoteRepository;
  late AnalyticsService _analytics;

  @override
  AsyncValue<User>? build() {
    _accountRemoteRepository = ref.watch(accountRemoteRepositoryProvider);
    _analytics = ref.watch(analyticsServiceProvider);
    return null;
  }

  Future<void> sync() async {
    state = const AsyncValue.loading();

    // Demo mode: re-affirm the seeded demo user without contacting VTOP.
    if (DemoService.isDemoMode) {
      final demoUser = ref.read(currentUserProvider);
      state = demoUser != null
          ? AsyncValue.data(demoUser)
          : AsyncValue.data(await DemoService.instance.loadDemoUser());
      return;
    }

    final User? user = ref.read(currentUserProvider);
    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();
    if (credentials == null) {
      _analytics.logError(
        'sync_credentials_missing',
        'User credentials not found during sync',
      );
      state = AsyncValue.error(
        'User not found. Please Logout and Login.',
        StackTrace.current,
      );
      return;
    }

    // No student identifier here: the cohort is already carried by the
    // joining_year / branch user properties set at login.
    _analytics.logEvent(AnalyticsEvents.syncStarted);

    state = const AsyncValue.loading();
    final res = await _accountRemoteRepository.syncUser(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
    );

    if (res case Left(value: final failure)) {
      _analytics.logError('sync_failed', failure.message);
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final newUser)) {
      _analytics.logEvent(AnalyticsEvents.syncCompleted);
      debugPrint(newUser.toString());
      state = AsyncValue.data(newUser);
      if (user != null) {
        final updatedUser = newUser.copyWith(id: user.id);
        await userNotifier.updateUser(updatedUser);
        debugPrint(updatedUser.toString());
      }
    }
  }
}
