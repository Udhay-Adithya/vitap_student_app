import 'package:fpdart/fpdart.dart';
import 'package:objectbox/objectbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/timetable/repository/timetable_remote_repository.dart';

part 'timetable_viewmodel.g.dart';

@riverpod
class TimetableViewModel extends _$TimetableViewModel {
  late TimetableRemoteRepository _timetableRemoteRepository;

  @override
  AsyncValue<Timetable>? build() {
    _timetableRemoteRepository = ref.watch(timetableRemoteRepositoryProvider);

    return null;
  }

  Future<void> refreshTimetable() async {
    // Demo mode: serve the timetable seeded into the user at login.
    if (DemoService.isDemoMode) {
      final demoTimetable = ref.read(currentUserProvider)?.timetable.target;
      if (demoTimetable != null) {
        state = AsyncValue.data(demoTimetable);
      }
      return;
    }

    state = const AsyncValue.loading();
    final User? user = ref.read(currentUserProvider);
    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error(
          'User not found. Please Logout and Login.', StackTrace.current);
      return;
    }
    final res = await _timetableRemoteRepository.fetchTimetable(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final newTimetable)) {
      state = AsyncValue.data(newTimetable);
      if (user != null) {
        await userNotifier.updateUser(
            user.copyWith(timetable: ToOne<Timetable>(target: newTimetable)));
      }
    }
  }
}
