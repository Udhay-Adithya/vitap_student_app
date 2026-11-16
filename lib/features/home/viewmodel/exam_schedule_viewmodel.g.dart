// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_schedule_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExamScheduleViewModel)
final examScheduleViewModelProvider = ExamScheduleViewModelProvider._();

final class ExamScheduleViewModelProvider
    extends
        $NotifierProvider<
          ExamScheduleViewModel,
          AsyncValue<List<ExamSchedule>>?
        > {
  ExamScheduleViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'examScheduleViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$examScheduleViewModelHash();

  @$internal
  @override
  ExamScheduleViewModel create() => ExamScheduleViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<ExamSchedule>>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<ExamSchedule>>?>(
        value,
      ),
    );
  }
}

String _$examScheduleViewModelHash() =>
    r'4dd81588a5e248c2a40e6a83280a1cff5cedbdf2';

abstract class _$ExamScheduleViewModel
    extends $Notifier<AsyncValue<List<ExamSchedule>>?> {
  AsyncValue<List<ExamSchedule>>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ExamSchedule>>?,
              AsyncValue<List<ExamSchedule>>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ExamSchedule>>?,
                AsyncValue<List<ExamSchedule>>?
              >,
              AsyncValue<List<ExamSchedule>>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
