// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outing_local_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(outingLocalRepository)
final outingLocalRepositoryProvider = OutingLocalRepositoryProvider._();

final class OutingLocalRepositoryProvider
    extends
        $FunctionalProvider<
          OutingLocalRepository,
          OutingLocalRepository,
          OutingLocalRepository
        >
    with $Provider<OutingLocalRepository> {
  OutingLocalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outingLocalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outingLocalRepositoryHash();

  @$internal
  @override
  $ProviderElement<OutingLocalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OutingLocalRepository create(Ref ref) {
    return outingLocalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OutingLocalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OutingLocalRepository>(value),
    );
  }
}

String _$outingLocalRepositoryHash() =>
    r'19108af6649a4643f4abd12b14b818be07b04e98';
