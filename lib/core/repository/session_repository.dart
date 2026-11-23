import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/store.dart';
import 'package:vit_ap_student_app/core/providers/user_persistence.dart';
import 'package:vit_ap_student_app/core/services/secure_store_service.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/core/utils/file_saver.dart';
import 'package:vit_ap_student_app/objectbox.g.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'session_repository.g.dart';

@Riverpod(keepAlive: true)
SessionRepository sessionRepository(Ref ref) => SessionRepository(
  store: ref.watch(storeProvider),
  secureStorage: ref.watch(secureStorageServiceProvider),
  resetVtopClient: ref.watch(vtopClientServiceProvider).resetClient,
  sessionCleanups: [
    () => WebViewCookieManager().clearCookies(),
    FileSaver.clearViewedFiles,
  ],
);

/// Where a signed-in session lives on the device: the user graph in ObjectBox
/// and the credentials in the keychain.
class SessionRepository {
  SessionRepository({
    required Store store,
    required SecureStorageService secureStorage,
    void Function()? resetVtopClient,
    List<Future<void> Function()> sessionCleanups = const [],
  }) : _store = store,
       _secureStorage = secureStorage,
       _resetVtopClient = resetVtopClient ?? (() {}),
       _sessionCleanups = sessionCleanups;

  final Store _store;
  final SecureStorageService _secureStorage;
  final void Function() _resetVtopClient;
  final List<Future<void> Function()> _sessionCleanups;

  User? loadUser() =>
      _store.box<User>().query().order(User_.id).build().findFirst();

  /// Writes [user] and returns it as stored, with its id.
  ///
  /// Refreshing an existing user replaces its relations rather than adding to
  /// them; see [saveUser].
  User saveUserGraph(User user) {
    final id = saveUser(_store, user);
    return user.id == id ? user : user.copyWith(id: id);
  }

  void clearUserData() => removeAllUserData(_store);

  Future<Credentials?> readCredentials() => _secureStorage.getCredentials();

  Future<void> saveCredentials(Credentials credentials) =>
      _secureStorage.saveCredentials(credentials);

  Future<void> clearCredentials() => _secureStorage.clearCredentials();

  /// Drops the copies of the VTOP session that live outside storage: the
  /// authenticated client held in memory (cookie jar, CSRF token, password),
  /// the cookies handed to the WebView, and documents opened with "View".
  ///
  /// The cleanups after the client reset are best effort. They go through
  /// platform channels, and a logout must not fail halfway because one did.
  Future<void> endVtopSession() async {
    _resetVtopClient();
    for (final cleanup in _sessionCleanups) {
      try {
        await cleanup();
      } catch (e) {
        if (kDebugMode) debugPrint('Session cleanup skipped: $e');
      }
    }
  }
}
