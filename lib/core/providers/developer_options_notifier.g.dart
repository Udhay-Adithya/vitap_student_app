// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'developer_options_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeveloperOptionsNotifier)
final developerOptionsProvider = DeveloperOptionsNotifierProvider._();

final class DeveloperOptionsNotifierProvider
    extends
        $AsyncNotifierProvider<
          DeveloperOptionsNotifier,
          DeveloperOptionsState
        > {
  DeveloperOptionsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'developerOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$developerOptionsNotifierHash();

  @$internal
  @override
  DeveloperOptionsNotifier create() => DeveloperOptionsNotifier();
}

String _$developerOptionsNotifierHash() =>
    r'33845fb686dd0729aacef0c5e236903790e8f187';

abstract class _$DeveloperOptionsNotifier
    extends $AsyncNotifier<DeveloperOptionsState> {
  FutureOr<DeveloperOptionsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<DeveloperOptionsState>, DeveloperOptionsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DeveloperOptionsState>,
                DeveloperOptionsState
              >,
              AsyncValue<DeveloperOptionsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
