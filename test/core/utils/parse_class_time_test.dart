import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/utils/parse_class_time.dart';

void main() {
  group('parseClassTime', () {
    test('parses a valid HH:mm time to today', () {
      final result = parseClassTime('09:05');
      final now = DateTime.now();
      expect(result, isNotNull);
      expect(result!.year, now.year);
      expect(result.month, now.month);
      expect(result.day, now.day);
      expect(result.hour, 9);
      expect(result.minute, 5);
    });

    test('tolerates surrounding whitespace', () {
      expect(parseClassTime('  14:30 '), isNotNull);
      expect(parseClassTime('14:30')!.hour, 14);
    });

    // Regression: the "-" placeholder from empty VTOP grid cells used to throw a
    // FormatException and blank the home-screen upcoming-class widget.
    test('returns null for the "-" placeholder', () {
      expect(parseClassTime('-'), isNull);
    });

    test('returns null for null, empty and malformed input', () {
      expect(parseClassTime(null), isNull);
      expect(parseClassTime(''), isNull);
      expect(parseClassTime('9'), isNull);
      expect(parseClassTime('09:00:00'), isNull);
      expect(parseClassTime('ab:cd'), isNull);
    });

    test('returns null for out-of-range values', () {
      expect(parseClassTime('24:00'), isNull);
      expect(parseClassTime('10:60'), isNull);
      expect(parseClassTime('-1:00'), isNull);
    });
  });
}
