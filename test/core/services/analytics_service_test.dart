import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';

/// Guards the two things about analytics that are easy to regress and
/// expensive to get wrong: the registration-number prefix must never leak the
/// digits that identify an individual student, and the no-op implementation
/// must satisfy the interface so tests can swap it in.
void main() {
  group('StudentIdentity.fromRegistrationNumber', () {
    test('splits a standard registration number into year and branch', () {
      final identity = StudentIdentity.fromRegistrationNumber('23BCE7625');
      expect(identity.joiningYear, '2023');
      expect(identity.branch, 'BCE');
    });

    test('discards the unique digits entirely', () {
      // This is the whole reason hashing is unnecessary: nothing downstream of
      // the parse can reconstruct which student it was.
      final identity = StudentIdentity.fromRegistrationNumber('21BCE7625');
      expect(identity.joiningYear, isNot(contains('7625')));
      expect(identity.branch, isNot(contains('7625')));
      expect(identity.toString(), isNot(contains('7625')));
    });

    test('normalises a lowercase branch code', () {
      expect(StudentIdentity.fromRegistrationNumber('22bce1234').branch, 'BCE');
    });

    test('tolerates surrounding whitespace', () {
      expect(
        StudentIdentity.fromRegistrationNumber('  24MEC0001  ').joiningYear,
        '2024',
      );
    });

    test('handles a five-digit unique suffix', () {
      final identity = StudentIdentity.fromRegistrationNumber('23BCE76251');
      expect(identity.joiningYear, '2023');
      expect(identity.branch, 'BCE');
    });

    test('falls back to Custom for anything off-pattern', () {
      // VTOP accepts several login id shapes; only the registration number
      // matches, and the rest must not be forwarded verbatim.
      for (final input in <String>[
        '',
        'someone@vitap.ac.in',
        '2024043196',
        'BCE237625',
        '23BC7625',
        '23BCEX625',
      ]) {
        expect(
          StudentIdentity.fromRegistrationNumber(input),
          StudentIdentity.unknown,
          reason: '"$input" should not be parsed as a registration number',
        );
      }
    });
  });

  group('NoopAnalyticsService', () {
    test('satisfies the interface without throwing', () async {
      const AnalyticsService analytics = NoopAnalyticsService();

      await analytics.initialize(enabled: true);
      await analytics.setCollectionEnabled(enabled: false);
      analytics.logScreen('HomePage');
      analytics.logEvent('some_event', {'a': 1, 'b': null, 'c': true});
      analytics.logLogin('vtop_credentials');
      analytics.logError('type', Exception('boom'), location: 'here');
      analytics.identifyStudent('23BCE7625');
      await analytics.reset();
    });
  });
}
