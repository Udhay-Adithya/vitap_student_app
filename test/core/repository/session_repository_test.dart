import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/repository/session_repository.dart';

import '../../helpers/object_box_test_store.dart';
import '../../helpers/provider_harness.dart';

void main() {
  group(
    'SessionRepository.endVtopSession',
    () {
      test('resets the client and then runs every cleanup', () async {
        // Logout used to clear storage and the keychain but leave the signed-in
        // VTOP client in memory and its cookies in the WebView, so a signed-out
        // app still held a live session until the process died.
        final calls = <String>[];
        final repository = SessionRepository(
          store: TestStore.open().store,
          secureStorage: FakeSecureStorageService(),
          resetVtopClient: () => calls.add('reset'),
          sessionCleanups: [
            () async => calls.add('cookies'),
            () async => calls.add('viewed files'),
          ],
        );

        await repository.endVtopSession();

        expect(calls, ['reset', 'cookies', 'viewed files']);
      });

      test('a failing cleanup neither stops the rest nor throws', () async {
        // The cleanups go through platform channels. One that throws must not
        // leave a logout half done.
        final calls = <String>[];
        final repository = SessionRepository(
          store: TestStore.open().store,
          secureStorage: FakeSecureStorageService(),
          resetVtopClient: () => calls.add('reset'),
          sessionCleanups: [
            () async => throw StateError('no WebView platform'),
            () async => calls.add('viewed files'),
          ],
        );

        await expectLater(repository.endVtopSession(), completes);
        expect(calls, ['reset', 'viewed files']);
      });
    },
    skip: objectBoxAvailable ? false : objectBoxMissingReason,
  );
}
