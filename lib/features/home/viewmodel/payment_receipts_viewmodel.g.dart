// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_receipts_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaymentReceiptsViewModel)
final paymentReceiptsViewModelProvider = PaymentReceiptsViewModelProvider._();

final class PaymentReceiptsViewModelProvider
    extends
        $NotifierProvider<
          PaymentReceiptsViewModel,
          AsyncValue<List<PaymentReceipt>>?
        > {
  PaymentReceiptsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentReceiptsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentReceiptsViewModelHash();

  @$internal
  @override
  PaymentReceiptsViewModel create() => PaymentReceiptsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<PaymentReceipt>>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<PaymentReceipt>>?>(
        value,
      ),
    );
  }
}

String _$paymentReceiptsViewModelHash() =>
    r'b4cfd1b6ed84d3ce285c59b2143e20651165b9c8';

abstract class _$PaymentReceiptsViewModel
    extends $Notifier<AsyncValue<List<PaymentReceipt>>?> {
  AsyncValue<List<PaymentReceipt>>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<PaymentReceipt>>?,
              AsyncValue<List<PaymentReceipt>>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PaymentReceipt>>?,
                AsyncValue<List<PaymentReceipt>>?
              >,
              AsyncValue<List<PaymentReceipt>>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
