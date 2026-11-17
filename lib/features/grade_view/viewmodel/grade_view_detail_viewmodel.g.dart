// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_view_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GradeViewDetailViewmodel)
final gradeViewDetailViewmodelProvider = GradeViewDetailViewmodelProvider._();

final class GradeViewDetailViewmodelProvider
    extends
        $NotifierProvider<
          GradeViewDetailViewmodel,
          AsyncValue<GradeViewDetailModel>?
        > {
  GradeViewDetailViewmodelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gradeViewDetailViewmodelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gradeViewDetailViewmodelHash();

  @$internal
  @override
  GradeViewDetailViewmodel create() => GradeViewDetailViewmodel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<GradeViewDetailModel>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<GradeViewDetailModel>?>(
        value,
      ),
    );
  }
}

String _$gradeViewDetailViewmodelHash() =>
    r'e63548dbaf4c6621a1e42f711a4b93177ef6ff6b';

abstract class _$GradeViewDetailViewmodel
    extends $Notifier<AsyncValue<GradeViewDetailModel>?> {
  AsyncValue<GradeViewDetailModel>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<GradeViewDetailModel>?,
              AsyncValue<GradeViewDetailModel>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<GradeViewDetailModel>?,
                AsyncValue<GradeViewDetailModel>?
              >,
              AsyncValue<GradeViewDetailModel>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
