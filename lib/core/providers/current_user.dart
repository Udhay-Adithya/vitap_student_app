import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/repository/session_repository.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/utils/avatar_image.dart';

part 'current_user.g.dart';

/// The signed-in student, or null when nobody is.
///
/// Storage belongs to [SessionRepository] and reminders follow this state on
/// their own (see `reminderSchedulerProvider`). State is assigned once per
/// transition, after storage has succeeded, so listeners never see a user that
/// was not actually saved.
@Riverpod(keepAlive: true)
class CurrentUserNotifier extends _$CurrentUserNotifier {
  SessionRepository get _session => ref.read(sessionRepositoryProvider);

  @override
  User? build() => ref.watch(sessionRepositoryProvider).loadUser();

  Future<void> loginUser(User user, Credentials credentials) async {
    try {
      final saved = _session.saveUserGraph(user);
      await _session.saveCredentials(credentials);
      state = saved;
    } catch (e) {
      // Only a failure to *store* the account rolls it back.
      _session.clearUserData();
      throw Exception('Login failed: $e');
    }
  }

  Future<void> updateUser(User updatedUser) async {
    try {
      // Preserve the existing ID when updating
      final withId = state?.id != null
          ? updatedUser.copyWith(id: state!.id)
          : updatedUser;
      state = _session.saveUserGraph(withId);
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  Future<void> logout() async {
    try {
      state = null;
      _session.clearUserData();

      // Exit demo mode (no-op for normal accounts) so a subsequent real login
      // is not treated as a demo session.
      await ref.read(demoModeProvider.notifier).set(false);

      await _session.clearCredentials();

      // Drop the analytics identity so the next account on a shared device
      // does not inherit this student's cohort properties.
      await ref.read(analyticsServiceProvider).reset();

      // Preferences are the device's and mostly survive a logout, but the
      // last-synced stamps belong to the account that fetched the data.
      final prefsNotifier = ref.read(userPreferencesProvider.notifier);
      await prefsNotifier.updatePreferences(
        ref.read(userPreferencesProvider).withoutAccountData(),
      );

      // The decoded profile photo is a picture of the student who just left.
      clearPhotoCache();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<Credentials?> getSavedCredentials() => _session.readCredentials();

  Future<void> updateSavedCredentials({required Credentials newCredentials}) =>
      _session.saveCredentials(newCredentials);

  bool get isLoggedIn => state != null;
}
