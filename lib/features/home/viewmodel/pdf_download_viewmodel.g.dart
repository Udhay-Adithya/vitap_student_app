// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_download_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GeneralOutingPdfDownloadViewModel)
final generalOutingPdfDownloadViewModelProvider =
    GeneralOutingPdfDownloadViewModelProvider._();

final class GeneralOutingPdfDownloadViewModelProvider
    extends
        $NotifierProvider<
          GeneralOutingPdfDownloadViewModel,
          AsyncValue<String>?
        > {
  GeneralOutingPdfDownloadViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generalOutingPdfDownloadViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$generalOutingPdfDownloadViewModelHash();

  @$internal
  @override
  GeneralOutingPdfDownloadViewModel create() =>
      GeneralOutingPdfDownloadViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String>?>(value),
    );
  }
}

String _$generalOutingPdfDownloadViewModelHash() =>
    r'd3212520bf43ae73a85bee2b13dec49096cd9e7b';

abstract class _$GeneralOutingPdfDownloadViewModel
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

@ProviderFor(WeekendOutingPdfDownloadViewModel)
final weekendOutingPdfDownloadViewModelProvider =
    WeekendOutingPdfDownloadViewModelProvider._();

final class WeekendOutingPdfDownloadViewModelProvider
    extends
        $NotifierProvider<
          WeekendOutingPdfDownloadViewModel,
          AsyncValue<String>?
        > {
  WeekendOutingPdfDownloadViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weekendOutingPdfDownloadViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$weekendOutingPdfDownloadViewModelHash();

  @$internal
  @override
  WeekendOutingPdfDownloadViewModel create() =>
      WeekendOutingPdfDownloadViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String>?>(value),
    );
  }
}

String _$weekendOutingPdfDownloadViewModelHash() =>
    r'6a806be63bc0f3e631b20cacab1caa424bff1f0a';

abstract class _$WeekendOutingPdfDownloadViewModel
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
