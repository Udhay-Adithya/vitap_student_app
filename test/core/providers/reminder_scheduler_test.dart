import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/models/user_preferences.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/reminder_scheduler.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

/// Records calls in order, taking a turn of the event loop on each one the
/// way the real plugin does, so overlapping runs would interleave.
///
/// Set [hold] to keep timetable scheduling in flight until it completes, the
/// way a slow plugin does with a full timetable.
class _RecordingNotifications extends Fake implements NotificationService {
  _RecordingNotifications({this.failTimetable = false});

  final bool failTimetable;
  final List<String> calls = [];
  Completer<void>? hold;

  @override
  Future<void> cancelAllNotifications() async {
    await Future<void>.delayed(Duration.zero);
    calls.add('cancel');
  }

  @override
  Future<void> scheduleTimetableNotifications({
    required User user,
    required UserPreferences prefs,
  }) async {
    await Future<void>.delayed(Duration.zero);
    // The real service checks the switch itself.
    if (!prefs.isTimetableNotificationsEnabled) return;
    if (hold != null) await hold!.future;
    if (failTimetable) throw StateError('exact alarms not permitted');
    calls.add('timetable ${user.id}');
  }

  @override
  Future<void> scheduleExamNotifications({
    required User user,
    required UserPreferences prefs,
  }) async {
    await Future<void>.delayed(Duration.zero);
    calls.add('exams ${user.id}');
  }
}

void main() {
  late RecordingAnalyticsService analytics;

  ReminderScheduler scheduler(NotificationService notifications) {
    analytics = RecordingAnalyticsService();
    return ReminderScheduler(
      notifications: notifications,
      preferences: UserPreferences.new,
      analytics: analytics,
    );
  }

  test('signing out cancels reminders and schedules nothing', () async {
    final notifications = _RecordingNotifications();

    await scheduler(notifications).apply(null);

    expect(notifications.calls, ['cancel']);
  });

  /// Every refresh saves the user, and two can land together. Run side by
  /// side, their cancels and schedules interleave and the plugin keeps
  /// whichever write came last, which can be the older user's.
  test('runs one rebuild at a time, in order', () async {
    final notifications = _RecordingNotifications();
    final s = scheduler(notifications);

    final first = s.apply(newUser(id: 1));
    final second = s.apply(newUser(id: 2));
    await Future.wait([first, second]);

    expect(notifications.calls, [
      'cancel',
      'timetable 1',
      'exams 1',
      'cancel',
      'timetable 2',
      'exams 2',
    ]);
  });

  test('logs a failure instead of throwing, and keeps going', () async {
    final failing = _RecordingNotifications(failTimetable: true);
    final s = scheduler(failing);

    expect(await s.apply(newUser(id: 1)), isFalse);
    expect(await s.apply(null), isTrue);

    expect(analytics.errorTypes, ['notification_error']);
    expect(failing.calls.last, 'cancel', reason: 'the queue is not stuck');
  });

  group(
    'every writer of the schedule',
    () {
      late _RecordingNotifications notifications;

      setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

      /// Signed in, with the rebuild that sign-in started still in flight.
      Future<ProviderContainer> signedInMidRebuild() async {
        final deps = testDependencies();
        notifications = _RecordingNotifications()..hold = Completer<void>();
        final container = ProviderContainer(
          overrides: [
            ...deps.overrides,
            notificationServiceProvider.overrideWithValue(notifications),
          ],
        );
        addTearDown(container.dispose);
        container.read(reminderSyncProvider);
        await container
            .read(currentUserProvider.notifier)
            .loginUser(newUser(), testCredentials());
        await pumpEventQueue();
        return container;
      }

      /// Settings used to cancel and reschedule on their own, beside the
      /// scheduler's queue. A refresh mid-rebuild had read the old settings,
      /// so switching class reminders off cancelled them only for that
      /// rebuild to schedule them again.
      test('a settings change lands after a rebuild in flight', () async {
        final ref = await signedInMidRebuild();

        final change = ref
            .read(userPreferencesProvider.notifier)
            .updatePreferences(
              ref
                  .read(userPreferencesProvider)
                  .copyWith(isTimetableNotificationsEnabled: false),
            );
        await pumpEventQueue();
        notifications.hold!.complete();
        await change;

        final lastRun = notifications.calls.sublist(
          notifications.calls.lastIndexOf('cancel'),
        );
        expect(lastRun, isNot(contains(startsWith('timetable'))));
        expect(lastRun, contains(startsWith('exams')));
      });

      /// Logout used to leave its cancel queued behind the rebuild without
      /// waiting for it. Closing the app in that gap kept the previous
      /// student's reminders registered, and nothing clears them on a
      /// signed-out launch.
      test('logout finishes only once reminders are cancelled', () async {
        final ref = await signedInMidRebuild();

        var loggedOut = false;
        final logout = ref
            .read(currentUserProvider.notifier)
            .logout()
            .then((_) => loggedOut = true);
        await pumpEventQueue();
        expect(loggedOut, isFalse, reason: 'the rebuild is still running');

        notifications.hold!.complete();
        await logout;

        expect(notifications.calls.last, 'cancel');
      });
    },
    skip: objectBoxAvailable ? false : objectBoxMissingReason,
  );
}
