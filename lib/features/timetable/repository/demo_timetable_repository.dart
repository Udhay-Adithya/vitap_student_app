import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/timetable/repository/timetable_remote_repository.dart';

/// The demo account's timetable, from the bundled demo user.
class DemoTimetableRepository implements TimetableRemoteRepository {
  DemoTimetableRepository(this._demo);

  final DemoService _demo;

  @override
  Future<Either<Failure, Timetable>> fetchTimetable({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) async {
    final user = await _demo.loadDemoUser();
    final timetable = user.timetable.target;
    if (timetable == null) return Left(Failure('No demo timetable.'));
    return Right(timetable);
  }
}
