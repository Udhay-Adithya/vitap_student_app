import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/home/model/general_outing_report.dart';
import 'package:vit_ap_student_app/features/home/repository/outing_remote_repository.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/outing_reports_viewmodel.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

GeneralOutingReport report(String serial) => GeneralOutingReport(
  serial: serial,
  registrationNumber: '23BCE0001',
  placeOfVisit: 'Vijayawada',
  purposeOfVisit: 'Shopping',
  fromDate: '14-Nov-2026',
  fromTime: '09:00',
  toDate: '14-Nov-2026',
  toTime: '18:00',
  status: 'Accepted',
  canDownload: true,
  leaveId: 'L$serial',
);

/// Fails every fetch, the way a call does when the device is offline.
class _OfflineOutingRepository extends OutingRemoteRepository {
  _OfflineOutingRepository() : super(http.Client(), VtopClientService());

  @override
  Future<Either<Failure, List<GeneralOutingReport>>> fetchGeneralOutingReports({
    required String registrationNumber,
    required String password,
  }) async => Left(Failure('No internet connection'));
}

void main() {
  group(
    'GeneralOutingReportsViewModel offline',
    () {
      late TestDependencies deps;

      Future<ProviderContainer> harness() async {
        deps = await registerTestDependencies(credentials: testCredentials());
        final container = ProviderContainer(
          overrides: [
            outingRemoteRepositoryProvider.overrideWithValue(
              _OfflineOutingRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);
        container.listen(generalOutingReportsViewModelProvider, (_, _) {});
        return container;
      }

      /// Offline used to be decided by probing third-party hosts before the
      /// fetch, and that branch read the cache even on a silent refresh. Now the
      /// failed fetch is the signal, so the fallback has to live in the failure
      /// path or a silent refresh offline shows an error over a full cache.
      test('a silent refresh falls back to the cache', () async {
        final ref = await harness();
        deps.store.box<GeneralOutingReport>().put(report('1'));

        final synced = await ref
            .read(generalOutingReportsViewModelProvider.notifier)
            .fetchGeneralOutingReports(silentRefresh: true);

        final state = ref.read(generalOutingReportsViewModelProvider);
        expect(synced, isFalse);
        expect(state?.hasError, isFalse);
        expect(state?.value?.map((r) => r.serial), ['1']);
      });

      test('shows the failure when there is nothing cached', () async {
        final ref = await harness();

        final synced = await ref
            .read(generalOutingReportsViewModelProvider.notifier)
            .fetchGeneralOutingReports();

        final state = ref.read(generalOutingReportsViewModelProvider);
        expect(synced, isFalse);
        expect(state?.error, 'No internet connection');
      });
    },
    skip: objectBoxAvailable ? false : objectBoxMissingReason,
  );
}
