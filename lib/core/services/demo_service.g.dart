// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(demoService)
final demoServiceProvider = DemoServiceProvider._();

final class DemoServiceProvider
    extends $FunctionalProvider<DemoService, DemoService, DemoService>
    with $Provider<DemoService> {
  DemoServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'demoServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$demoServiceHash();

  @$internal
  @override
  $ProviderElement<DemoService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DemoService create(Ref ref) {
    return demoService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DemoService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DemoService>(value),
    );
  }
}

String _$demoServiceHash() => r'901091cb2b6aed02fbb12b03a894b3e445560af5';

/// Whether the demo account is signed in.
///
/// Repository providers watch this to choose between VTOP and the bundled
/// dataset, so flipping it swaps every data source at once. Change it through
/// [DemoMode.set], which also persists the flag in [DemoService].

@ProviderFor(DemoMode)
final demoModeProvider = DemoModeProvider._();

/// Whether the demo account is signed in.
///
/// Repository providers watch this to choose between VTOP and the bundled
/// dataset, so flipping it swaps every data source at once. Change it through
/// [DemoMode.set], which also persists the flag in [DemoService].
final class DemoModeProvider extends $NotifierProvider<DemoMode, bool> {
  /// Whether the demo account is signed in.
  ///
  /// Repository providers watch this to choose between VTOP and the bundled
  /// dataset, so flipping it swaps every data source at once. Change it through
  /// [DemoMode.set], which also persists the flag in [DemoService].
  DemoModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'demoModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$demoModeHash();

  @$internal
  @override
  DemoMode create() => DemoMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$demoModeHash() => r'afc5a5e3b2acd92b14bb987b85c96e20167daec9';

/// Whether the demo account is signed in.
///
/// Repository providers watch this to choose between VTOP and the bundled
/// dataset, so flipping it swaps every data source at once. Change it through
/// [DemoMode.set], which also persists the flag in [DemoService].

abstract class _$DemoMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
