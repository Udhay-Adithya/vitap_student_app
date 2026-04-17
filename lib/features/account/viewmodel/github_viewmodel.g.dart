// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChangelogViewModel)
final changelogViewModelProvider = ChangelogViewModelProvider._();

final class ChangelogViewModelProvider
    extends $NotifierProvider<ChangelogViewModel, AsyncValue<String>?> {
  ChangelogViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changelogViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changelogViewModelHash();

  @$internal
  @override
  ChangelogViewModel create() => ChangelogViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String>?>(value),
    );
  }
}

String _$changelogViewModelHash() =>
    r'8421f5594034da43f72e961a59f4892f7240ed2f';

abstract class _$ChangelogViewModel extends $Notifier<AsyncValue<String>?> {
  AsyncValue<String>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>?, AsyncValue<String>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>?, AsyncValue<String>?>,
              AsyncValue<String>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ContributorsViewModel)
final contributorsViewModelProvider = ContributorsViewModelProvider._();

final class ContributorsViewModelProvider
    extends
        $NotifierProvider<
          ContributorsViewModel,
          AsyncValue<List<Contributor>>
        > {
  ContributorsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contributorsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contributorsViewModelHash();

  @$internal
  @override
  ContributorsViewModel create() => ContributorsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Contributor>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Contributor>>>(
        value,
      ),
    );
  }
}

String _$contributorsViewModelHash() =>
    r'49ec85e9df21acbd74909f2a68985887e26b1c33';

abstract class _$ContributorsViewModel
    extends $Notifier<AsyncValue<List<Contributor>>> {
  AsyncValue<List<Contributor>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<Contributor>>,
              AsyncValue<List<Contributor>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<Contributor>>,
                AsyncValue<List<Contributor>>
              >,
              AsyncValue<List<Contributor>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
