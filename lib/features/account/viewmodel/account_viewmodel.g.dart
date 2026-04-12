// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountViewModel)
final accountViewModelProvider = AccountViewModelProvider._();

final class AccountViewModelProvider
    extends $NotifierProvider<AccountViewModel, AsyncValue<User>?> {
  AccountViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountViewModelHash();

  @$internal
  @override
  AccountViewModel create() => AccountViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<User>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<User>?>(value),
    );
  }
}

String _$accountViewModelHash() => r'ff32ce81c96d5b39a2f66795fbb3c2430eb1577c';

abstract class _$AccountViewModel extends $Notifier<AsyncValue<User>?> {
  AsyncValue<User>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<User>?, AsyncValue<User>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<User>?, AsyncValue<User>?>,
              AsyncValue<User>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
