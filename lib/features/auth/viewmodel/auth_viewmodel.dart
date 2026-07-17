import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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

  @override
  AsyncValue<User>? build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserProvider.notifier);
    return null;
  }

  /// Logs in the bundled demo account for App Store review / demos.
  ///
  /// Bypasses the entire VTOP flow (no credential check, no semester fetch, no
  /// OTP) and seeds local storage from [DemoService]'s sanitized dataset.
  Future<void> loginDemoUser() async {
    state = const AsyncValue.loading();

    await AnalyticsService.logEvent('login_attempt', {
      'method': 'demo',
    });

    try {
      final user = await DemoService.instance.loadDemoUser();
      final credentials = DemoService.instance.credentials;

      await DemoService.instance.setDemoMode(true);
      await _currentUserNotifier.loginUser(user, credentials);

      await AnalyticsService.logLogin('demo');
      await AnalyticsService.logEvent('login_success', {
        'method': 'demo',
      });

      state = AsyncValue.data(user);
    } catch (e) {
      // Roll back the flag so the app doesn't get stuck in a broken demo state.
      await DemoService.instance.setDemoMode(false);
      await AnalyticsService.logError('auth_error', 'Demo login failed: $e',
          location: 'loginDemoUser');
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
        await AnalyticsService.logError('auth_error', 'No saved credentials found',
            location: 'loginUser');
        return;
      }
    }

    // Log login attempt
    await AnalyticsService.logEvent('login_attempt', {
      'method': 'vtop_credentials',
      'registration_number': credentials.registrationNumber,
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

    await setUserProperties(credentials.registrationNumber);

    if (res case Left(value: final failure)) {
      // Log login failure
      await AnalyticsService.logEvent('login_failed', {
        'error_message': failure.message,
        'method': 'vtop_credentials',
      });
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final user)) {
      // Log successful login
      await AnalyticsService.logLogin('vtop_credentials');
      await AnalyticsService.logEvent('login_success', {
        'method': 'vtop_credentials',
        'user_id': user.profile.target?.applicationNumber ?? 'unknown',
      });
      _getDataSuccess(user, newCredentials);
    }
  }

  AsyncValue<User> _getDataSuccess(User user, Credentials credentials) {
    _currentUserNotifier.loginUser(user, credentials);
    return state = AsyncValue.data(user);
  }

  Future<void> setUserProperties(String regNo) async {
    final regex = RegExp(r'^\d{2}[A-Z]{3}\d+$', caseSensitive: false);

    String joiningYear;
    String branch;

    if (regex.hasMatch(regNo)) {
      joiningYear = '20${regNo.substring(0, 2)}';
      branch = regNo.substring(2, 5).toUpperCase();
    } else {
      joiningYear = 'Custom';
      branch = 'Custom';
    }

    await FirebaseAnalytics.instance
        .setUserProperty(name: 'joining_year', value: joiningYear);
    await FirebaseAnalytics.instance
        .setUserProperty(name: 'branch', value: branch);
  }
}
