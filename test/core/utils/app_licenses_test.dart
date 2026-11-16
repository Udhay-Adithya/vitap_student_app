import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/utils/app_licenses.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(LicenseRegistry.reset);

  Future<List<LicenseEntry>> entriesFor(String package) async {
    final all = await LicenseRegistry.licenses.toList();
    return all.where((e) => e.packages.contains(package)).toList();
  }

  String textOf(LicenseEntry entry) =>
      entry.paragraphs.map((p) => p.text).join('\n');

  // Locks down that the licenses page shows the app's own GPL terms and
  // attribution. If NOTICE or LICENSE drop out of the pubspec assets, the
  // stream throws on load and the page silently loses them.
  test('lists the app NOTICE before the GPL text', () async {
    registerAppLicenses();

    final entries = await entriesFor(appLicensePackage);

    expect(entries, hasLength(2));
    expect(textOf(entries.first), contains('Based on VITAP Student'));
    expect(textOf(entries.last), contains('GNU GENERAL PUBLIC LICENSE'));
  });

  test('lists lib_vtop under its Apache-2.0 NOTICE and license', () async {
    registerAppLicenses();

    final entries = await entriesFor(rustLicensePackage);

    expect(entries, hasLength(2));
    expect(textOf(entries.first), contains('lib_vtop'));
    expect(textOf(entries.last), contains('Apache License'));
  });

  test('the legalese carries the attribution NOTICE requires', () {
    expect(appLegalese, contains('Based on VITAP Student'));
    expect(
      appLegalese,
      contains('https://github.com/Udhay-Adithya/vitap_student_app'),
    );
  });
}
