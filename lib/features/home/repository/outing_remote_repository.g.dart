// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outing_remote_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(outingRemoteRepository)
final outingRemoteRepositoryProvider = OutingRemoteRepositoryProvider._();

final class OutingRemoteRepositoryProvider
    extends
        $FunctionalProvider<
          OutingRemoteRepository,
          OutingRemoteRepository,
          OutingRemoteRepository
        >
    with $Provider<OutingRemoteRepository> {
  OutingRemoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outingRemoteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outingRemoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<OutingRemoteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OutingRemoteRepository create(Ref ref) {
    return outingRemoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OutingRemoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OutingRemoteRepository>(value),
    );
  }
}

String _$outingRemoteRepositoryHash() =>
    r'e6fd9bca7c09aea1604c5c55abe786c3bce30876';
