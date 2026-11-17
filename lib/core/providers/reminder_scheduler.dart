import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/models/user_preferences.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';

part 'reminder_scheduler.g.dart';

/// The one queue every writer of class and exam reminders goes through.
///
/// Knows nothing of the current user, so the current user's own notifier can
/// wait on it. The listener lives apart, in [reminderSync].
@Riverpod(keepAlive: true)
ReminderScheduler reminderScheduler(Ref ref) => ReminderScheduler(
  notifications: ref.watch(notificationServiceProvider),
  preferences: () => ref.read(userPreferencesProvider),
  analytics: ref.watch(analyticsServiceProvider),
);

/// Keeps reminders in step with the signed-in user.
///
/// Read once at startup so the listener is in place: every change to the
/// current user rebuilds the schedule from it, and signing out cancels it.
@Riverpod(keepAlive: true)
void reminderSync(Ref ref) {
  final scheduler = ref.watch(reminderSchedulerProvider);
  ref.listen<User?>(currentUserProvider, (_, user) => scheduler.apply(user));
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

  /// Rebuilds the schedule for [user], or clears it when there is none, and
  /// completes with whether that worked.
  ///
  /// Runs one at a time, and every writer of the schedule goes through here:
  /// two rebuilds side by side interleave their cancels and schedules, and the
  /// plugin keeps whichever write came last. A settings change racing a
  /// refresh could switch reminders off only for the refresh to put them back.
  ///
  /// Never throws. Reminders are a convenience laid on top of data the
  /// student already has, so a failure here must not fail the sign-in or
  /// refresh that triggered it. Scheduling once shared `loginUser`'s `catch`,
  /// which rolled the account back: a refused alarm deleted every row the
  /// student had just signed in to see. Callers that owe someone an answer,
  /// like the reset button, read the result instead.
  Future<bool> apply(User? user) {
    final run = _pending.then((_) => _apply(user));
    _pending = run;
    return run;
  }

  Future<bool> _apply(User? user) async {
    try {
      await _notifications.cancelAllNotifications();
      if (user == null) return true;
      // Read per run rather than captured at enqueue, so a run queued behind a
      // settings change schedules with the settings that won.
      final prefs = _preferences();
      await _notifications.scheduleTimetableNotifications(
        user: user,
        prefs: prefs,
      );
      await _notifications.scheduleExamNotifications(user: user, prefs: prefs);
      return true;
    } catch (e, stackTrace) {
      debugPrint('Failed to schedule notifications: $e');
      _analytics.logError(
        'notification_error',
        e,
        location: 'scheduleNotifications',
      );
      debugPrintStack(stackTrace: stackTrace, label: 'scheduleNotifications');
      return false;
    }
  }
}
