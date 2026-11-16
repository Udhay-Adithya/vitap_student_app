import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vit_ap_student_app/core/utils/app_licenses.dart';
import 'package:vit_ap_student_app/features/account/view/pages/about_page.dart';

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'VITAP Student',
      packageName: 'com.udhay.vitapstudentapp',
      version: '2.3.4',
      buildNumber: '27',
      buildSignature: '',
    );
  });

  // The licenses screen is where NOTICE requires the attribution to be
  // reachable from, so the button must open it, not ripple and do nothing.
  testWidgets('the licenses tile opens the licenses page with the attribution',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    await tester.pumpAndSettle();

    final tile = find.text('Open Source Licenses');
    await tester.scrollUntilVisible(tile, 100);
    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
    expect(find.textContaining('Based on VIT-AP Student App'), findsOneWidget);
    expect(find.text(appLicensePackage), findsWidgets);
  });
}
