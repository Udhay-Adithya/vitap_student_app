import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/models/capstone_attendance.dart';

/// The wire shape the Rust side emits: the registration info and the tally are
/// flattened into one object, with the punch calendar nested under it.
const _wire = '''
{
  "title": "Capstone",
  "guide_evaluation_status": "Registered, Invoice Generated,",
  "date_of_registration": "2026-07-06 00:00:00.0",
  "present": "14",
  "on_duty": "4",
  "absent": "12",
  "percentage": "60",
  "punches": [
    {"serial": "1", "date": "17-07-2026", "day": "FRIDAY",
     "day_type": "Instructional", "status": "Absent", "punch_time": ""},
    {"serial": "2", "date": "18-07-2026", "day": "SATURDAY",
     "day_type": "Instructional", "status": "Present", "punch_time": "09:14:22"},
    {"serial": "3", "date": "19-07-2026", "day": "SUNDAY",
     "day_type": "Holiday", "status": "", "punch_time": ""}
  ]
}
''';

CapstoneAttendance _parse([String json = _wire]) =>
    CapstoneAttendance.fromJson(jsonDecode(json) as Map<String, dynamic>);

void main() {
  group('CapstoneAttendance.fromJson', () {
    test('reads the flat registration and tally fields', () {
      final capstone = _parse();

      expect(capstone.title, 'Capstone');
      expect(capstone.guideEvaluationStatus, 'Registered, Invoice Generated,');
      expect(capstone.dateOfRegistration, '2026-07-06 00:00:00.0');
      expect(capstone.present, '14');
      expect(capstone.onDuty, '4');
      expect(capstone.absent, '12');
    });

    test('reads the nested punch calendar', () {
      final punches = _parse().punches.toList();

      expect(punches, hasLength(3));
      expect(punches[1].date, '18-07-2026');
      expect(punches[1].dayType, 'Instructional');
      expect(punches[1].status, 'Present');
      expect(punches[1].punchTime, '09:14:22');
    });

    test('a day with no status or punch stays empty rather than a dash', () {
      final holiday = _parse().punches.toList()[2];

      expect(holiday.dayType, 'Holiday');
      // VTOP writes "-" here; the parser normalises it so the UI can tell
      // "no status" apart from a real one instead of rendering a dash.
      expect(holiday.status, isEmpty);
      expect(holiday.punchTime, isEmpty);
    });

    test('round-trips through toJson', () {
      final again = _parse(jsonEncode(_parse().toJson()));

      expect(again.percentage, '60');
      expect(again.punches, hasLength(3));
      expect(again.punches.toList()[0].day, 'FRIDAY');
    });
  });

  group('percentageValue', () {
    /// Locks down the bug that made the capstone card read 0%: the percentage
    /// arrives from VTOP as "60%", and leaving the sign on it makes every
    /// numeric parse fail. It is stripped before it reaches Dart.
    test('parses the stripped percentage', () {
      expect(_parse().percentageValue, 60.0);
    });

    test('is null rather than zero when VTOP sends something unparseable', () {
      final capstone = _parse(_wire.replaceFirst('"60"', '"60%"'));

      // Null, not 0.0 — a confident zero reads as "you never turned up", and
      // it also silently disabled the low-attendance warning.
      expect(capstone.percentageValue, isNull);
    });
  });

  group('day tally', () {
    test('keeps present, on duty and absent as three separate counts', () {
      final capstone = _parse();

      expect(capstone.presentDays, 14);
      expect(capstone.onDutyDays, 4);
      expect(capstone.absentDays, 12);
      expect(capstone.totalDays, 30);
    });

    test('treats missing counts as zero rather than throwing', () {
      final capstone = _parse(
        _wire.replaceFirst('"on_duty": "4"', '"on_duty": ""'),
      );

      expect(capstone.onDutyDays, 0);
      expect(capstone.totalDays, 26);
    });
  });
}
