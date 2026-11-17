// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_page_remote_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(coursePageRemoteRepository)
final coursePageRemoteRepositoryProvider =
    CoursePageRemoteRepositoryProvider._();

final class CoursePageRemoteRepositoryProvider
    extends
        $FunctionalProvider<
          CoursePageRemoteRepository,
          CoursePageRemoteRepository,
          CoursePageRemoteRepository
        >
    with $Provider<CoursePageRemoteRepository> {
  CoursePageRemoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coursePageRemoteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coursePageRemoteRepositoryHash();

  @$internal
  @override
  $ProviderElement<CoursePageRemoteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CoursePageRemoteRepository create(Ref ref) {
    return coursePageRemoteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoursePageRemoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoursePageRemoteRepository>(value),
    );
  }
}

String _$coursePageRemoteRepositoryHash() =>
    r'67d0b38e08da95e3dce48179683fe784d70b169b';
