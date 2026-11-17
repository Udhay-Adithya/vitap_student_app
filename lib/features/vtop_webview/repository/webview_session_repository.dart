import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/error/failure_from.dart';
import 'package:vit_ap_student_app/core/services/secure_store_service.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/vtop_webview/models/webview_cookie_data.dart';
import 'package:vit_ap_student_app/features/vtop_webview/models/webview_session.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/vtop_client.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'webview_session_repository.g.dart';

@riverpod
WebViewSessionRepository webViewSessionRepository(Ref ref) =>
    WebViewSessionRepository(
      vtopService: ref.watch(vtopClientServiceProvider),
      secureStorage: ref.watch(secureStorageServiceProvider),
    );

/// Hands the app's authenticated VTOP session over to the WebView.
class WebViewSessionRepository {
  WebViewSessionRepository({
    required VtopClientService vtopService,
    required SecureStorageService secureStorage,
  }) : _vtopService = vtopService,
       _secureStorage = secureStorage;

  final VtopClientService _vtopService;
  final SecureStorageService _secureStorage;

  Future<Either<Failure, WebViewSession>> openSession() async {
    try {
      final credentials = await _secureStorage.getCredentials();
      if (credentials == null) {
        return Left(Failure('No credentials found. Please login first.'));
      }

      final session = await _vtopService.executeWithRetry(
        credentials: credentials,
        operation: _readSession,
      );
      return Right(session);
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) => error is _SessionNotUsable
              ? error.message
              : 'Failed to load VTOP: $error',
        ),
      );
    }
  }

  /// Drops the current VTOP client, so the next [openSession] logs in afresh.
  void resetSession() => _vtopService.resetClient();

  Future<WebViewSession> _readSession(VtopClient client) async {
    if (!await vtop.fetchIsAuth(client: client)) {
      throw const _SessionNotUsable(
        'Session not authenticated. Please refresh.',
      );
    }

    final cookies = parseCookieString(
      String.fromCharCodes(await vtop.fetchCookies(client: client)),
    );
    if (cookies.isEmpty) {
      throw const _SessionNotUsable(
        'No session cookies found. Please refresh.',
      );
    }

    return WebViewSession(
      cookies: cookies,
      csrfToken: await vtop.fetchCsrfToken(client: client),
      authorizedId: await vtop.fetchUsername(client: client),
      // The WebView and the Rust client share one server session, so they
      // have to look like one client. VtopConfig picks a random browser UA per
      // session, so the only way to match is to ask the session which one it
      // used.
      userAgent: await vtop.fetchUserAgent(client: client),
    );
  }
}

/// A session VTOP answered for but that the WebView cannot continue.
class _SessionNotUsable implements Exception {
  const _SessionNotUsable(this.message);

  final String message;

  @override
  String toString() => message;
}
