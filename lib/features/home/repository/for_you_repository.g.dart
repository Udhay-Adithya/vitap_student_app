// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'for_you_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(forYouRepository)
final forYouRepositoryProvider = ForYouRepositoryProvider._();

final class ForYouRepositoryProvider
    extends
        $FunctionalProvider<
          ForYouRepository,
          ForYouRepository,
          ForYouRepository
        >
    with $Provider<ForYouRepository> {
  ForYouRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forYouRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forYouRepositoryHash();

  @$internal
  @override
  $ProviderElement<ForYouRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ForYouRepository create(Ref ref) {
    return forYouRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForYouRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForYouRepository>(value),
    );
  }
}

String _$forYouRepositoryHash() => r'5bd72d8ac0eebd772be1b297598dbde712ddad13';
