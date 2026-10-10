import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/digital_assignment_remote_repository.dart';
import 'package:vit_ap_student_app/features/digital_assignment/viewmodel/upload_assignment_viewmodel.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

/// An upload that finishes only when the test lets it, so the state partway
/// through can be inspected.
class _FakeAssignmentRepository extends DigitalAssignmentRemoteRepository {
  _FakeAssignmentRepository({this.failure}) : super(VtopClientService());

  final String? failure;
  int uploads = 0;
  final List<String> otpsSubmitted = [];
  Completer<Either<Failure, String>>? gate;

  @override
  Future<Either<Failure, String>> uploadDigitalAssignment({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String classId,
    required String mode,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    uploads++;
    if (gate != null) return gate!.future;
    if (failure != null) return Left(Failure(failure!));
    return const Right('Uploaded successfully');
  }

  @override
  Future<Either<Failure, String>> uploadDigitalAssignmentWithOtp({
    required String registrationNumber,
    required String password,
    required String semSubId,
    required String otpEmail,
  }) async {
    otpsSubmitted.add(otpEmail);
    if (failure != null) return Left(Failure(failure!));
    return const Right('Uploaded successfully');
  }
}

void main() {
  group(
    'UploadAssignmentViewModel',
    () {
      late _FakeAssignmentRepository repository;

      Future<ProviderContainer> harness({
        bool signedIn = true,
        String? failure,
      }) async {
        await registerTestDependencies(
          credentials: signedIn ? testCredentials() : null,
        );
        repository = _FakeAssignmentRepository(failure: failure);
        final container = ProviderContainer(
          overrides: [
            digitalAssignmentRemoteRepositoryProvider.overrideWithValue(
              repository,
            ),
          ],
        );
        addTearDown(container.dispose);
        // These view models are auto-disposed, so without a listener the
        // notifier is torn down between reads and its state reads back as
        // null. A page being on screen is exactly this subscription.
        container.listen(uploadAssignmentViewModelProvider, (_, _) {});
        return container;
      }

      Future<void> upload(ProviderContainer ref) => ref
          .read(uploadAssignmentViewModelProvider.notifier)
          .uploadAssignment(
            classId: 'AP2026272000101',
            mode: 'DA01',
            fileName: 'assignment.pdf',
            fileBytes: const [1, 2, 3],
          );

      test('uploads nothing until asked', () async {
        final ref = await harness();

        expect(ref.read(uploadAssignmentViewModelProvider), isNull);
        expect(repository.uploads, 0);
      });

      /// An upload is the slowest thing in the app and the one a student is most
      /// likely to tap twice. It has to report that it is running for as long as
      /// it runs, not just flicker at the end.
      test('stays in a loading state for as long as the upload runs', () async {
        final ref = await harness();
        repository.gate = Completer<Either<Failure, String>>();

        final pending = upload(ref);
        await Future<void>.delayed(Duration.zero);

        expect(ref.read(uploadAssignmentViewModelProvider)?.isLoading, isTrue);

        repository.gate!.complete(const Right('Uploaded successfully'));
        await pending;

        final state = ref.read(uploadAssignmentViewModelProvider);
        expect(state?.isLoading, isFalse);
        expect(state?.value, 'Uploaded successfully');
      });

      test(
        'reports a failed upload instead of staying on the spinner',
        () async {
          final ref = await harness(
            failure: 'File size should not exceed 4 MB.',
          );

          await upload(ref);

          final state = ref.read(uploadAssignmentViewModelProvider);
          expect(state?.isLoading, isFalse);
          expect(state?.hasError, isTrue);
          expect(state?.error, 'File size should not exceed 4 MB.');
        },
      );

      /// VTOP answers an upload with an OTP demand, which the flow reports as
      /// `OTP_REQUIRED` for the sheet to pick up.
      test('surfaces the OTP demand VTOP answers an upload with', () async {
        final ref = await harness(failure: 'OTP_REQUIRED');

        await upload(ref);

        expect(
          ref.read(uploadAssignmentViewModelProvider)?.error,
          'OTP_REQUIRED',
        );
      });

      test('passes the OTP through and settles', () async {
        final ref = await harness();

        await ref
            .read(uploadAssignmentViewModelProvider.notifier)
            .submitOtp(otpEmail: '123456');

        expect(repository.otpsSubmitted, ['123456']);
        final state = ref.read(uploadAssignmentViewModelProvider);
        expect(state?.isLoading, isFalse);
        expect(state?.value, 'Uploaded successfully');
      });

      test('does not upload when there are no saved credentials', () async {
        final ref = await harness(signedIn: false);

        await upload(ref);

        expect(repository.uploads, 0);
        expect(ref.read(uploadAssignmentViewModelProvider)?.hasError, isTrue);
      });
    },
    skip: objectBoxAvailable ? false : objectBoxMissingReason,
  );
}
