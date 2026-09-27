// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'non_instructional_days_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The days this semester has no classes on, read from the stored calendar.
///
/// Reads only what has already been fetched — a refresh is a request per month,
/// so it stays the student's decision on the calendar page. Until they have
/// done that once, this is [NonInstructionalDays.empty] and nothing is
/// suppressed, which is the same behaviour the app had before.

@ProviderFor(nonInstructionalDays)
final nonInstructionalDaysProvider = NonInstructionalDaysProvider._();

/// The days this semester has no classes on, read from the stored calendar.
///
/// Reads only what has already been fetched — a refresh is a request per month,
/// so it stays the student's decision on the calendar page. Until they have
/// done that once, this is [NonInstructionalDays.empty] and nothing is
/// suppressed, which is the same behaviour the app had before.

final class NonInstructionalDaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<NonInstructionalDays>,
          NonInstructionalDays,
          FutureOr<NonInstructionalDays>
        >
    with
        $FutureModifier<NonInstructionalDays>,
        $FutureProvider<NonInstructionalDays> {
  /// The days this semester has no classes on, read from the stored calendar.
  ///
  /// Reads only what has already been fetched — a refresh is a request per month,
  /// so it stays the student's decision on the calendar page. Until they have
  /// done that once, this is [NonInstructionalDays.empty] and nothing is
  /// suppressed, which is the same behaviour the app had before.
  NonInstructionalDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nonInstructionalDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nonInstructionalDaysHash();

  @$internal
  @override
  $FutureProviderElement<NonInstructionalDays> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NonInstructionalDays> create(Ref ref) {
    return nonInstructionalDays(ref);
  }
}

String _$nonInstructionalDaysHash() =>
    r'7c868e549d9cbb127e8396cf8ad6834f1e6275f1';
