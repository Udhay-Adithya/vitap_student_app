import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/models/user_preferences.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

/// Refuses to schedule, the way a denied exact-alarm permission does.
class _RefusingNotificationService extends Fake implements NotificationService {
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

        expect(deps.analytics.errorTypes, contains('notification_error'));
        expect(deps.store.count<User>(), 1);
        expect(ref.read(currentUserProvider), isNotNull);
        expect(deps.secureStorage.saved?.registrationNumber, '23BCE0001');
      });
    },
    skip: objectBoxAvailable ? false : objectBoxMissingReason,
  );
}
