/// Shared setup for tests that drive a real provider graph.
///
/// The view models reach for ObjectBox, the keychain and analytics through
/// `serviceLocator` rather than through Riverpod, so overriding providers alone
/// is not enough to stand one up. This registers throwaway stand-ins for the
/// three, so a test only has to override the repository it cares about.
library;

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
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/secure_store_service.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';

import 'object_box_test_store.dart';

/// Keeps credentials in memory. The real one reaches for the platform's
/// keychain, which a unit test has no access to.
class FakeSecureStorageService extends SecureStorageService {
  FakeSecureStorageService({this.saved}) : super(const FlutterSecureStorage());

  Credentials? saved;

  @override
  Future<void> saveCredentials(Credentials credentials) async {
    saved = credentials;
  }

  @override
  Future<Credentials?> getCredentials() async => saved;
}

/// Records the error types reported, so a test can tell a swallowed failure
/// apart from one that never happened.
class RecordingAnalyticsService extends NoopAnalyticsService {
  final List<String> errorTypes = [];

  @override
  void logError(String errorType, Object error, {String? location}) {
    errorTypes.add(errorType);
  }
}

typedef TestDependencies = ({
  TestStore store,
  FakeSecureStorageService secureStorage,
  RecordingAnalyticsService analytics,
});

/// Registers a throwaway store, keychain and analytics for one test.
///
/// Pass [credentials] for a test that needs a signed-in student; leave it off
/// to exercise the "no saved credentials" path.
Future<TestDependencies> registerTestDependencies({
  Credentials? credentials,
}) async {
  final store = TestStore.open();
  final secureStorage = FakeSecureStorageService(saved: credentials);
  final analytics = RecordingAnalyticsService();

  // get_it's reset is asynchronous; registering without awaiting it first
  // leaves the registrations to be wiped by the reset that follows.
  await serviceLocator.reset();
  serviceLocator.registerSingleton<Store>(store.store);
  serviceLocator.registerSingleton<SecureStorageService>(secureStorage);
  serviceLocator.registerSingleton<AnalyticsService>(analytics);
  addTearDown(serviceLocator.reset);

  return (store: store, secureStorage: secureStorage, analytics: analytics);
}

Credentials testCredentials({String semSubId = 'AP2026272'}) => Credentials(
  registrationNumber: '23BCE0001',
  password: 'not-a-real-password',
  semSubId: semSubId,
);

/// A student with no data hanging off them yet.
User newUser({int? id}) => User(
  id: id,
  profile: ToOne<Profile>(),
  attendance: ToMany<Attendance>(items: []),
  timetable: ToOne<Timetable>(),
  examSchedule: ToMany<ExamSchedule>(items: []),
  marks: ToMany<Mark>(items: []),
  capstoneAttendance: ToOne<CapstoneAttendance>(),
);
