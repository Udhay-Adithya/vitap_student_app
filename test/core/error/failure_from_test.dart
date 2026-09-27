import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/error/failure_from.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/vtop_errors.dart';

void main() {
  group('failureFrom', () {
    test('reports a dropped connection as no internet', () {
      final failure = failureFrom(const SocketException('Connection reset'));

      expect(failure.message, 'No internet connection');
    });

    test('uses the VTOP message for a VtopError', () {
      final failure = failureFrom(const VtopError.sessionExpired());

      expect(
        failure.message,
        vtopErrorMessage(const VtopError.sessionExpired()),
      );
    });

    test('reports malformed JSON as a bad response, not the parser text', () {
      final failure = failureFrom(const FormatException('Unexpected token'));

      expect(failure.message, 'Invalid response format from server');
    });

    test('labels anything else as unexpected by default', () {
      final failure = failureFrom(StateError('boom'));

      expect(failure.message, 'Unexpected error: Bad state: boom');
    });

    test('words anything else the way the caller asks', () {
      final failure = failureFrom(
        StateError('boom'),
        unexpected: (error) => 'Failed to fetch grades: $error',
      );

      expect(failure.message, 'Failed to fetch grades: Bad state: boom');
    });
  });

  group('vtopErrorMessage', () {
    test('treats a failed login and bad credentials the same way', () {
      expect(
        vtopErrorMessage(const VtopError.authenticationFailed('Invalid')),
        vtopErrorMessage(const VtopError.invalidCredentials()),
      );
    });

    // VTOP's lockout text says when the account unlocks; replacing it with
    // "invalid username or password" would send the student off retrying.
    test('passes the lockout text through untouched', () {
      const vtopText =
          'Number Of Maximum Fail Attempts Reached. Try after 30 minutes';

      expect(
        vtopErrorMessage(const VtopError.authenticationFailed(vtopText)),
        'Authentication failed: $vtopText',
      );
    });

    test('does not treat an ordinary parse error as a lockout', () {
      expect(
        vtopErrorMessage(const VtopError.parseError('missing table')),
        'Unable to process server response. Please try again.',
      );
    });
  });
}
