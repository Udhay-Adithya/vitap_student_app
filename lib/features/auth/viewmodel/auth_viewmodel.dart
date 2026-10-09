import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/auth/repository/auth_remote_repository.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  late CurrentUserNotifier _currentUserNotifier;
  late AnalyticsService _analytics;

  @override
  AsyncValue<User>? build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserProvider.notifier);
    _analytics = ref.watch(analyticsServiceProvider);
    return null;
  }

  /// Logs in the bundled demo account for App Store review / demos.
  ///
  /// Bypasses the entire VTOP flow (no credential check, no semester fetch, no
  /// OTP) and seeds local storage from [DemoService]'s sanitized dataset.
  Future<void> loginDemoUser() async {
    state = const AsyncValue.loading();

    _analytics.logEvent(AnalyticsEvents.loginAttempt, {
      AnalyticsParams.method: 'demo',
    });

    try {
      final user = await DemoService.instance.loadDemoUser();
      final credentials = DemoService.instance.credentials;

      await DemoService.instance.setDemoMode(true);
      await _currentUserNotifier.loginUser(user, credentials);

      _analytics.logLogin('demo');
      _analytics.logEvent(AnalyticsEvents.loginSuccess, {
        AnalyticsParams.method: 'demo',
      });

      state = AsyncValue.data(user);
    } catch (e) {
      // Roll back the flag so the app doesn't get stuck in a broken demo state.
      await DemoService.instance.setDemoMode(false);
      _analytics.logError('auth_error', e, location: 'loginDemoUser');
      state = AsyncValue.error(
        'Failed to start the demo. Please try again.',
        StackTrace.current,
      );
    }
  }

  Future<void> loginUser({
    required String semSubId,
    String? registrationNumber,
    String? password,
  }) async {
    state = const AsyncValue.loading();

    Credentials? credentials;

    // If credentials are provided as parameters, use them (first-time login)
    if (registrationNumber != null && password != null) {
      credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );
    } else {
      // Otherwise, try to get saved credentials (re-authentication)
      credentials = await ref
          .read(currentUserProvider.notifier)
          .getSavedCredentials();
      if (credentials == null) {
        state = AsyncValue.error(
            'No saved credentials found. Please log in again.',
            StackTrace.current);
        _analytics.logError(
          'auth_error',
          'No saved credentials found',
          location: 'loginUser',
        );
        return;
      }
    }

    // The typed login id is never logged — it identifies the student. Cohort
    // properties are set from the scraped registration number after login.
    _analytics.logEvent(AnalyticsEvents.loginAttempt, {
      AnalyticsParams.method: 'vtop_credentials',
    });

    final res = await _authRemoteRepository.login(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: semSubId,
    );

    final Credentials newCredentials = Credentials(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: semSubId,
    );

    if (res case Left(value: final failure)) {
      // Log login failure
      _analytics.logEvent(AnalyticsEvents.loginFailed, {
        AnalyticsParams.method: 'vtop_credentials',
        AnalyticsParams.reason: failure.message,
      });
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final user)) {
      // Log successful login. The registration number scraped from VTOP is the
      // authoritative one — the login id the student typed may be something
      // else entirely.
      final regNo = user.profile.target?.registrationNumber;
      if (regNo != null && regNo.isNotEmpty) {
        _analytics.identifyStudent(regNo);
      }
      _analytics.logLogin('vtop_credentials');
      _analytics.logEvent(AnalyticsEvents.loginSuccess, {
        AnalyticsParams.method: 'vtop_credentials',
      });
      await _getDataSuccess(user, newCredentials);
    }
  }

  /// Stores the signed-in account, then reports the outcome.
  ///
  /// Awaited: this used to be fire-and-forget, so a failure to store the
  /// account surfaced nowhere — the app navigated on to a home page with no
  /// account behind it, and every page said there was no user.
  Future<AsyncValue<User>> _getDataSuccess(
    User user,
    Credentials credentials,
  ) async {
    try {
      await _currentUserNotifier.loginUser(user, credentials);
    } catch (e) {
      _analytics.logError('auth_error', e, location: '_getDataSuccess');
      return state = AsyncValue.error(
        'Signed in, but saving the account failed. Please try again.',
        StackTrace.current,
      );
    }
    return state = AsyncValue.data(user);
  }

}
