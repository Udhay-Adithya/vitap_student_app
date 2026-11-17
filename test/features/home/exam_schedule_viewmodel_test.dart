import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/models/exam_schedule.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/home/repository/home_remote_repository.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/exam_schedule_viewmodel.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

/// Counts calls, so a test can assert that a refresh made none.
class _FakeHomeRepository extends HomeRemoteRepository {
  _FakeHomeRepository() : super(http.Client(), VtopClientService());

  int calls = 0;

  @override
  Future<Either<Failure, List<ExamSchedule>>> fetchExamSchedule({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) async {
    calls++;
    return const Right([]);
  }
}

void main() {
  group(
    'ExamScheduleViewModel',
    () {
      late _FakeHomeRepository repository;

      Future<ProviderContainer> harness({bool signedIn = true}) async {
        final deps = testDependencies(
          credentials: signedIn ? testCredentials() : null,
        );
        repository = _FakeHomeRepository();
        final container = ProviderContainer(
          overrides: [
            ...deps.overrides,
            homeRemoteRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);
        // Auto-disposed: without a listener the notifier is torn down between
        // reads and its state reads back as null.
        container.listen(examScheduleViewModelProvider, (_, _) {});
        return container;
      }

      /// Locks down a fall-through: with no saved credentials the error was
      /// built but never assigned to state, so the refresh carried on to
      /// `credentials!` and threw a null-check error, leaving the page on a
      /// spinner instead of telling the student to log in again.
      test('reports missing credentials without reaching VTOP', () async {
        final ref = await harness(signedIn: false);

        await ref
            .read(examScheduleViewModelProvider.notifier)
            .refreshExamSchedule();

        expect(repository.calls, 0);
        final state = ref.read(examScheduleViewModelProvider);
        expect(state?.hasError, isTrue);
        expect(state?.error, 'User not found. Please Logout and Login.');
      });
    },
    skip: objectBoxAvailable ? false : objectBoxMissingReason,
  );
}
