// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_calendar_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AcademicCalendarViewModel)
final academicCalendarViewModelProvider = AcademicCalendarViewModelProvider._();

final class AcademicCalendarViewModelProvider
    extends
        $NotifierProvider<
          AcademicCalendarViewModel,
          AsyncValue<AcademicCalendar?>
        > {
  AcademicCalendarViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'academicCalendarViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$academicCalendarViewModelHash();

  @$internal
  @override
  AcademicCalendarViewModel create() => AcademicCalendarViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AcademicCalendar?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<AcademicCalendar?>>(
        value,
      ),
    );
  }
}

String _$academicCalendarViewModelHash() =>
    r'ac552e8210d025d8b14a3f9b726812a9f2f0a5fc';

abstract class _$AcademicCalendarViewModel
    extends $Notifier<AsyncValue<AcademicCalendar?>> {
  AsyncValue<AcademicCalendar?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AcademicCalendar?>,
              AsyncValue<AcademicCalendar?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AcademicCalendar?>,
                AsyncValue<AcademicCalendar?>
              >,
              AsyncValue<AcademicCalendar?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
