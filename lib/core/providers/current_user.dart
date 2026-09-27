import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/user_persistence.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';
import 'package:vit_ap_student_app/core/services/secure_store_service.dart';
import 'package:vit_ap_student_app/core/utils/avatar_image.dart';
import 'package:vit_ap_student_app/features/academic_calendar/viewmodel/non_instructional_days_provider.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:vit_ap_student_app/objectbox.g.dart';

part 'current_user.g.dart';

@Riverpod(keepAlive: true)
class CurrentUserNotifier extends _$CurrentUserNotifier {
  @override
  User? build() {
    // Load cached user from ObjectBox with proper ordering
    final store = serviceLocator.get<Store>();
    return store.box<User>().query().order(User_.id).build().findFirst();
  }

  Future<void> loginUser(User user, Credentials credentials) async {
    try {
      // Save user to state and ObjectBox
      state = user;
      _saveUserToObjectBox(user);

      // Save credentials
      await serviceLocator.get<SecureStorageService>().saveCredentials(
        credentials,
      );

      final prefs = ref.read(userPreferencesProvider);
      await NotificationService.scheduleTimetableNotifications(
        user: user,
        prefs: prefs,
        nonInstructionalDays: await ref.read(
          nonInstructionalDaysProvider.future,
        ),
      );
      await NotificationService.scheduleExamNotifications(
        user: user,
        prefs: prefs,
      );
    } catch (e) {
      state = null;
      _clearUserDataObjectBox();
      throw Exception('Login failed: $e');
    }
  }

  // Update user in state and ObjectBox
  Future<void> updateUser(User updatedUser) async {
    try {
      // Preserve the existing ID when updating
      final userWithId = state?.id != null
          ? updatedUser.copyWith(id: state!.id)
          : updatedUser;

      state = userWithId;
      _saveUserToObjectBox(userWithId);

      // Reschedule notifications with updated user data
      final prefs = ref.read(userPreferencesProvider);
      await NotificationService.cancelAllNotifications();
      await NotificationService.scheduleTimetableNotifications(
        user: userWithId,
        prefs: prefs,
        nonInstructionalDays: await ref.read(
          nonInstructionalDaysProvider.future,
        ),
      );
      await NotificationService.scheduleExamNotifications(
        user: userWithId,
        prefs: prefs,
      );
    } catch (e) {
      debugPrint('Failed to update user data: $e');
      throw Exception('Failed to update user data: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Clear user state and storage
      state = null;
      _clearUserDataObjectBox();

      // Exit demo mode (no-op for normal accounts) so a subsequent real login
      // is not treated as a demo session.
      await DemoService.instance.setDemoMode(false);

      // Remove credentials
      await serviceLocator.get<SecureStorageService>().clearCredentials();

      // Drop the analytics identity so the next account on a shared device
      // does not inherit this student's cohort properties.
      await ref.read(analyticsServiceProvider).reset();

      // Clear Notifications
      await NotificationService.cancelAllNotifications();

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

  Future<Credentials?> getSavedCredentials() async {
    return await serviceLocator.get<SecureStorageService>().getCredentials();
  }

  Future<void> updateSavedCredentials({
    required Credentials newCredentials,
  }) async {
    return await serviceLocator.get<SecureStorageService>().saveCredentials(
      newCredentials,
    );
  }

  // Manually save user
  void _saveUserToObjectBox(User user) {
    final newId = saveUser(serviceLocator.get<Store>(), user);
    debugPrint('Saved user with ID: $newId');

    // A fresh sign-in has no id until it is written.
    if (user.id == null || user.id! <= 0) {
      state = state?.copyWith(id: newId);
    }
  }

  // Manually clear user data
  void _clearUserDataObjectBox() {
    removeAllUserData(serviceLocator.get<Store>());
  }

  bool get isLoggedIn => state != null;
}
