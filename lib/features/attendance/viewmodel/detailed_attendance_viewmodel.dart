import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/attendance/model/attendance_detail.dart';
import 'package:vit_ap_student_app/features/attendance/repository/attendance_remote_repository.dart';

part 'detailed_attendance_viewmodel.g.dart';

@riverpod
class DetailedAttendanceViewmodel extends _$DetailedAttendanceViewmodel {
  late AttendanceRemoteRepository _attendanceRemoteRepository;

  @override
  AsyncValue<List<AttendanceDetail>>? build() {
    _attendanceRemoteRepository = ref.watch(attendanceRemoteRepositoryProvider);
    return null;
  }

  Future<void> fetchDetailedAttendance({
    required String courseId,
    required String courseType,
  }) async {
    state = const AsyncValue.loading();

    // Demo mode: serve bundled sample detailed attendance.
    if (DemoService.isDemoMode) {
      state = AsyncValue.data(
        await DemoService.instance.detailedAttendance(),
      );
      return;
    }

    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();

    if (credentials == null) {
      state = AsyncValue.error(
          'User not found. Please Logout and Login.', StackTrace.current);
      return;
    }

    final res = await _attendanceRemoteRepository.fetchDetailedAttendance(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
      courseId: courseId,
      courseType: courseType,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final detailedAttendance)) {
      state = AsyncValue.data(detailedAttendance);
    }
  }
}
