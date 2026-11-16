import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/models/user_preferences.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';

part 'reminder_scheduler.g.dart';

/// Keeps class and exam reminders in step with the signed-in user.
///
/// Read once at startup so the listener is in place: every change to the
/// current user rebuilds the schedule from it, and signing out cancels it.
@Riverpod(keepAlive: true)
ReminderScheduler reminderScheduler(Ref ref) {
  final scheduler = ReminderScheduler(
    notifications: ref.watch(notificationServiceProvider),
    preferences: () => ref.read(userPreferencesProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
  ref.listen<User?>(currentUserProvider, (_, user) => scheduler.apply(user));
  return scheduler;
}

class ReminderScheduler {
  ReminderScheduler({
    required NotificationService notifications,
    required UserPreferences Function() preferences,
    required AnalyticsService analytics,
  }) : _notifications = notifications,
       _preferences = preferences,
       _analytics = analytics;

  final NotificationService _notifications;
  final UserPreferences Function() _preferences;
  final AnalyticsService _analytics;

  Future<void> _pending = Future<void>.value();

  /// Rebuilds the schedule for [user], or clears it when there is none.
  ///
  /// Runs one at a time: two refreshes landing together would otherwise
  /// interleave their cancels and schedules, and the plugin keeps whichever
  /// write came last.
  ///
  /// Never throws. Reminders are a convenience laid on top of data the
  /// student already has, so a failure here must not fail the sign-in or
  /// refresh that triggered it. Scheduling once shared `loginUser`'s `catch`,
  /// which rolled the account back: a refused alarm deleted every row the
  /// student had just signed in to see.
  Future<void> apply(User? user) =>
      _pending = _pending.then((_) => _apply(user));

  Future<void> _apply(User? user) async {
    try {
      await _notifications.cancelAllNotifications();
      if (user == null) return;
      final prefs = _preferences();
      await _notifications.scheduleTimetableNotifications(
        user: user,
        prefs: prefs,
      );
      await _notifications.scheduleExamNotifications(user: user, prefs: prefs);
    } catch (e, stackTrace) {
      debugPrint('Failed to schedule notifications: $e');
      _analytics.logError(
        'notification_error',
        e,
        location: 'scheduleNotifications',
      );
      debugPrintStack(stackTrace: stackTrace, label: 'scheduleNotifications');
    }
  }
}
