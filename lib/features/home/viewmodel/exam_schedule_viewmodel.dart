import 'package:fpdart/fpdart.dart';
import 'package:objectbox/objectbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/exam_schedule.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/home/repository/home_remote_repository.dart';

part 'exam_schedule_viewmodel.g.dart';

@riverpod
class ExamScheduleViewModel extends _$ExamScheduleViewModel {
  late HomeRemoteRepository _homeRemoteRepository;

  @override
  AsyncValue<List<ExamSchedule>>? build() {
    _homeRemoteRepository = ref.watch(homeRemoteRepositoryProvider);

    return null;
  }

  Future<void> refreshExamSchedule() async {
    // Demo mode: serve the exam schedule seeded into the user at login.
    if (DemoService.isDemoMode) {
      final demoUser = ref.read(currentUserProvider);
      state = AsyncValue.data(demoUser?.examSchedule.toList() ?? []);
      return;
    }

    state = const AsyncValue.loading();
    final User? user = ref.read(currentUserProvider);
    final userNotifier = ref.read(currentUserProvider.notifier);
    final Credentials? credentials = await userNotifier.getSavedCredentials();
    if (credentials == null) {
      AsyncValue<List<ExamSchedule>>.error(
        'User not found. Please Logout and Login.',
        StackTrace.current,
      );
    }
    final res = await _homeRemoteRepository.fetchExamSchedule(
      registrationNumber: credentials!.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final newExamSchedule)) {
      state = AsyncValue.data(newExamSchedule);
      if (user != null) {
        await userNotifier.updateUser(
          user.copyWith(
            examSchedule: ToMany<ExamSchedule>(items: newExamSchedule),
          ),
        );
      }
    }
  }
}
