import 'package:fpdart/fpdart.dart';
import 'package:objectbox/objectbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/attendance.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/attendance/repository/attendance_remote_repository.dart';

part 'attendance_viewmodel.g.dart';

@riverpod
class AttendanceViewMode extends _$AttendanceViewMode {
  late AttendanceRemoteRepository _attendanceRemoteRepository;

  @override
  AsyncValue<List<Attendance>>? build() {
    _attendanceRemoteRepository = ref.watch(attendanceRemoteRepositoryProvider);

    return null;
  }

  Future<void> refreshAttendance({bool silentRefresh = false}) async {
    // Demo mode: serve the attendance seeded into the user at login; never
    // contact VTOP.
    if (DemoService.isDemoMode) {
      final demoUser = ref.read(currentUserProvider);
      state = AsyncValue.data(demoUser?.attendance.toList() ?? []);
      return;
    }

    if (!silentRefresh) {
      state = const AsyncValue.loading();
    }
    final User? user = ref.read(currentUserProvider);
    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error(
          'User not found. Please Logout and Login.', StackTrace.current);
      return;
    }
    final res = await _attendanceRemoteRepository.fetchAttendance(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final newAttendance)) {
      state = AsyncValue.data(newAttendance);
      if (user != null) {
        await userNotifier.updateUser(
          user.copyWith(
            attendance: ToMany<Attendance>(items: newAttendance),
          ),
        );
      }
    }
  }
}
