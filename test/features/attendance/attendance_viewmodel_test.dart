import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/models/attendance.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/attendance/repository/attendance_remote_repository.dart';
import 'package:vit_ap_student_app/features/attendance/viewmodel/attendance_viewmodel.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

Attendance attendance(String courseCode) => Attendance(
  classNumber: '1',
  faculty: 'Test Faculty',
  courseId: 'AM_${courseCode}_00200',
  courseCode: courseCode,
  courseName: 'A course',
  courseType: 'Theory Only',
  courseTypeCode: 'TH',
  courseSlot: 'A1',
  attendedClasses: '23',
  totalClasses: '25',
  attendancePercentage: '92',
  betweenAttendancePercentage: '92',
  debarStatus: '-',
);

/// Counts calls, so a test can assert that opening the page made none.
class _FakeAttendanceRepository extends AttendanceRemoteRepository {
  _FakeAttendanceRepository({this.failure}) : super(VtopClientService());

  final String? failure;
  int calls = 0;

  @override
  Future<Either<Failure, AttendanceFetch>> fetchAttendance({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) async {
    calls++;
    if (failure != null) return Left(Failure(failure!));
    return Right((attendances: [attendance('CSE3009')], capstone: null));
  }
}

void main() {
  group('AttendanceViewMode', () {
    late _FakeAttendanceRepository repository;

    Future<ProviderContainer> harness({
      bool signedIn = true,
      String? failure,
    }) async {
      await registerTestDependencies(
        credentials: signedIn ? testCredentials() : null,
      );
      repository = _FakeAttendanceRepository(failure: failure);
      final container = ProviderContainer(
        overrides: [
          attendanceRemoteRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      // Auto-disposed: without a listener the notifier is torn down between
      // reads and its state reads back as null. A page being on screen is
      // exactly this subscription.
      container.listen(attendanceViewModeProvider, (_, _) {});
      return container;
    }

    /// The rule this locks down: VTOP demands an OTP per session, and it can
    /// demand one for a page the student only glanced at. So attendance must
    /// fetch on an explicit tap and never on build. Reading the provider is
    /// what a page open does.
    test('does not fetch when the page is opened', () async {
      final ref = await harness();

      final state = ref.read(attendanceViewModeProvider);

      expect(state, isNull, reason: 'build() must not start a fetch');
      expect(repository.calls, 0);
    });

    test('fetches once on an explicit refresh', () async {
      final ref = await harness();

      await ref.read(attendanceViewModeProvider.notifier).refreshAttendance();

      expect(repository.calls, 1);
      expect(ref.read(attendanceViewModeProvider)?.value, hasLength(1));
    });

    test('shows a loading state while refreshing', () async {
      final ref = await harness();
      final states = <bool>[];
      ref.listen(attendanceViewModeProvider, (_, next) {
        states.add(next?.isLoading ?? false);
      });

      await ref.read(attendanceViewModeProvider.notifier).refreshAttendance();

      expect(states.first, isTrue, reason: 'a refresh must announce itself');
      expect(states.last, isFalse);
    });

    /// A silent refresh runs behind data that is already on screen, so it must
    /// not replace it with a spinner.
    test('a silent refresh never shows loading', () async {
      final ref = await harness();
      final loadingStates = <bool>[];
      ref.listen(attendanceViewModeProvider, (_, next) {
        loadingStates.add(next?.isLoading ?? false);
      });

      await ref
          .read(attendanceViewModeProvider.notifier)
          .refreshAttendance(silentRefresh: true);

      expect(loadingStates, isNot(contains(true)));
      expect(ref.read(attendanceViewModeProvider)?.value, hasLength(1));
    });

    test('reports a failure without leaving a spinner behind', () async {
      final ref = await harness(failure: 'No internet connection');

      await ref.read(attendanceViewModeProvider.notifier).refreshAttendance();

      final state = ref.read(attendanceViewModeProvider);
      expect(state?.hasError, isTrue);
      expect(state?.error, 'No internet connection');
    });

    /// Without saved credentials there is nothing to authenticate with, so the
    /// request must not be attempted at all.
    test('does not reach VTOP when there are no saved credentials', () async {
      final ref = await harness(signedIn: false);

      await ref.read(attendanceViewModeProvider.notifier).refreshAttendance();

      expect(repository.calls, 0);
      expect(ref.read(attendanceViewModeProvider)?.hasError, isTrue);
    });
  }, skip: objectBoxAvailable ? false : objectBoxMissingReason);
}
