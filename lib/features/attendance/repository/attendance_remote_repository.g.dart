// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_remote_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(attendanceRemoteRepository)
final attendanceRemoteRepositoryProvider =
    AttendanceRemoteRepositoryProvider._();

final class AttendanceRemoteRepositoryProvider
    extends
        $FunctionalProvider<
          AttendanceRemoteRepository,
          AttendanceRemoteRepository,
          AttendanceRemoteRepository
        >
    with $Provider<AttendanceRemoteRepository> {
  AttendanceRemoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceRemoteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceRemoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<AttendanceRemoteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AttendanceRemoteRepository create(Ref ref) {
    return attendanceRemoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceRemoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceRemoteRepository>(value),
    );
  }
}

String _$attendanceRemoteRepositoryHash() =>
    r'f90a6c62c49d5218b49dfd971b0b67daeeaf492d';
