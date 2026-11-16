// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vtop_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's one VTOP session. [VtopClientService.instance] is already a
/// process-wide singleton; this is how the rest of the app reaches it.

@ProviderFor(vtopClientService)
final vtopClientServiceProvider = VtopClientServiceProvider._();

/// The app's one VTOP session. [VtopClientService.instance] is already a
/// process-wide singleton; this is how the rest of the app reaches it.

final class VtopClientServiceProvider
    extends
        $FunctionalProvider<
          VtopClientService,
          VtopClientService,
          VtopClientService
        >
    with $Provider<VtopClientService> {
  /// The app's one VTOP session. [VtopClientService.instance] is already a
  /// process-wide singleton; this is how the rest of the app reaches it.
  VtopClientServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vtopClientServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vtopClientServiceHash();

  @$internal
  @override
  $ProviderElement<VtopClientService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VtopClientService create(Ref ref) {
    return vtopClientService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VtopClientService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VtopClientService>(value),
    );
  }
}

String _$vtopClientServiceHash() => r'7a3aba7a66f82fd38775a776e3832d4f3589d9aa';
