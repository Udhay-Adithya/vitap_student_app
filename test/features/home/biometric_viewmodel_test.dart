import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/home/model/biometric.dart';
import 'package:vit_ap_student_app/features/home/repository/home_remote_repository.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/biometric_viewmodel.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

/// Counts calls and remembers the date asked for.
class _FakeHomeRepository extends HomeRemoteRepository {
  _FakeHomeRepository({this.failure})
    : super(http.Client(), VtopClientService());

  final String? failure;
  int calls = 0;
  String? askedFor;

  @override
  Future<Either<Failure, List<Biometric>>> fetchBiometric({
    required String registrationNumber,
    required String password,
    required String date,
  }) async {
    calls++;
    askedFor = date;
    if (failure != null) return Left(Failure(failure!));
    return Right([Biometric(time: '08:41', location: 'AB1-FACE-IN-2')]);
  }
}

void main() {
  group('BiometricViewModel', () {
    late _FakeHomeRepository repository;

    Future<ProviderContainer> harness({
      bool signedIn = true,
      String? failure,
    }) async {
      await registerTestDependencies(
        credentials: signedIn ? testCredentials() : null,
      );
      repository = _FakeHomeRepository(failure: failure);
      final container = ProviderContainer(
        overrides: [homeRemoteRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      // Auto-disposed: without a listener the notifier is torn down between
      // reads and its state reads back as null. A page being on screen is
      // exactly this subscription.
      container.listen(biometricViewModelProvider, (_, _) {});
      return container;
    }

    /// The rule this locks down: VTOP can demand an OTP for a page the student
    /// only glanced at, so the biometric log fetches on an explicit tap and
    /// never on build. It has no pull-to-refresh for the same reason.
    test('does not fetch when the page is opened', () async {
      final ref = await harness();

      final state = ref.read(biometricViewModelProvider);

      expect(state, isNull, reason: 'build() must not start a fetch');
      expect(repository.calls, 0);
    });

    test('fetches the day it was asked for, once', () async {
      final ref = await harness();

      await ref
          .read(biometricViewModelProvider.notifier)
          .fetchBiometric('25/09/2026');

      expect(repository.calls, 1);
      expect(repository.askedFor, '25/09/2026');
      expect(ref.read(biometricViewModelProvider)?.value, hasLength(1));
    });

    test('shows a loading state while fetching', () async {
      final ref = await harness();
      final loadingStates = <bool>[];
      ref.listen(biometricViewModelProvider, (_, next) {
        loadingStates.add(next?.isLoading ?? false);
      });

      await ref
          .read(biometricViewModelProvider.notifier)
          .fetchBiometric('25/09/2026');

      expect(loadingStates.first, isTrue);
      expect(loadingStates.last, isFalse);
    });

    test('reports a failure instead of staying on the spinner', () async {
      final ref = await harness(failure: 'No internet connection');

      await ref
          .read(biometricViewModelProvider.notifier)
          .fetchBiometric('25/09/2026');

      final state = ref.read(biometricViewModelProvider);
      expect(state?.hasError, isTrue);
      expect(state?.error, 'No internet connection');
    });

    test('does not reach VTOP when there are no saved credentials', () async {
      final ref = await harness(signedIn: false);

      await ref
          .read(biometricViewModelProvider.notifier)
          .fetchBiometric('25/09/2026');

      expect(repository.calls, 0);
      expect(ref.read(biometricViewModelProvider)?.hasError, isTrue);
    });
  }, skip: objectBoxAvailable ? false : objectBoxMissingReason);
}
