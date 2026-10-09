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
import 'package:vit_ap_student_app/features/academic_calendar/model/non_instructional_days.dart';
import 'package:vit_ap_student_app/features/academic_calendar/viewmodel/non_instructional_days_provider.dart';
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

      setUp(() async {
        testStore = TestStore.open();
        secureStorage = _FakeSecureStorageService();

        // get_it's reset is asynchronous; registering without awaiting it first
        // leaves the registrations to be wiped by the reset that follows.
        await serviceLocator.reset();
        serviceLocator.registerSingleton<Store>(testStore.store);
        serviceLocator.registerSingleton<SecureStorageService>(secureStorage);
        serviceLocator.registerSingleton<AnalyticsService>(
          const NoopAnalyticsService(),
        );
        addTearDown(serviceLocator.reset);
      });

      /// [schedulingFailure] stands in for anything that can upset the reminder
      /// schedule. The real provider reads the stored calendar through the VTOP
      /// service, which this has no business standing up.
      ProviderContainer container({Object? schedulingFailure}) {
        final container = ProviderContainer(
          overrides: [
            nonInstructionalDaysProvider.overrideWith((ref) async {
              if (schedulingFailure != null) throw schedulingFailure;
              return NonInstructionalDays.empty;
            }),
          ],
        );
        addTearDown(container.dispose);
        return container;
      }

      test('stores the account', () async {
        final ref = container();

        await ref
            .read(currentUserProvider.notifier)
            .loginUser(newUser(), testCredentials());

        expect(testStore.count<User>(), 1);
        expect(ref.read(currentUserProvider), isNotNull);
        expect(secureStorage.saved?.registrationNumber, '23BCE0001');
      });

      /// The bug this locks down: scheduling class reminders shared `loginUser`'s
      /// `catch`, which rolled the account back with `removeAllUserData`. So
      /// anything that upset the reminder schedule — a refused alarm, an
      /// unreadable stored calendar — deleted every row the student had just
      /// signed in to see, while leaving their saved credentials in place. The
      /// call was not awaited either, so it happened in silence and the app
      /// carried on to a home page with no account behind it.
      test('keeps the account when scheduling reminders fails', () async {
        final ref = container(
          schedulingFailure: StateError('no alarms for you'),
        );

        await ref
            .read(currentUserProvider.notifier)
            .loginUser(newUser(), testCredentials());

        expect(testStore.count<User>(), 1);
        expect(ref.read(currentUserProvider), isNotNull);
        expect(secureStorage.saved?.registrationNumber, '23BCE0001');
      });
    },
    skip: objectBoxAvailable ? false : objectBoxMissingReason,
  );
}
