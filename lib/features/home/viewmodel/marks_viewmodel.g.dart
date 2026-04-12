// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marks_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MarksViewModel)
final marksViewModelProvider = MarksViewModelProvider._();

final class MarksViewModelProvider
    extends $NotifierProvider<MarksViewModel, AsyncValue<List<Mark>>?> {
  MarksViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marksViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marksViewModelHash();

  @$internal
  @override
  MarksViewModel create() => MarksViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Mark>>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Mark>>?>(value),
    );
  }
}

String _$marksViewModelHash() => r'c4b71d7a719359564be07819d9b9b8ff30222cbe';

abstract class _$MarksViewModel extends $Notifier<AsyncValue<List<Mark>>?> {
  AsyncValue<List<Mark>>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Mark>>?, AsyncValue<List<Mark>>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Mark>>?, AsyncValue<List<Mark>>?>,
              AsyncValue<List<Mark>>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
