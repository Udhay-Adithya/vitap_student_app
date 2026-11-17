// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_payments_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PendingPaymentsViewModel)
final pendingPaymentsViewModelProvider = PendingPaymentsViewModelProvider._();

final class PendingPaymentsViewModelProvider
    extends
        $NotifierProvider<
          PendingPaymentsViewModel,
          AsyncValue<List<PendingPayment>>?
        > {
  PendingPaymentsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingPaymentsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingPaymentsViewModelHash();

  @$internal
  @override
  PendingPaymentsViewModel create() => PendingPaymentsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<PendingPayment>>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<PendingPayment>>?>(
        value,
      ),
    );
  }
}

String _$pendingPaymentsViewModelHash() =>
    r'903425b94ed50d7f4e52fa7811c9745eb0d0a809';

abstract class _$PendingPaymentsViewModel
    extends $Notifier<AsyncValue<List<PendingPayment>>?> {
  AsyncValue<List<PendingPayment>>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<PendingPayment>>?,
              AsyncValue<List<PendingPayment>>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PendingPayment>>?,
                AsyncValue<List<PendingPayment>>?
              >,
              AsyncValue<List<PendingPayment>>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
