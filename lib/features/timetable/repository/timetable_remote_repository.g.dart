// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_remote_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(timetableRemoteRepository)
final timetableRemoteRepositoryProvider = TimetableRemoteRepositoryProvider._();

final class TimetableRemoteRepositoryProvider
    extends
        $FunctionalProvider<
          TimetableRemoteRepository,
          TimetableRemoteRepository,
          TimetableRemoteRepository
        >
    with $Provider<TimetableRemoteRepository> {
  TimetableRemoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timetableRemoteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timetableRemoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<TimetableRemoteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TimetableRemoteRepository create(Ref ref) {
    return timetableRemoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimetableRemoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimetableRemoteRepository>(value),
    );
  }
}

String _$timetableRemoteRepositoryHash() =>
    r'2ec8312ac5508865b47ec8d5d2f0e29cd878a0fa';
