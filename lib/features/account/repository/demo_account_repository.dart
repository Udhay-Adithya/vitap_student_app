import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/account/repository/account_remote_repository.dart';

/// Syncing the demo account reloads the bundled demo user.
class DemoAccountRepository implements AccountRemoteRepository {
  DemoAccountRepository(this._demo);

  final DemoService _demo;

  @override
  Future<Either<Failure, User>> syncUser({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) => serveDemo(_demo.loadDemoUser);

  @override
  Future<Either<Failure, User>> syncUserLegacy({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) => serveDemo(_demo.loadDemoUser);
}
