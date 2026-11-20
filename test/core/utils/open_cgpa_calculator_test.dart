import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/utils/open_cgpa_calculator.dart';

void main() {
  final payload = <String, dynamic>{
    'credits_registered': '160',
    'credits_earned': '152',
    'cgpa': '8.91',
    'courses': [
      {'course_code': 'CSE1001', 'grade': 'A', 'credits': '4'},
    ],
  };

  group('cgpaCalculatorUrlFor', () {
    test('puts the grade history in the fragment, not the query', () {
      // The link used to be `/api/app/?data=...`, which sent every student's
      // grade history to the calculator host in the request line, where it
      // landed in request logs. A fragment is never sent to the server.
      final uri = Uri.parse(cgpaCalculatorUrlFor(payload));

      expect(uri.hasQuery, isFalse);
      expect(uri.fragment, startsWith('data='));
    });

    test('opens the report page directly', () {
      // The report page decodes in the browser. `/api/app` is a server route
      // and can't read a fragment, so linking there would lose the data.
      final uri = Uri.parse(cgpaCalculatorUrlFor(payload));

      expect(uri.scheme, 'https');
      expect(uri.host, 'cgpa-calculator-vitap.vercel.app');
      expect(uri.path, '/report');
    });

    test('round-trips the payload through gzip and base64url', () {
      final uri = Uri.parse(cgpaCalculatorUrlFor(payload));
      final encoded = uri.fragment.substring('data='.length);

      final decoded = jsonDecode(
        utf8.decode(gzip.decode(base64Url.decode(encoded))),
      );

      expect(decoded, payload);
    });
  });
}
