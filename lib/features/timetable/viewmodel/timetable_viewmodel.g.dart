// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimetableViewModel)
final timetableViewModelProvider = TimetableViewModelProvider._();

final class TimetableViewModelProvider
    extends $NotifierProvider<TimetableViewModel, AsyncValue<Timetable>?> {
  TimetableViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timetableViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timetableViewModelHash();

  @$internal
  @override
  TimetableViewModel create() => TimetableViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Timetable>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Timetable>?>(value),
    );
  }
}

String _$timetableViewModelHash() =>
    r'2bbd6dca378696a1b2896b295a8a30de5136f5ce';

abstract class _$TimetableViewModel extends $Notifier<AsyncValue<Timetable>?> {
  AsyncValue<Timetable>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Timetable>?, AsyncValue<Timetable>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Timetable>?, AsyncValue<Timetable>?>,
              AsyncValue<Timetable>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
