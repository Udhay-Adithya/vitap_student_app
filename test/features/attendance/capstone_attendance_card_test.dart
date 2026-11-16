import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:objectbox/objectbox.dart';
import 'package:vit_ap_student_app/core/models/capstone_attendance.dart';
import 'package:vit_ap_student_app/features/attendance/view/widgets/capstone_attendance_card.dart';

CapstoneAttendance capstone({
  String title = 'Capstone',
  String present = '14',
  String onDuty = '4',
  String absent = '12',
  String percentage = '60',
}) => CapstoneAttendance(
  title: title,
  guideEvaluationStatus: 'Registered, Invoice Generated,',
  dateOfRegistration: '2026-07-06 00:00:00.0',
  present: present,
  onDuty: onDuty,
  absent: absent,
  percentage: percentage,
  punches: ToMany<CapstonePunch>(items: []),
);

Future<void> pumpCard(WidgetTester tester, CapstoneAttendance value) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: CapstoneAttendanceCard(capstone: value)),
    ),
  );
}

void main() {
  testWidgets('shows the real percentage, not a placeholder', (tester) async {
    await pumpCard(tester, capstone());

    // Locks down the bug where the percentage arrived as "60%", failed to
    // parse, and rendered as 0%.
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('0%'), findsNothing);
  });

  testWidgets('warns when attendance is below the 75% threshold', (
    tester,
  ) async {
    await pumpCard(tester, capstone(percentage: '61'));

    expect(find.text('61%'), findsOneWidget);
    // The deficit badge is the warning; a percentage that fails to parse
    // reads as 0 and suppresses it entirely.
    expect(find.text('-14%'), findsOneWidget);
  });

  testWidgets('says so plainly when there is no usable percentage', (
    tester,
  ) async {
    await pumpCard(tester, capstone(percentage: ''));

    expect(find.text('No percentage'), findsOneWidget);
    expect(find.text('0%'), findsNothing);
  });

  testWidgets('keeps present, on duty and absent separate', (tester) async {
    await pumpCard(tester, capstone());

    // An on-duty day is neither attended nor absent; collapsing the three
    // counts into attended/total is what hides that.
    expect(find.text('Present 14'), findsOneWidget);
    expect(find.text('On duty 4'), findsOneWidget);
    expect(find.text('Absent 12'), findsOneWidget);
  });

  testWidgets('shows the registration title VTOP gave', (tester) async {
    await pumpCard(tester, capstone(title: 'SDP'));

    expect(find.text('SDP'), findsOneWidget);
  });

  testWidgets('falls back to a neutral label when VTOP sends no title', (
    tester,
  ) async {
    await pumpCard(tester, capstone(title: ''));

    expect(find.text('Capstone / SDP'), findsOneWidget);
  });
}
