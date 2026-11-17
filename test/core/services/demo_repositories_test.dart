import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vit_ap_student_app/core/error/exceptions.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/account/repository/account_remote_repository.dart';
import 'package:vit_ap_student_app/features/account/repository/demo_account_repository.dart';
import 'package:vit_ap_student_app/features/attendance/repository/attendance_remote_repository.dart';
import 'package:vit_ap_student_app/features/attendance/repository/demo_attendance_repository.dart';
import 'package:vit_ap_student_app/features/attendance/viewmodel/attendance_viewmodel.dart';
import 'package:vit_ap_student_app/features/course_page/repository/course_page_remote_repository.dart';
import 'package:vit_ap_student_app/features/course_page/repository/demo_course_page_repository.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/demo_digital_assignment_repository.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/digital_assignment_remote_repository.dart';
import 'package:vit_ap_student_app/features/grade_view/repository/demo_grade_view_repository.dart';
import 'package:vit_ap_student_app/features/grade_view/repository/grade_view_remote_repository.dart';
import 'package:vit_ap_student_app/features/home/repository/demo_faculty_repository.dart';
import 'package:vit_ap_student_app/features/home/repository/demo_home_repository.dart';
import 'package:vit_ap_student_app/features/home/repository/demo_outing_repository.dart';
import 'package:vit_ap_student_app/features/home/repository/faculty_repository.dart';
import 'package:vit_ap_student_app/features/home/repository/home_remote_repository.dart';
import 'package:vit_ap_student_app/features/home/repository/outing_remote_repository.dart';
import 'package:vit_ap_student_app/features/timetable/repository/demo_timetable_repository.dart';
import 'package:vit_ap_student_app/features/timetable/repository/timetable_remote_repository.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await DemoService.instance.setDemoMode(false);
  });

  tearDown(() => DemoService.instance.setDemoMode(false));

  /// Demo mode used to be a branch at the top of 18 view models, and a new
  /// screen that forgot its branch sent the demo account's placeholder
  /// credentials towards VTOP. The choice now lives in the repository
  /// providers, so this is the one place it can go wrong.
  test('switching demo mode swaps every vtop repository', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    List<Object> repositories() => [
      container.read(accountRemoteRepositoryProvider),
      container.read(attendanceRemoteRepositoryProvider),
      container.read(coursePageRemoteRepositoryProvider),
      container.read(digitalAssignmentRemoteRepositoryProvider),
      container.read(gradeViewRemoteRepositoryProvider),
      container.read(facultyRepositoryProvider),
      container.read(homeRemoteRepositoryProvider),
      container.read(outingRemoteRepositoryProvider),
      container.read(timetableRemoteRepositoryProvider),
    ];

    expect(
      repositories().map((r) => r.runtimeType.toString()),
      everyElement(startsWith('Vtop')),
    );

    await container.read(demoModeProvider.notifier).set(true);

    expect(repositories(), [
      isA<DemoAccountRepository>(),
      isA<DemoAttendanceRepository>(),
      isA<DemoCoursePageRepository>(),
      isA<DemoDigitalAssignmentRepository>(),
      isA<DemoGradeViewRepository>(),
      isA<DemoFacultyRepository>(),
      isA<DemoHomeRepository>(),
      isA<DemoOutingRepository>(),
      isA<DemoTimetableRepository>(),
    ]);
    expect(DemoService.isDemoMode, isTrue, reason: 'the flag is persisted too');
  });

  test('refuses what would need vtop', () async {
    final result = await DemoOutingRepository(DemoService.instance)
        .submitGeneralOutingForm(
          registrationNumber: 'R',
          password: 'p',
          outPlace: 'Vijayawada',
          purposeOfVisit: 'Shopping',
          outingDate: '14-Nov-2026',
          outTime: '09:00',
          inDate: '14-Nov-2026',
          inTime: '18:00',
        );

    expect(result.isLeft(), isTrue);
    expect(
      result.getLeft().toNullable()?.message,
      const DemoModeException().message,
    );
  });

  group(
    'a view model in demo mode',
    () {
      test('serves the bundled dataset through its repository', () async {
        final deps = testDependencies(
          credentials: DemoService.instance.credentials,
        );
        await DemoService.instance.setDemoMode(true);
        final container = ProviderContainer(overrides: deps.overrides);
        addTearDown(container.dispose);
        container.listen(attendanceViewModeProvider, (_, _) {});

        await container
            .read(attendanceViewModeProvider.notifier)
            .refreshAttendance();

        final state = container.read(attendanceViewModeProvider);
        expect(state?.hasError, isFalse, reason: '${state?.error}');
        expect(state?.value, isNotEmpty);
      });
    },
    skip: objectBoxAvailable ? false : objectBoxMissingReason,
  );
}
