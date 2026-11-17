import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/vtop_webview/models/webview_cookie_data.dart';
import 'package:vit_ap_student_app/features/vtop_webview/models/webview_session.dart';
import 'package:vit_ap_student_app/features/vtop_webview/repository/webview_session_repository.dart';
import 'package:vit_ap_student_app/features/vtop_webview/viewmodel/webview_session_viewmodel.dart';

import '../../helpers/provider_harness.dart';

const _session = WebViewSession(
  cookies: [WebViewCookieData(name: 'JSESSIONID', value: 'abc')],
  csrfToken: 'csrf',
  authorizedId: '23BCE0001',
  userAgent: 'test-agent',
);

class _FakeSessionRepository extends Fake implements WebViewSessionRepository {
  _FakeSessionRepository({this.failure});

  final String? failure;
  final List<String> calls = [];

  @override
  Future<Either<Failure, WebViewSession>> openSession() async {
    calls.add('open');
    if (failure != null) return Left(Failure(failure!));
    return const Right(_session);
  }

  @override
  void resetSession() => calls.add('reset');
}

void main() {
  group('WebViewSessionRepository', () {
    test('asks for a login when no credentials are saved', () async {
      final repository = WebViewSessionRepository(
        vtopService: VtopClientService(),
        secureStorage: FakeSecureStorageService(),
      );

      final res = await repository.openSession();

      expect(
        res.getLeft().toNullable()?.message,
        'No credentials found. Please login first.',
      );
    });
  });

  group('WebViewSessionViewModel', () {
    late _FakeSessionRepository repository;

    ProviderContainer harness({String? failure}) {
      repository = _FakeSessionRepository(failure: failure);
      final container = ProviderContainer(
        overrides: [
          webViewSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(webViewSessionViewModelProvider, (_, _) {});
      return container;
    }

    test('fetches nothing until opened', () {
      final ref = harness();

      expect(ref.read(webViewSessionViewModelProvider), isNull);
      expect(repository.calls, isEmpty);
    });

    test('holds the session once opened', () async {
      final ref = harness();

      await ref.read(webViewSessionViewModelProvider.notifier).open();

      expect(ref.read(webViewSessionViewModelProvider)?.value, _session);
    });

    test('surfaces the failure message', () async {
      final ref = harness(failure: 'Session not authenticated.');

      await ref.read(webViewSessionViewModelProvider.notifier).open();

      expect(
        ref.read(webViewSessionViewModelProvider)?.error,
        'Session not authenticated.',
      );
    });

    /// Retrying the same rejected session gets the same rejection, so a
    /// refresh has to drop the client and log in again first.
    test('refresh starts a fresh login before reopening', () async {
      final ref = harness();

      await ref.read(webViewSessionViewModelProvider.notifier).refresh();

      expect(repository.calls, ['reset', 'open']);
    });
  });
}
