import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/utils/session_validity.dart';

void main() {
  Credentials credentials({
    String registrationNumber = '21BCE7625',
    String password = 'hunter2',
    String semSubId = 'VL20252601',
  }) {
    return Credentials(
      registrationNumber: registrationNumber,
      password: password,
      semSubId: semSubId,
    );
  }

  group('areCredentialsUsable', () {
    test('accepts a complete set', () {
      expect(areCredentialsUsable(credentials()), isTrue);
    });

    test('rejects nothing stored', () {
      // The reinstall case: the user survived in ObjectBox but the keychain
      // entry did not, so the app must not open as if it were logged in.
      expect(areCredentialsUsable(null), isFalse);
    });

    test('rejects a blank registration number or password', () {
      // A partially written or restored entry deserializes fine but is just as
      // unusable as having no entry at all.
      expect(
        areCredentialsUsable(credentials(registrationNumber: '')),
        isFalse,
      );
      expect(areCredentialsUsable(credentials(password: '')), isFalse);
      expect(
        areCredentialsUsable(credentials(registrationNumber: '   ')),
        isFalse,
      );
      expect(areCredentialsUsable(credentials(password: '  ')), isFalse);
    });

    test('does not require a semester id', () {
      // The semester is re-selectable in the app, so its absence is not a
      // reason to throw the student back out to login.
      expect(areCredentialsUsable(credentials(semSubId: '')), isTrue);
    });
  });
}
