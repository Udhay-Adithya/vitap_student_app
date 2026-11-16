import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/models/exam_schedule.dart';
import 'package:vit_ap_student_app/core/models/mark.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/features/home/model/biometric.dart';
import 'package:vit_ap_student_app/features/home/model/payment_receipt.dart';
import 'package:vit_ap_student_app/features/home/model/pending_payment.dart';
import 'package:vit_ap_student_app/features/home/model/weather.dart';
import 'package:vit_ap_student_app/features/home/repository/home_remote_repository.dart';

/// Home data for the demo account. Weather never involved VTOP, so it is
/// passed through to the real repository.
class DemoHomeRepository implements HomeRemoteRepository {
  DemoHomeRepository(this._demo, this._live);

  final DemoService _demo;
  final HomeRemoteRepository _live;

  @override
  Future<Either<Failure, Weather>> fetchWeather() => _live.fetchWeather();

  @override
  Future<Either<Failure, List<Biometric>>> fetchBiometric({
    required String registrationNumber,
    required String password,
    required String date,
  }) => serveDemo(_demo.biometric);

  @override
  Future<Either<Failure, List<Mark>>> fetchMarks({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) => serveDemo(() async => (await _demo.loadDemoUser()).marks.toList());

  @override
  Future<Either<Failure, List<ExamSchedule>>> fetchExamSchedule({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) =>
      serveDemo(() async => (await _demo.loadDemoUser()).examSchedule.toList());

  @override
  Future<Either<Failure, List<PendingPayment>>> fetchPendingPayments({
    required String registrationNumber,
    required String password,
  }) => serveDemo(_demo.pendingPayments);

  @override
  Future<Either<Failure, List<PaymentReceipt>>> fetchPaymentReceipts({
    required String registrationNumber,
    required String password,
  }) => serveDemo(_demo.paymentReceipts);
}
