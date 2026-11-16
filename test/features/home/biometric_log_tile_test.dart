import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/biometric/biometric_log_tile.dart';

void main() {
  group('scanLocationKind', () {
    // Regression: a `\b(MH|LH)\b` pattern matched none of these, because the
    // digit is flush against the prefix — so every hostel scan showed the
    // academic icon.
    test('reads the real hostel codes', () {
      for (final String code in <String>[
        'MH1',
        'MH7',
        'LH1',
        'LH4',
        'mh3',
        'MH-1',
      ]) {
        expect(scanLocationKind(code), ScanLocationKind.hostel, reason: code);
      }
    });

    test('reads capstone face attendance', () {
      expect(scanLocationKind('SDP-CAPSTONE-1'), ScanLocationKind.capstone);
      expect(scanLocationKind('SDP-CAPSTONE-2'), ScanLocationKind.capstone);
    });

    test('falls back to academic for block codes', () {
      for (final String code in <String>['CB', 'AB1', 'AB2', '105-AB-2']) {
        expect(scanLocationKind(code), ScanLocationKind.academic, reason: code);
      }
    });

    // The trailing boundary is what stops an academic code that merely contains
    // the letters from being read as a hostel.
    test('does not read hostel letters embedded in a longer code', () {
      expect(scanLocationKind('AB1-MHZ'), ScanLocationKind.academic);
      expect(scanLocationKind('ALHAMBRA'), ScanLocationKind.academic);
    });
  });

  group('formatScanTime', () {
    test('formats a 24-hour scan time for reading', () {
      expect(formatScanTime('08:42'), '8:42 AM');
      expect(formatScanTime('18:05'), '6:05 PM');
      expect(formatScanTime('00:15'), '12:15 AM');
    });

    test('tolerates surrounding whitespace', () {
      expect(formatScanTime(' 09:00 '), '9:00 AM');
    });

    // Regression: this parse used to run unguarded inside an item builder, so a
    // single malformed row threw and took the whole list down with it.
    test('returns the raw value instead of throwing on bad input', () {
      expect(formatScanTime('-'), '-');
      expect(formatScanTime('not a time'), 'not a time');
      expect(formatScanTime('25:00'), '25:00');
      expect(formatScanTime(''), '');
    });
  });
}
