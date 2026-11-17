import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/models/user_preferences.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/reminder_scheduler.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

/// Refuses to schedule, the way a denied exact-alarm permission does.
class _RefusingNotificationService extends Fake implements NotificationService {
  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<void> scheduleTimetableNotifications({
    required User user,
    required UserPreferences prefs,
  }) async => throw StateError('exact alarms not permitted');

  @override
  Future<void> scheduleExamNotifications({
    required User user,
    required UserPreferences prefs,
  }) async => throw StateError('exact alarms not permitted');
}

void main() {
  group(
    'CurrentUserNotifier.loginUser',
    () {
      late TestDependencies deps;

      setUp(() async {
        deps = testDependencies();
      });

      ProviderContainer newContainer() {
        final container = ProviderContainer(
          overrides: [
            ...deps.overrides,
            notificationServiceProvider.overrideWithValue(
              _RefusingNotificationService(),
            ),
          ],
        );
        addTearDown(container.dispose);
        // Started at app launch; reminders follow the user from there.
        container.read(reminderSchedulerProvider);
        return container;
      }

      /// The bug this locks down: scheduling class reminders shared `loginUser`'s
      /// `catch`, which rolled the account back with `removeAllUserData`. So
      /// anything that upset the reminder schedule — a refused alarm, an
      /// uninitialised plugin — deleted every row the student had just signed in
      /// to see, while leaving their saved credentials in place. Nothing awaited
      /// the call either, so it happened in silence and the app carried on to a
      /// home page with no account behind it.
      ///
      /// Scheduling fails here on purpose, through [_RefusingNotificationService].
      /// The analytics assertion is what keeps this honest: without it the test
      /// would still pass if scheduling had quietly started succeeding, and
      /// would no longer be testing anything.
      test('keeps the account when scheduling reminders fails', () async {
        final ref = newContainer();

        await ref
            .read(currentUserProvider.notifier)
            .loginUser(newUser(), testCredentials());
        // Reminders are scheduled off the back of the state change.
        await pumpEventQueue();

        expect(deps.analytics.errorTypes, contains('notification_error'));
        expect(deps.store.count<User>(), 1);
        expect(ref.read(currentUserProvider), isNotNull);
        expect(deps.secureStorage.saved?.registrationNumber, '23BCE0001');
      });

      /// Changing semester logs in again on top of a signed-in session. When
      /// the keychain refused the new credentials, the rollback deleted the
      /// stored user but left the old one in state, so every screen went on
      /// reading relations whose rows were gone.
      test('signs out when storing a repeat login fails', () async {
        final ref = newContainer();
        await ref
            .read(currentUserProvider.notifier)
            .loginUser(newUser(), testCredentials());
        deps.secureStorage.refuseSaves = true;

        await expectLater(
          ref
              .read(currentUserProvider.notifier)
              .loginUser(newUser(), testCredentials(semSubId: 'AP2026273')),
          throwsException,
        );

        expect(ref.read(currentUserProvider), isNull);
        expect(deps.store.count<User>(), 0);
      });
    },
    skip: objectBoxAvailable ? false : objectBoxMissingReason,
  );
}
