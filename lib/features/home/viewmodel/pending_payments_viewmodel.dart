import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/home/model/pending_payment.dart';
import 'package:vit_ap_student_app/features/home/repository/home_remote_repository.dart';

part 'pending_payments_viewmodel.g.dart';

@riverpod
class PendingPaymentsViewModel extends _$PendingPaymentsViewModel {
  late HomeRemoteRepository _homeRemoteRepository;

  @override
  AsyncValue<List<PendingPayment>>? build() {
    _homeRemoteRepository = ref.watch(homeRemoteRepositoryProvider);

    return null;
  }

  Future<void> fetchPendingPayments() async {
    state = const AsyncValue.loading();

    // Demo mode: serve bundled sample pending payments.
    if (DemoService.isDemoMode) {
      state = AsyncValue.data(await DemoService.instance.pendingPayments());
      return;
    }

    final credentials = await ref
        .read(currentUserProvider.notifier)
        .getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error('error', StackTrace.current);
      return;
    }
    final res = await _homeRemoteRepository.fetchPendingPayments(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
    );

    state = switch (res) {
      Left(value: final failure) =>
        AsyncValue.error(failure.message, StackTrace.current),
      Right(value: final pendingPayments) => AsyncValue.data(pendingPayments),
    };
  }
}
