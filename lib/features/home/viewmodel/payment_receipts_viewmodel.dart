import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/home/model/payment_receipt.dart';
import 'package:vit_ap_student_app/features/home/repository/home_remote_repository.dart';

part 'payment_receipts_viewmodel.g.dart';

@riverpod
class PaymentReceiptsViewModel extends _$PaymentReceiptsViewModel {
  late HomeRemoteRepository _homeRemoteRepository;

  @override
  AsyncValue<List<PaymentReceipt>>? build() {
    _homeRemoteRepository = ref.watch(homeRemoteRepositoryProvider);

    return null;
  }

  Future<void> fetchPendingPayments() async {
    state = const AsyncValue.loading();

    // Demo mode: serve bundled sample payment receipts.
    if (DemoService.isDemoMode) {
      state = AsyncValue.data(await DemoService.instance.paymentReceipts());
      return;
    }

    final credentials = await ref
        .read(currentUserProvider.notifier)
        .getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error('error', StackTrace.current);
      return;
    }
    final res = await _homeRemoteRepository.fetchPaymentReceipts(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
    );

    state = switch (res) {
      Left(value: final failure) =>
        AsyncValue.error(failure.message, StackTrace.current),
      Right(value: final paymentReceipts) => AsyncValue.data(paymentReceipts),
    };
  }
}
