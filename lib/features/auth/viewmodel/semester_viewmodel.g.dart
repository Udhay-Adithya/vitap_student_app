// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SemesterViewModel)
final semesterViewModelProvider = SemesterViewModelProvider._();

final class SemesterViewModelProvider
    extends
        $NotifierProvider<SemesterViewModel, AsyncValue<List<SemesterInfo>>?> {
  SemesterViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'semesterViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$semesterViewModelHash();

  @$internal
  @override
  SemesterViewModel create() => SemesterViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<SemesterInfo>>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<SemesterInfo>>?>(
        value,
      ),
    );
  }
}

String _$semesterViewModelHash() => r'eca251dbe11b09b1a82f24f8d31bedb3583db9d0';

abstract class _$SemesterViewModel
    extends $Notifier<AsyncValue<List<SemesterInfo>>?> {
  AsyncValue<List<SemesterInfo>>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<SemesterInfo>>?,
              AsyncValue<List<SemesterInfo>>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<SemesterInfo>>?,
                AsyncValue<List<SemesterInfo>>?
              >,
              AsyncValue<List<SemesterInfo>>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
