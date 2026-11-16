import 'package:flutter/foundation.dart';
import 'package:vit_ap_student_app/core/error/exceptions.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/models/semester_cache.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/services/secure_store_service.dart';
import 'package:vit_ap_student_app/core/utils/session_validity.dart';
import 'package:vit_ap_student_app/objectbox.g.dart';

/// Discards a stored user that has no usable credentials behind it.
///
/// The two halves of a session are persisted separately — the user in
/// ObjectBox, the credentials in the keychain — so they can drift apart. A
/// reinstall is the case that bites: Android auto-backup can restore the
/// database while the keystore key behind the encrypted credentials is gone,
/// and iOS keychain entries outlive an uninstall on their own schedule. The
/// app then opens straight into a home page it can never fetch for, and
/// because it believes it is logged in there is no route back to login.
///
/// Called before the first frame, so `CurrentUserNotifier` reads an empty box
/// and the app opens on onboarding instead.
Future<void> discardSessionWithoutCredentials({
  required Store store,
  required SecureStorageService secureStorage,
}) async {
  final userBox = store.box<User>();

  // Nothing stored means onboarding is already where the app will land.
  if (userBox.isEmpty()) return;

  Credentials? credentials;
  try {
    credentials = await secureStorage.getCredentials();
  } on SecureStorageException catch (e) {
    // Unreadable is the same as absent here — the encrypted entry survived the
    // reinstall but the key that decrypts it did not.
    debugPrint('Stored credentials could not be read: $e');
    credentials = null;
  }

  if (areCredentialsUsable(credentials)) return;

  debugPrint('Discarding stored user: no usable credentials behind it');
  userBox.removeAll();
  store.box<SemesterCache>().removeAll();

  try {
    await secureStorage.clearCredentials();
  } on SecureStorageException catch (e) {
    // Best effort. The user is already gone, so the app lands on onboarding
    // either way and the next login overwrites this entry.
    debugPrint('Failed to clear unusable credentials: $e');
  }

  // A half-restored session must not be mistaken for an ongoing demo session.
  await DemoService.instance.setDemoMode(false);
}
