// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_download_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MaterialDownloadViewmodel)
final materialDownloadViewmodelProvider = MaterialDownloadViewmodelProvider._();

final class MaterialDownloadViewmodelProvider
    extends
        $NotifierProvider<MaterialDownloadViewmodel, AsyncValue<Uint8List>?> {
  MaterialDownloadViewmodelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'materialDownloadViewmodelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$materialDownloadViewmodelHash();

  @$internal
  @override
  MaterialDownloadViewmodel create() => MaterialDownloadViewmodel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Uint8List>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Uint8List>?>(value),
    );
  }
}

String _$materialDownloadViewmodelHash() =>
    r'5408e325e23f32f36b02a4ec36be6d439b035f2b';

abstract class _$MaterialDownloadViewmodel
    extends $Notifier<AsyncValue<Uint8List>?> {
  AsyncValue<Uint8List>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Uint8List>?, AsyncValue<Uint8List>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Uint8List>?, AsyncValue<Uint8List>?>,
              AsyncValue<Uint8List>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
