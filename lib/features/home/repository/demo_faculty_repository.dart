import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/home/model/faculty.dart';
import 'package:vit_ap_student_app/features/home/repository/faculty_repository.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/types/faculty.dart';

/// Faculty for the demo account. The list is a bundled asset either way, so it
/// is passed through; the details page comes from the demo dataset.
class DemoFacultyRepository implements FacultyRepository {
  DemoFacultyRepository(this._demo, this._live);

  final DemoService _demo;
  final FacultyRepository _live;

  @override
  Future<Either<Failure, List<FacultyListItem>>> fetchFacultyList() =>
      _live.fetchFacultyList();

  @override
  Future<Either<Failure, FacultyDetails>> fetchFacultyDetails({
    required String registrationNumber,
    required String password,
    required String empId,
  }) => serveDemo(_demo.facultyDetails);
}
