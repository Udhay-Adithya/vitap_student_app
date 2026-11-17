// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_remote_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountRemoteRepository)
final accountRemoteRepositoryProvider = AccountRemoteRepositoryProvider._();

final class AccountRemoteRepositoryProvider
    extends
        $FunctionalProvider<
          AccountRemoteRepository,
          AccountRemoteRepository,
          AccountRemoteRepository
        >
    with $Provider<AccountRemoteRepository> {
  AccountRemoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRemoteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRemoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountRemoteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountRemoteRepository create(Ref ref) {
    return accountRemoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRemoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRemoteRepository>(value),
    );
  }
}

String _$accountRemoteRepositoryHash() =>
    r'21578f0ba8bac7fc9d6d146b1111f216af7d0749';
