import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/models/user_preferences.dart';
import 'package:vit_ap_student_app/core/providers/reminder_scheduler.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';

import '../../helpers/provider_harness.dart';

/// Records calls in order, taking a turn of the event loop on each one the
/// way the real plugin does, so overlapping runs would interleave.
class _RecordingNotifications extends Fake implements NotificationService {
  _RecordingNotifications({this.failTimetable = false});

  final bool failTimetable;
  final List<String> calls = [];

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

    await s.apply(newUser(id: 1));
    await s.apply(null);

    expect(analytics.errorTypes, ['notification_error']);
    expect(failing.calls.last, 'cancel', reason: 'the queue is not stuck');
  });
}
