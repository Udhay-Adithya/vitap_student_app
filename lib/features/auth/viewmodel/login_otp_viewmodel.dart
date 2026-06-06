import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/features/auth/repository/auth_remote_repository.dart';

part 'login_otp_viewmodel.g.dart';

@riverpod
class LoginOtpViewModel extends _$LoginOtpViewModel {
  late AuthRemoteRepository _repository;

  @override
  AsyncValue<void>? build() {
    _repository = ref.watch(authRemoteRepositoryProvider);
    return null;
  }

  Future<void> submitOtp(String otpCode) async {
    state = const AsyncValue.loading();

    final res = await _repository.submitLoginOtp(otpCode);

    switch (res) {
      case Left(value: final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);
      case Right():
        state = const AsyncValue.data(null);
    }
  }

  Future<void> resendOtp() async {
    state = const AsyncValue.loading();

    final res = await _repository.resendLoginOtp();

    switch (res) {
      case Left(value: final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);
      case Right():
        // Reset to idle after successful resend so user can enter OTP
        state = null;
    }
  }
}
