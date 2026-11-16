// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's ObjectBox store.
///
/// Opening a store is asynchronous and has to finish before the first frame,
/// so there is nothing here to build: `initDependencies` opens it and supplies
/// it as an override, and tests override it with a throwaway store.

@ProviderFor(store)
final storeProvider = StoreProvider._();

/// The app's ObjectBox store.
///
/// Opening a store is asynchronous and has to finish before the first frame,
/// so there is nothing here to build: `initDependencies` opens it and supplies
/// it as an override, and tests override it with a throwaway store.

final class StoreProvider extends $FunctionalProvider<Store, Store, Store>
    with $Provider<Store> {
  /// The app's ObjectBox store.
  ///
  /// Opening a store is asynchronous and has to finish before the first frame,
  /// so there is nothing here to build: `initDependencies` opens it and supplies
  /// it as an override, and tests override it with a throwaway store.
  StoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeHash();

  @$internal
  @override
  $ProviderElement<Store> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Store create(Ref ref) {
    return store(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Store value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Store>(value),
    );
  }
}

String _$storeHash() => r'02b4df87f9ff472a72f472ad068f0a55197cb530';
