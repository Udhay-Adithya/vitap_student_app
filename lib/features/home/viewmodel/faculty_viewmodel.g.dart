// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faculty_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the full list of faculty members loaded from VTOP.
/// State is `null` when not yet fetched, `AsyncLoading` during fetch,
/// `AsyncData` on success, and `AsyncError` on failure.

@ProviderFor(FacultyListViewModel)
final facultyListViewModelProvider = FacultyListViewModelProvider._();

/// Holds the full list of faculty members loaded from VTOP.
/// State is `null` when not yet fetched, `AsyncLoading` during fetch,
/// `AsyncData` on success, and `AsyncError` on failure.
final class FacultyListViewModelProvider
    extends
        $NotifierProvider<
          FacultyListViewModel,
          AsyncValue<List<FacultyListItem>>?
        > {
  /// Holds the full list of faculty members loaded from VTOP.
  /// State is `null` when not yet fetched, `AsyncLoading` during fetch,
  /// `AsyncData` on success, and `AsyncError` on failure.
  FacultyListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facultyListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facultyListViewModelHash();

  @$internal
  @override
  FacultyListViewModel create() => FacultyListViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<FacultyListItem>>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<FacultyListItem>>?>(
        value,
      ),
    );
  }
}

String _$facultyListViewModelHash() =>
    r'b5598e6120b72a92117ba5c029c771044e91b2a8';

/// Holds the full list of faculty members loaded from VTOP.
/// State is `null` when not yet fetched, `AsyncLoading` during fetch,
/// `AsyncData` on success, and `AsyncError` on failure.

abstract class _$FacultyListViewModel
    extends $Notifier<AsyncValue<List<FacultyListItem>>?> {
  AsyncValue<List<FacultyListItem>>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<FacultyListItem>>?,
              AsyncValue<List<FacultyListItem>>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<FacultyListItem>>?,
                AsyncValue<List<FacultyListItem>>?
              >,
              AsyncValue<List<FacultyListItem>>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Holds the details of a single faculty member fetched on demand.
/// State starts as `null` (idle). Call [fetchDetails] when the user taps
/// a faculty list item.

@ProviderFor(FacultyDetailsViewModel)
final facultyDetailsViewModelProvider = FacultyDetailsViewModelProvider._();

/// Holds the details of a single faculty member fetched on demand.
/// State starts as `null` (idle). Call [fetchDetails] when the user taps
/// a faculty list item.
final class FacultyDetailsViewModelProvider
    extends
        $NotifierProvider<
          FacultyDetailsViewModel,
          AsyncValue<FacultyDetails>?
        > {
  /// Holds the details of a single faculty member fetched on demand.
  /// State starts as `null` (idle). Call [fetchDetails] when the user taps
  /// a faculty list item.
  FacultyDetailsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facultyDetailsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facultyDetailsViewModelHash();

  @$internal
  @override
  FacultyDetailsViewModel create() => FacultyDetailsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<FacultyDetails>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<FacultyDetails>?>(value),
    );
  }
}

String _$facultyDetailsViewModelHash() =>
    r'668bafe7ad68f47026024624ca1ac63330f3fb1d';

/// Holds the details of a single faculty member fetched on demand.
/// State starts as `null` (idle). Call [fetchDetails] when the user taps
/// a faculty list item.

abstract class _$FacultyDetailsViewModel
    extends $Notifier<AsyncValue<FacultyDetails>?> {
  AsyncValue<FacultyDetails>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<FacultyDetails>?, AsyncValue<FacultyDetails>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<FacultyDetails>?,
                AsyncValue<FacultyDetails>?
              >,
              AsyncValue<FacultyDetails>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
