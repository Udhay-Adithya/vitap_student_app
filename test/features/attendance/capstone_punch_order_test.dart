import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/models/capstone_attendance.dart';
import 'package:vit_ap_student_app/features/attendance/utils/capstone_punch_order.dart';

CapstonePunch punch(String serial, String date) => CapstonePunch(
  serial: serial,
  date: date,
  day: '',
  dayType: 'Instructional',
  status: 'Present',
  punchTime: '',
);

List<String> dates(List<CapstonePunch> punches) => [
  for (final p in punches) p.date,
];

void main() {
  // The day-wise tab listed VTOP's calendar oldest first, so the latest day
  // was at the bottom of the list.
  test('puts the most recent day first', () {
    final ordered = newestPunchesFirst([
      punch('1', '17-07-2026'),
      punch('2', '18-07-2026'),
      punch('3', '20-07-2026'),
    ]);

    expect(dates(ordered), ['20-07-2026', '18-07-2026', '17-07-2026']);
  });

  test('orders by the date itself, not by the order it arrives in', () {
    final ordered = newestPunchesFirst([
      punch('30', '01-09-2026'),
      punch('1', '17-07-2026'),
      punch('12', '31-07-2026'),
    ]);

    expect(dates(ordered), ['01-09-2026', '31-07-2026', '17-07-2026']);
  });

  test('compares across months and years as dates, not as text', () {
    final ordered = newestPunchesFirst([
      punch('1', '31-12-2025'),
      punch('2', '01-01-2026'),
      punch('3', '15-02-2026'),
    ]);

    expect(dates(ordered), ['15-02-2026', '01-01-2026', '31-12-2025']);
  });

  test('puts a date it cannot read last instead of throwing', () {
    final ordered = newestPunchesFirst([
      punch('1', ''),
      punch('2', '17-07-2026'),
      punch('3', 'not a date'),
      punch('4', '18-07-2026'),
    ]);

    expect(dates(ordered).take(2), ['18-07-2026', '17-07-2026']);
    expect(dates(ordered).skip(2), unorderedEquals(['', 'not a date']));
  });

  test('breaks a tie on the same day by the later serial', () {
    final ordered = newestPunchesFirst([
      punch('4', '17-07-2026'),
      punch('5', '17-07-2026'),
    ]);

    expect([for (final p in ordered) p.serial], ['5', '4']);
  });

  test('leaves the input untouched', () {
    final input = [punch('1', '17-07-2026'), punch('2', '18-07-2026')];

    newestPunchesFirst(input);

    expect(dates(input), ['17-07-2026', '18-07-2026']);
  });
}
