import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/models/mark.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/grade_view/model/grade_view_course.dart';
import 'package:vit_ap_student_app/features/grade_view/repository/grade_view_remote_repository.dart';
import 'package:vit_ap_student_app/features/home/repository/home_remote_repository.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/marks_viewmodel.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

/// Counts calls, so a test can assert that a refresh made none.
class _FakeHomeRepository extends HomeRemoteRepository {
  _FakeHomeRepository() : super(http.Client(), VtopClientService());

  int calls = 0;

  @override
  Future<Either<Failure, List<Mark>>> fetchMarks({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) async {
    calls++;
    return const Right([]);
  }
}

class _FakeGradeViewRepository extends GradeViewRemoteRepository {
  _FakeGradeViewRepository() : super(VtopClientService());

  int calls = 0;

  @override
  Future<Either<Failure, List<GradeViewCourseModel>>> fetchGradeView({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) async {
    calls++;
    return const Right([]);
  }
}

void main() {
  group('MarksViewModel', () {
    late _FakeHomeRepository homeRepository;
    late _FakeGradeViewRepository gradeViewRepository;

    Future<ProviderContainer> harness({bool signedIn = true}) async {
      final deps = testDependencies(
        credentials: signedIn ? testCredentials() : null,
      );
      homeRepository = _FakeHomeRepository();
      gradeViewRepository = _FakeGradeViewRepository();
      final container = ProviderContainer(
        overrides: [
          ...deps.overrides,
          homeRemoteRepositoryProvider.overrideWithValue(homeRepository),
          gradeViewRemoteRepositoryProvider.overrideWithValue(
            gradeViewRepository,
          ),
        ],
      );
      addTearDown(container.dispose);
      // Auto-disposed: without a listener the notifier is torn down between
      // reads and its state reads back as null.
      container.listen(marksViewModelProvider, (_, _) {});
      return container;
    }

    /// Locks down a fall-through: with no saved credentials the error was
    /// built but never assigned to state, so the refresh carried on to
    /// `credentials!` and threw a null-check error, leaving the page on a
    /// spinner instead of telling the student to log in again.
    test('reports missing credentials without reaching VTOP', () async {
      final ref = await harness(signedIn: false);

      await ref.read(marksViewModelProvider.notifier).refreshMarks();

      expect(homeRepository.calls, 0);
      expect(gradeViewRepository.calls, 0);
      final state = ref.read(marksViewModelProvider);
      expect(state?.hasError, isTrue);
      expect(state?.error, 'User not found. Please Logout and Login.');
    });
  }, skip: objectBoxAvailable ? false : objectBoxMissingReason);
}
