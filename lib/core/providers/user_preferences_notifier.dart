import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/user_preferences.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/store.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';

part 'user_preferences_notifier.g.dart';

@Riverpod(keepAlive: true)
class UserPreferencesNotifier extends _$UserPreferencesNotifier {
  @override
  UserPreferences build() {
    // Load cached user preferences from ObjectBox
    final store = ref.watch(storeProvider);
    return store.box<UserPreferences>().query().build().findFirst() ??
        UserPreferences();
  }

  Future<void> updatePreferences(UserPreferences newPreferences) async {
    final notifications = ref.read(notificationServiceProvider);
    try {
      final store = ref.read(storeProvider);
      final box = store.box<UserPreferences>();
      final existing = box.query().build().findFirst();
      if (existing != null) {
        newPreferences.id = existing.id;
      }
      box.put(newPreferences);
      state = newPreferences;

      final user = ref.read(currentUserProvider);
      if (user != null) {
        // Cancel all notifications first
        await notifications.cancelAllNotifications();

        // Reschedule timetable notifications if enabled
        if (newPreferences.isTimetableNotificationsEnabled) {
          await notifications.scheduleTimetableNotifications(
            user: user,
            prefs: newPreferences,
          );
        }

        // Reschedule exam notifications if enabled
        if (newPreferences.isExamScheduleNotificationEnabled) {
          await notifications.scheduleExamNotifications(
            user: user,
            prefs: newPreferences,
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  // Toggle bypass weekend outing restriction
  Future<void> toggleBypassWeekendOutingRestriction(bool value) async {
    final updatedPrefs = state.copyWith(bypassWeekendOutingRestriction: value);
    await updatePreferences(updatedPrefs);
  }

  /// Toggle Privacy Mode, which hides the CGPA and credits badges.
  ///
  /// Shared by the settings switch and the badges themselves, so a tap on
  /// either lands in the same place.
  Future<void> togglePrivacyMode(bool value) async {
    await updatePreferences(state.copyWith(isPrivacyEnabled: value));
  }

  /// Toggle anonymous usage analytics.
  ///
  /// The backend is updated alongside the stored preference so opting out takes
  /// effect immediately rather than at the next launch; disabling also clears
  /// data already buffered on the device.
  Future<void> toggleAnalytics(bool value) async {
    await updatePreferences(state.copyWith(isAnalyticsEnabled: value));
    await ref
        .read(analyticsServiceProvider)
        .setCollectionEnabled(enabled: value);
  }

  // Manually clear user preferences
  void clearUserPreferences() {
    ref.read(storeProvider).box<UserPreferences>().removeAll();
  }
}
