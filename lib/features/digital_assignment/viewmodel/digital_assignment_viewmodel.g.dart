// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'digital_assignment_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DigitalAssignmentViewModel)
final digitalAssignmentViewModelProvider =
    DigitalAssignmentViewModelProvider._();

final class DigitalAssignmentViewModelProvider
    extends
        $NotifierProvider<
          DigitalAssignmentViewModel,
          AsyncValue<List<DigitalAssignment>>?
        > {
  DigitalAssignmentViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'digitalAssignmentViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$digitalAssignmentViewModelHash();

  @$internal
  @override
  DigitalAssignmentViewModel create() => DigitalAssignmentViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<DigitalAssignment>>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<DigitalAssignment>>?>(value),
    );
  }
}

String _$digitalAssignmentViewModelHash() =>
    r'e96b82104ee8fb3f3bde48bb885c63c63f01d32d';

abstract class _$DigitalAssignmentViewModel
    extends $Notifier<AsyncValue<List<DigitalAssignment>>?> {
  AsyncValue<List<DigitalAssignment>>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<DigitalAssignment>>?,
              AsyncValue<List<DigitalAssignment>>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<DigitalAssignment>>?,
                AsyncValue<List<DigitalAssignment>>?
              >,
              AsyncValue<List<DigitalAssignment>>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
