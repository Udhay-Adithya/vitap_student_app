// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'digital_assignment_remote_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(digitalAssignmentRemoteRepository)
final digitalAssignmentRemoteRepositoryProvider =
    DigitalAssignmentRemoteRepositoryProvider._();

final class DigitalAssignmentRemoteRepositoryProvider
    extends
        $FunctionalProvider<
          DigitalAssignmentRemoteRepository,
          DigitalAssignmentRemoteRepository,
          DigitalAssignmentRemoteRepository
        >
    with $Provider<DigitalAssignmentRemoteRepository> {
  DigitalAssignmentRemoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'digitalAssignmentRemoteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$digitalAssignmentRemoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<DigitalAssignmentRemoteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DigitalAssignmentRemoteRepository create(Ref ref) {
    return digitalAssignmentRemoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DigitalAssignmentRemoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DigitalAssignmentRemoteRepository>(
        value,
      ),
    );
  }
}

String _$digitalAssignmentRemoteRepositoryHash() =>
    r'eac6a638f2f66b97f00c28190a7c338cb6041e44';
