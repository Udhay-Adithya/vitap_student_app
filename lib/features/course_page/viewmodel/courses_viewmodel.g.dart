// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courses_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CoursesViewmodel)
final coursesViewmodelProvider = CoursesViewmodelProvider._();

final class CoursesViewmodelProvider
    extends
        $NotifierProvider<CoursesViewmodel, AsyncValue<CoursesResponseModel>?> {
  CoursesViewmodelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coursesViewmodelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coursesViewmodelHash();

  @$internal
  @override
  CoursesViewmodel create() => CoursesViewmodel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CoursesResponseModel>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CoursesResponseModel>?>(
        value,
      ),
    );
  }
}

String _$coursesViewmodelHash() => r'e350cd72de54fb1e114f43138c8d3acebab6c104';

abstract class _$CoursesViewmodel
    extends $Notifier<AsyncValue<CoursesResponseModel>?> {
  AsyncValue<CoursesResponseModel>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CoursesResponseModel>?,
              AsyncValue<CoursesResponseModel>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CoursesResponseModel>?,
                AsyncValue<CoursesResponseModel>?
              >,
              AsyncValue<CoursesResponseModel>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
