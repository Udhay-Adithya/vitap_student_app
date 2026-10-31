import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/assignment_reminder_section.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/assignment_reminder_store.dart';
import 'package:vit_ap_student_app/features/digital_assignment/utils/assignment_reminders.dart';

Future<void> pumpSection(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        analyticsServiceProvider.overrideWithValue(
          const NoopAnalyticsService(),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: AssignmentReminderSection()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

bool chipSelected(WidgetTester tester, String label) =>
    tester.widget<FilterChip>(find.widgetWithText(FilterChip, label)).selected;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          (call) async =>
              call.method == 'pendingNotificationRequests' ? [] : null,
        );
  });

  // The plugin only reaches its Android implementation on Android.
  final android = TargetPlatformVariant.only(TargetPlatform.android);

  testWidgets('offers all four lead times, all on by default', (tester) async {
    await pumpSection(tester);
    for (final lead in ReminderLead.values) {
      expect(chipSelected(tester, lead.label), isTrue);
    }
  }, variant: android);

  testWidgets('deselecting a chip saves the change', (tester) async {
    await pumpSection(tester);
    await tester.tap(find.widgetWithText(FilterChip, '7 days'));
    await tester.pumpAndSettle();

    expect(chipSelected(tester, '7 days'), isFalse);
    final saved = await const AssignmentReminderStore().readSettings();
    expect(saved.leads, isNot(contains(ReminderLead.sevenDays)));
  }, variant: android);

  // An empty selection with the switch still on would look enabled while
  // scheduling nothing at all.
  testWidgets('the last chip cannot be deselected', (tester) async {
    SharedPreferences.setMockInitialValues({
      'assignment_reminder_leads': ['oneHour'],
    });
    await pumpSection(tester);
    await tester.tap(find.widgetWithText(FilterChip, '1 hour'));
    await tester.pump();

    expect(
      find.text('Keep at least one, or turn reminders off'),
      findsOneWidget,
    );
    expect(chipSelected(tester, '1 hour'), isTrue);
    await tester.pump(const Duration(seconds: 3));
  }, variant: android);

  testWidgets('the switch hides the lead times and is remembered', (
    tester,
  ) async {
    await pumpSection(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.byType(FilterChip), findsNothing);
    expect(
      (await const AssignmentReminderStore().readSettings()).enabled,
      isFalse,
    );
  }, variant: android);
}
