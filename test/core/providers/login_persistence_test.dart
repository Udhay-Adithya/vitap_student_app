import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:objectbox/objectbox.dart';
import 'package:vit_ap_student_app/core/models/attendance.dart';
import 'package:vit_ap_student_app/core/models/capstone_attendance.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/exam_schedule.dart';
import 'package:vit_ap_student_app/core/models/mark.dart';
import 'package:vit_ap_student_app/core/models/profile.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/secure_store_service.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';

import '../../helpers/object_box_test_store.dart';

/// Keeps credentials in memory. The real one reaches for the platform's
/// keychain, which a unit test has no access to.
class _FakeSecureStorageService extends SecureStorageService {
  _FakeSecureStorageService() : super(const FlutterSecureStorage());

  Credentials? saved;

  @override
  Future<void> saveCredentials(Credentials credentials) async {
    saved = credentials;
  }

  @override
  Future<Credentials?> getCredentials() async => saved;
}

/// Records the error types reported, so a test can tell the difference between
/// "the reminder schedule succeeded" and "it failed and was swallowed".
class _RecordingAnalyticsService extends NoopAnalyticsService {
  final List<String> errorTypes = [];

  @override
  void logError(String errorType, Object error, {String? location}) {
    errorTypes.add(errorType);
  }
}

User newUser() => User(
  profile: ToOne<Profile>(),
  attendance: ToMany<Attendance>(items: []),
  timetable: ToOne<Timetable>(),
  examSchedule: ToMany<ExamSchedule>(items: []),
  marks: ToMany<Mark>(items: []),
  capstoneAttendance: ToOne<CapstoneAttendance>(),
);

Credentials testCredentials() => Credentials(
  registrationNumber: '23BCE0001',
  password: 'not-a-real-password',
  semSubId: 'AP2026272',
);

void main() {
  group(
    'CurrentUserNotifier.loginUser',
    () {
      late TestStore testStore;
      late _FakeSecureStorageService secureStorage;
      late _RecordingAnalyticsService analytics;

      setUp(() async {
        testStore = TestStore.open();
        secureStorage = _FakeSecureStorageService();
        analytics = _RecordingAnalyticsService();

        // get_it's reset is asynchronous; registering without awaiting it first
        // leaves the registrations to be wiped by the reset that follows.
        await serviceLocator.reset();
        serviceLocator.registerSingleton<Store>(testStore.store);
        serviceLocator.registerSingleton<SecureStorageService>(secureStorage);
        serviceLocator.registerSingleton<AnalyticsService>(analytics);
        addTearDown(serviceLocator.reset);
      });

      ProviderContainer newContainer() {
        final container = ProviderContainer();
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
      /// The notification plugin is never initialised under `flutter test`, so
      /// scheduling really does fail here. The analytics assertion is what keeps
      /// this honest: without it the test would still pass if scheduling had
      /// quietly started succeeding, and would no longer be testing anything.
      test('keeps the account when scheduling reminders fails', () async {
        final ref = newContainer();

        await ref
            .read(currentUserProvider.notifier)
            .loginUser(newUser(), testCredentials());

        expect(analytics.errorTypes, contains('notification_error'));
        expect(testStore.count<User>(), 1);
        expect(ref.read(currentUserProvider), isNotNull);
        expect(secureStorage.saved?.registrationNumber, '23BCE0001');
      });
    },
    skip: objectBoxAvailable ? false : objectBoxMissingReason,
  );
}
