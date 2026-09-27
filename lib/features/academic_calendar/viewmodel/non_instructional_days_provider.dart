import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/features/academic_calendar/model/non_instructional_days.dart';
import 'package:vit_ap_student_app/features/academic_calendar/repository/academic_calendar_repository.dart';

part 'non_instructional_days_provider.g.dart';

/// The days this semester has no classes on, read from the stored calendar.
///
/// Reads only what has already been fetched — a refresh is a request per month,
/// so it stays the student's decision on the calendar page. Until they have
/// done that once, this is [NonInstructionalDays.empty] and nothing is
/// suppressed, which is the same behaviour the app had before.
@riverpod
Future<NonInstructionalDays> nonInstructionalDays(Ref ref) async {
  final credentials = await ref
      .read(currentUserProvider.notifier)
      .getSavedCredentials();
  if (credentials == null) return NonInstructionalDays.empty;

  final repository = ref.watch(academicCalendarRepositoryProvider);
  return NonInstructionalDays.fromCalendar(
    repository.cached(semSubId: credentials.semSubId),
  );
}
