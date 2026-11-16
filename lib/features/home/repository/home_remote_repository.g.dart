// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_remote_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeRemoteRepository)
final homeRemoteRepositoryProvider = HomeRemoteRepositoryProvider._();

final class HomeRemoteRepositoryProvider
    extends
        $FunctionalProvider<
          HomeRemoteRepository,
          HomeRemoteRepository,
          HomeRemoteRepository
        >
    with $Provider<HomeRemoteRepository> {
  HomeRemoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeRemoteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeRemoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeRemoteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeRemoteRepository create(Ref ref) {
    return homeRemoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeRemoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeRemoteRepository>(value),
    );
  }
}

String _$homeRemoteRepositoryHash() =>
    r'8301bf892427602669def6ee7803be0d5f3d6240';
