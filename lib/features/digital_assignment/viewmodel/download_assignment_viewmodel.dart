import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/digital_assignment_remote_repository.dart';

part 'download_assignment_viewmodel.g.dart';

@riverpod
class DownloadAssignmentViewModel extends _$DownloadAssignmentViewModel {
  late DigitalAssignmentRemoteRepository _repository;

  @override
  AsyncValue<Uint8List>? build() {
    _repository = ref.watch(digitalAssignmentRemoteRepositoryProvider);
    return null;
  }

  Future<Uint8List?> downloadFile({required String downloadPath}) async {
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

    final res = await _repository.downloadAssignmentFile(
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
}
