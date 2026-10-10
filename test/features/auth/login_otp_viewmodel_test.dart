import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/auth/repository/auth_remote_repository.dart';
import 'package:vit_ap_student_app/features/auth/viewmodel/login_otp_viewmodel.dart';

/// VTOP's OTP step, with the answers under the test's control.
class _FakeAuthRepository extends AuthRemoteRepository {
  _FakeAuthRepository({this.submitFailure, this.resendFailure})
    : super(VtopClientService());

  final String? submitFailure;
  final String? resendFailure;
  final List<String> submitted = [];
  int resends = 0;

  @override
  Future<Either<Failure, void>> submitLoginOtp(String otpCode) async {
    submitted.add(otpCode);
    if (submitFailure != null) return Left(Failure(submitFailure!));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> resendLoginOtp() async {
    resends++;
    if (resendFailure != null) return Left(Failure(resendFailure!));
    return const Right(null);
  }
}

void main() {
  group('LoginOtpViewModel', () {
    late _FakeAuthRepository repository;

    ProviderContainer harness({String? submitFailure, String? resendFailure}) {
      repository = _FakeAuthRepository(
        submitFailure: submitFailure,
        resendFailure: resendFailure,
      );
      final container = ProviderContainer(
        overrides: [authRemoteRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      // Auto-disposed: without a listener the notifier is torn down between
      // reads and its state reads back as null. A page being on screen is
      // exactly this subscription.
      container.listen(loginOtpViewModelProvider, (_, _) {});
      return container;
    }

    test('submits nothing until asked', () {
      final ref = harness();

      expect(ref.read(loginOtpViewModelProvider), isNull);
      expect(repository.submitted, isEmpty);
    });

    test('passes the code through and settles on success', () async {
      final ref = harness();

      await ref.read(loginOtpViewModelProvider.notifier).submitOtp('123456');

      expect(repository.submitted, ['123456']);
      final state = ref.read(loginOtpViewModelProvider);
      expect(state?.hasError, isFalse);
      expect(state?.isLoading, isFalse);
    });

    test('shows a loading state while the code is checked', () async {
      final ref = harness();
      final loadingStates = <bool>[];
      ref.listen(loginOtpViewModelProvider, (_, next) {
        loadingStates.add(next?.isLoading ?? false);
      });

      await ref.read(loginOtpViewModelProvider.notifier).submitOtp('123456');

      expect(loadingStates.first, isTrue);
      expect(loadingStates.last, isFalse);
    });

    /// A wrong code has to leave the sheet usable: the student types the next
    /// one into the same field, so the error must land in the state rather than
    /// throwing out of the call.
    test('reports a wrong code without throwing', () async {
      final ref = harness(submitFailure: 'Incorrect OTP entered for login.');

      await ref.read(loginOtpViewModelProvider.notifier).submitOtp('000000');

      final state = ref.read(loginOtpViewModelProvider);
      expect(state?.hasError, isTrue);
      expect(state?.error, 'Incorrect OTP entered for login.');
    });

    test('accepts a second attempt after a wrong code', () async {
      final ref = harness(submitFailure: 'Incorrect OTP entered for login.');
      await ref.read(loginOtpViewModelProvider.notifier).submitOtp('000000');

      await ref.read(loginOtpViewModelProvider.notifier).submitOtp('123456');

      expect(repository.submitted, ['000000', '123456']);
    });

    /// A resend puts the student back where they started — waiting to type a
    /// code — so the state returns to idle rather than reading as success.
    test('returns to idle after a resend', () async {
      final ref = harness();

      await ref.read(loginOtpViewModelProvider.notifier).resendOtp();

      expect(repository.resends, 1);
      expect(ref.read(loginOtpViewModelProvider), isNull);
    });

    test('reports a resend that failed', () async {
      final ref = harness(resendFailure: 'Could not send a new code.');

      await ref.read(loginOtpViewModelProvider.notifier).resendOtp();

      final state = ref.read(loginOtpViewModelProvider);
      expect(state?.hasError, isTrue);
      expect(state?.error, 'Could not send a new code.');
    });
  });
}
