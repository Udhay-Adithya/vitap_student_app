// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_view_remote_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gradeViewRemoteRepository)
final gradeViewRemoteRepositoryProvider = GradeViewRemoteRepositoryProvider._();

final class GradeViewRemoteRepositoryProvider
    extends
        $FunctionalProvider<
          GradeViewRemoteRepository,
          GradeViewRemoteRepository,
          GradeViewRemoteRepository
        >
    with $Provider<GradeViewRemoteRepository> {
  GradeViewRemoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gradeViewRemoteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gradeViewRemoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<GradeViewRemoteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GradeViewRemoteRepository create(Ref ref) {
    return gradeViewRemoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GradeViewRemoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GradeViewRemoteRepository>(value),
    );
  }
}

String _$gradeViewRemoteRepositoryHash() =>
    r'7befbb29d61c9874abe080054485d06b3309c903';
