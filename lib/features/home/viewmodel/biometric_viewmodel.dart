import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/home/model/biometric.dart';
import 'package:vit_ap_student_app/features/home/repository/home_remote_repository.dart';

part 'biometric_viewmodel.g.dart';

@riverpod
class BiometricViewModel extends _$BiometricViewModel {
  late HomeRemoteRepository _homeRemoteRepository;

  @override
  AsyncValue<List<Biometric>>? build() {
    _homeRemoteRepository = ref.watch(homeRemoteRepositoryProvider);

    return null;
  }

  Future<void> fetchBiometric(String date) async {
    state = const AsyncValue.loading();

    // Demo mode: serve bundled sample biometric log.
    if (DemoService.isDemoMode) {
      state = AsyncValue.data(await DemoService.instance.biometric());
      return;
    }

    final credentials = await ref
        .read(currentUserProvider.notifier)
        .getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error('error', StackTrace.current);
      return;
    }
    final res = await _homeRemoteRepository.fetchBiometric(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      date: date,
    );

    state = switch (res) {
      Left(value: final failure) =>
        AsyncValue.error(failure.message, StackTrace.current),
      Right(value: final weather) => AsyncValue.data(weather),
    };
  }
}
