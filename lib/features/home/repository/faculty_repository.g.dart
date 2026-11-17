// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faculty_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(facultyRepository)
final facultyRepositoryProvider = FacultyRepositoryProvider._();

final class FacultyRepositoryProvider
    extends
        $FunctionalProvider<
          FacultyRepository,
          FacultyRepository,
          FacultyRepository
        >
    with $Provider<FacultyRepository> {
  FacultyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facultyRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facultyRepositoryHash();

  @$internal
  @override
  $ProviderElement<FacultyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FacultyRepository create(Ref ref) {
    return facultyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FacultyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FacultyRepository>(value),
    );
  }
}

String _$facultyRepositoryHash() => r'b0fab76e8b088607a8893dde70aad5e761df8c01';
