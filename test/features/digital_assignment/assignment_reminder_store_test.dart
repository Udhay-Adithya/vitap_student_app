import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/assignment_reminder_store.dart';
import 'package:vit_ap_student_app/features/digital_assignment/utils/assignment_reminders.dart';

import 'assignment_reminders_test.dart' show course, detail;

/// Stands in for the OS: holds what has been scheduled, the way the plugin's
/// `pendingNotificationRequests` would report it.
class _FakeNotifications {
  final Map<int, Map<String, Object?>> pending = {};
  bool canExact = true;

  Future<Object?> handle(MethodCall call) async {
    switch (call.method) {
      case 'zonedSchedule':
        final args = Map<String, Object?>.from(call.arguments as Map);
        pending[args['id']! as int] = args;
      case 'cancel':
        pending.remove((call.arguments as Map)['id']);
      case 'pendingNotificationRequests':
        return [
          for (final p in pending.values)
            {
              'id': p['id'],
              'title': p['title'],
              'body': p['body'],
              'payload': p['payload'],
            },
        ];
      case 'canScheduleExactNotifications':
        return canExact;
    }
    return null;
  }

  List<String> get titles =>
      [for (final p in pending.values) p['title']! as String]..sort();

  /// A class reminder already scheduled by the timetable code.
  void addClassReminder() =>
      pending[1] = {'id': 1, 'title': '📅 Class Starting Soon', 'payload': ''};
}

const store = AssignmentReminderStore();

/// A due date [days] from now in VTOP's format, so the reminders are always
/// in the future whenever the test runs.
String dueIn(int days) => DateFormat(
  'dd-MMM-yyyy',
).format(tz.TZDateTime.now(tz.local).add(Duration(days: days)));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeNotifications os;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    os = _FakeNotifications();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          os.handle,
        );
  });

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  Future<void> fetched(List<DigitalAssignment> assignments) async {
    await store.saveAssignments(assignments);
    await store.reschedule();
  }

  test('defaults to every lead, enabled', () async {
    final settings = await store.readSettings();
    expect(settings.enabled, isTrue);
    expect(settings.leads, ReminderLead.values.toSet());
  });

  test('settings round-trip, and unknown leads are dropped', () async {
    await store.writeSettings(
      const AssignmentReminderSettings(
        enabled: false,
        leads: {ReminderLead.oneDay},
      ),
    );
    var settings = await store.readSettings();
    expect(settings.enabled, isFalse);
    expect(settings.leads, {ReminderLead.oneDay});

    SharedPreferences.setMockInitialValues({
      'assignment_reminder_leads': ['oneHour', 'twoWeeks'],
    });
    settings = await store.readSettings();
    expect(settings.leads, {ReminderLead.oneHour});
  });

  test('a fetch schedules every reminder for work due in 10 days', () async {
    await fetched([
      course([detail(dueDate: dueIn(10))]),
    ]);
    expect(os.titles, [
      '📝 DA-1 due in 1 hour',
      '📝 DA-1 due in 3 days',
      '📝 DA-1 due in 7 days',
      '📝 DA-1 due tomorrow',
    ]);
    expect(
      os.pending.values.map(
        (p) => (p['platformSpecifics']! as Map)['scheduleMode'],
      ),
      everyElement('exactAllowWhileIdle'),
    );
  });

  // Every preference change cancels all notifications and rebuilds them;
  // assignment reminders must come back from the cache without a fetch.
  test('rebuilding replaces reminders instead of stacking them', () async {
    await fetched([
      course([detail(dueDate: dueIn(10))]),
    ]);
    await store.reschedule();
    await store.reschedule();
    expect(os.pending, hasLength(4));
  });

  // Several chips tapped quickly used to overlap: each run cancelled before
  // the other scheduled, so a lead just turned off could keep its reminders.
  test('overlapping reschedules settle on the latest settings', () async {
    await store.saveAssignments([
      course([detail(dueDate: dueIn(10))]),
    ]);
    final first = store.reschedule();
    await store.writeSettings(
      const AssignmentReminderSettings(
        enabled: true,
        leads: {ReminderLead.oneHour},
      ),
    );
    await Future.wait([first, store.reschedule()]);
    expect(os.titles, ['📝 DA-1 due in 1 hour']);
  });

  test('changing the leads reschedules only those', () async {
    await fetched([
      course([detail(dueDate: dueIn(10))]),
    ]);
    await store.writeSettings(
      const AssignmentReminderSettings(
        enabled: true,
        leads: {ReminderLead.oneDay, ReminderLead.oneHour},
      ),
    );
    await store.reschedule();
    expect(os.titles, ['📝 DA-1 due in 1 hour', '📝 DA-1 due tomorrow']);
  });

  test('turning reminders off cancels them but not class reminders', () async {
    os.addClassReminder();
    await fetched([
      course([detail(dueDate: dueIn(10))]),
    ]);
    await store.writeSettings(
      AssignmentReminderSettings.defaults.copyWith(enabled: false),
    );
    await store.reschedule();
    expect(os.titles, ['📅 Class Starting Soon']);
  });

  test('an upload silences only that assignment', () async {
    await fetched([
      course([
        detail(dueDate: dueIn(10), title: 'DA-1', mcode: 'a'),
        detail(dueDate: dueIn(10), title: 'DA-2', mcode: 'b'),
      ]),
    ]);
    await store.markSubmitted(classId: 'AP1', mcode: 'a');
    expect(os.titles, everyElement(startsWith('📝 DA-2')));
    expect(os.pending, hasLength(4));

    // And it stays gone when something later rebuilds the schedule.
    await store.reschedule();
    expect(os.titles, everyElement(startsWith('📝 DA-2')));
  });

  test('logging out clears the cache and its reminders', () async {
    os.addClassReminder();
    await fetched([
      course([detail(dueDate: dueIn(10))]),
    ]);
    await store.clearAssignments();
    expect(os.titles, ['📅 Class Starting Soon']);
    await store.reschedule();
    expect(os.titles, ['📅 Class Starting Soon']);
  });

  test(
    'falls back to inexact alarms without the exact-alarm permission',
    () async {
      os.canExact = false;
      await fetched([
        course([detail(dueDate: dueIn(10))]),
      ]);
      expect(
        os.pending.values.map(
          (p) => (p['platformSpecifics']! as Map)['scheduleMode'],
        ),
        everyElement('inexactAllowWhileIdle'),
      );
    },
  );

  test('a corrupt cache schedules nothing instead of throwing', () async {
    SharedPreferences.setMockInitialValues({
      'assignment_reminder_assignments': '{not json',
    });
    await store.reschedule();
    expect(os.pending, isEmpty);
  });
}
