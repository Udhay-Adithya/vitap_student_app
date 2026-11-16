import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/features/course_page/repository/course_page_remote_repository.dart';

part 'material_download_viewmodel.g.dart';

@riverpod
class MaterialDownloadViewmodel extends _$MaterialDownloadViewmodel {
  late CoursePageRemoteRepository _repository;

  @override
  AsyncValue<Uint8List>? build() {
    _repository = ref.watch(coursePageRemoteRepositoryProvider);
    return null;
  }

  Future<Uint8List?> downloadMaterial({required String downloadPath}) async {
    state = const AsyncValue.loading();
    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
        'User not found. Please Logout and Login.',
        StackTrace.current,
      );
      return null;
    }

    final res = await _repository.downloadCourseMaterial(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
      downloadPath: downloadPath,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
      return null;
    } else if (res case Right(value: final bytes)) {
      state = AsyncValue.data(bytes);
      return bytes;
    }
    return null;
  }

  Future<Uint8List?> downloadAllMaterials({
    required String downloadPath,
  }) async {
    state = const AsyncValue.loading();
    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
        'User not found. Please Logout and Login.',
        StackTrace.current,
      );
      return null;
    }

    final res = await _repository.downloadAllCourseMaterials(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
      downloadPath: downloadPath,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
      return null;
    } else if (res case Right(value: final bytes)) {
      state = AsyncValue.data(bytes);
      return bytes;
    }
    return null;
  }

  Future<Uint8List?> downloadSyllabus({
    required String courseId,
    required String courseType,
  }) async {
    state = const AsyncValue.loading();
    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
        'User not found. Please Logout and Login.',
        StackTrace.current,
      );
      return null;
    }

    final res = await _repository.downloadCourseSyllabus(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
      courseId: courseId,
      courseType: courseType,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
      return null;
    } else if (res case Right(value: final bytes)) {
      state = AsyncValue.data(bytes);
      return bytes;
    }
    return null;
  }

  void reset() {
    state = null;
  }
}
