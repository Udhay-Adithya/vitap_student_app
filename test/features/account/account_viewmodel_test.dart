import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/features/account/repository/account_remote_repository.dart';
import 'package:vit_ap_student_app/features/account/viewmodel/account_viewmodel.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

/// Counts calls, so a test can assert that a sync made none.
class _FakeAccountRepository extends Fake implements AccountRemoteRepository {
  int calls = 0;

  @override
  Future<Either<Failure, User>> syncUser({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) async {
    calls++;
    return Right(newUser());
  }
}

void main() {
  group('AccountViewModel', () {
    late _FakeAccountRepository repository;
    late RecordingAnalyticsService analytics;

    Future<ProviderContainer> harness({bool signedIn = true}) async {
      final deps = testDependencies(
        credentials: signedIn ? testCredentials() : null,
      );
      analytics = deps.analytics;
      repository = _FakeAccountRepository();
      final container = ProviderContainer(
        overrides: [
          ...deps.overrides,
          accountRemoteRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      // Auto-disposed: without a listener the notifier is torn down between
      // reads and its state reads back as null.
      container.listen(accountViewModelProvider, (_, _) {});
      return container;
    }

    /// Locks down a fall-through: with no saved credentials the error was
    /// built but never assigned to state, so the sync carried on to
    /// `credentials!` and threw a null-check error, leaving the page on a
    /// spinner instead of telling the student to log in again.
    test('reports missing credentials without reaching VTOP', () async {
      final ref = await harness(signedIn: false);

      await ref.read(accountViewModelProvider.notifier).sync();

      expect(repository.calls, 0);
      expect(analytics.errorTypes, ['sync_credentials_missing']);
      final state = ref.read(accountViewModelProvider);
      expect(state?.hasError, isTrue);
      expect(state?.error, 'User not found. Please Logout and Login.');
    });
  }, skip: objectBoxAvailable ? false : objectBoxMissingReason);
}
