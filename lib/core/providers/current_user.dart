import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/semester_cache.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';
import 'package:vit_ap_student_app/core/services/secure_store_service.dart';
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
      await serviceLocator
          .get<SecureStorageService>()
          .saveCredentials(credentials);

      final prefs = ref.read(userPreferencesProvider);
      await NotificationService.scheduleTimetableNotifications(
        user: user,
        prefs: prefs,
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
      final userWithId =
          state?.id != null ? updatedUser.copyWith(id: state!.id) : updatedUser;

      state = userWithId;
      _saveUserToObjectBox(userWithId);

      // Reschedule notifications with updated user data
      final prefs = ref.read(userPreferencesProvider);
      await NotificationService.cancelAllNotifications();
      await NotificationService.scheduleTimetableNotifications(
        user: userWithId,
        prefs: prefs,
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

      // Clear Notifications
      await NotificationService.cancelAllNotifications();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<Credentials?> getSavedCredentials() async {
    return await serviceLocator.get<SecureStorageService>().getCredentials();
  }

  Future<void> updateSavedCredentials(
      {required Credentials newCredentials}) async {
    return await serviceLocator
        .get<SecureStorageService>()
        .saveCredentials(newCredentials);
  }

  // Manually save user
  void _saveUserToObjectBox(User user) {
    debugPrint('Data saved: ${user.toString()}');
    final store = serviceLocator.get<Store>();
    final userBox = store.box<User>();

    // Check if we're updating an existing user or creating a new one
    if (user.id != null && user.id! > 0) {
      // For existing users, get the stored version and selectively update
      final existingUser = userBox.get(user.id!);
      if (existingUser != null) {
        // Clear and replace ToMany relationships to prevent duplicates
        // ObjectBox will automatically assign IDs to the new entities

        existingUser.attendance.clear();
        existingUser.attendance.addAll(user.attendance);

        existingUser.examSchedule.clear();
        existingUser.examSchedule.addAll(user.examSchedule);

        existingUser.marks.clear();
        existingUser.marks.addAll(user.marks);

        // Update ToOne relationships
        existingUser.profile.target = user.profile.target;
        existingUser.timetable.target = user.timetable.target;

        // Save the updated user (this will assign proper IDs to all entities)
        userBox.put(existingUser);
        debugPrint('Updated existing user with ID: ${existingUser.id}');
      } else {
        // Fallback: if existing user not found, create new
        final newId = userBox.put(user);
        debugPrint('Created new user with ID: $newId');
      }
    } else {
      // For new users, clear existing data and create fresh
      userBox.removeAll();
      final newId = userBox.put(user);
      debugPrint('New user created with ID: $newId');
      // Update state with the new ID
      state = state?.copyWith(id: newId);
    }
  }

  // Manually clear user data
  void _clearUserDataObjectBox() {
    serviceLocator.get<Store>().box<User>().removeAll();

    // Clear semester cache
    serviceLocator.get<Store>().box<SemesterCache>().removeAll();
  }

  bool get isLoggedIn => state != null;
}
