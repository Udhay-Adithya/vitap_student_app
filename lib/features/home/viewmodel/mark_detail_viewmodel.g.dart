// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mark_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the class-statistics section of the mark detail page.
///
/// The letter grade and grand total already live on the [Mark] (merged in when
/// marks are refreshed). The class statistics (mean, SD, grade cutoffs) are
/// heavier — one request per course — so they are fetched lazily the first time
/// a course's detail page is opened, then cached onto the Mark so reopening the
/// page never refetches.

@ProviderFor(MarkDetailViewModel)
final markDetailViewModelProvider = MarkDetailViewModelProvider._();

/// Drives the class-statistics section of the mark detail page.
///
/// The letter grade and grand total already live on the [Mark] (merged in when
/// marks are refreshed). The class statistics (mean, SD, grade cutoffs) are
/// heavier — one request per course — so they are fetched lazily the first time
/// a course's detail page is opened, then cached onto the Mark so reopening the
/// page never refetches.
final class MarkDetailViewModelProvider
    extends
        $NotifierProvider<
          MarkDetailViewModel,
          AsyncValue<GradeStatisticsModel?>?
        > {
  /// Drives the class-statistics section of the mark detail page.
  ///
  /// The letter grade and grand total already live on the [Mark] (merged in when
  /// marks are refreshed). The class statistics (mean, SD, grade cutoffs) are
  /// heavier — one request per course — so they are fetched lazily the first time
  /// a course's detail page is opened, then cached onto the Mark so reopening the
  /// page never refetches.
  MarkDetailViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'markDetailViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$markDetailViewModelHash();

  @$internal
  @override
  MarkDetailViewModel create() => MarkDetailViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<GradeStatisticsModel?>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<GradeStatisticsModel?>?>(
        value,
      ),
    );
  }
}

String _$markDetailViewModelHash() =>
    r'31cbd056b164300ed34881e3cbafdd17dac86c64';

/// Drives the class-statistics section of the mark detail page.
///
/// The letter grade and grand total already live on the [Mark] (merged in when
/// marks are refreshed). The class statistics (mean, SD, grade cutoffs) are
/// heavier — one request per course — so they are fetched lazily the first time
/// a course's detail page is opened, then cached onto the Mark so reopening the
/// page never refetches.

abstract class _$MarkDetailViewModel
    extends $Notifier<AsyncValue<GradeStatisticsModel?>?> {
  AsyncValue<GradeStatisticsModel?>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<GradeStatisticsModel?>?,
              AsyncValue<GradeStatisticsModel?>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<GradeStatisticsModel?>?,
                AsyncValue<GradeStatisticsModel?>?
              >,
              AsyncValue<GradeStatisticsModel?>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
