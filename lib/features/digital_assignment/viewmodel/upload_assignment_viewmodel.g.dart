// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_assignment_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UploadAssignmentViewModel)
final uploadAssignmentViewModelProvider = UploadAssignmentViewModelProvider._();

final class UploadAssignmentViewModelProvider
    extends $NotifierProvider<UploadAssignmentViewModel, AsyncValue<String>?> {
  UploadAssignmentViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uploadAssignmentViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uploadAssignmentViewModelHash();

  @$internal
  @override
  UploadAssignmentViewModel create() => UploadAssignmentViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String>?>(value),
    );
  }
}

String _$uploadAssignmentViewModelHash() =>
    r'10827eb13e001f38b7fa6269a9a1c5d2c3ff91e9';

abstract class _$UploadAssignmentViewModel
    extends $Notifier<AsyncValue<String>?> {
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
