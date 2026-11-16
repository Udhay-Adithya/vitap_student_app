// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(githubRepository)
final githubRepositoryProvider = GithubRepositoryProvider._();

final class GithubRepositoryProvider
    extends
        $FunctionalProvider<
          GithubRepository,
          GithubRepository,
          GithubRepository
        >
    with $Provider<GithubRepository> {
  GithubRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'githubRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$githubRepositoryHash();

  @$internal
  @override
  $ProviderElement<GithubRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GithubRepository create(Ref ref) {
    return githubRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GithubRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GithubRepository>(value),
    );
  }
}

String _$githubRepositoryHash() => r'16965b36c82757ba4095447f8c1560f3a48171ad';
