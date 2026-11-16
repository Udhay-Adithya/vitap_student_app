import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Name the app's own license is listed under on the licenses page.
const String appLicensePackage = 'VIT-AP Student App';

/// Name the bundled Rust crate's license is listed under.
const String rustLicensePackage = 'lib_vtop';

/// Shown at the top of the licenses page. This is the attribution that
/// NOTICE requires every distributed version to keep.
const String appLegalese =
    'Based on VIT-AP Student App\n'
    'https://github.com/Udhay-Adithya/vitap_student_app\n'
    'Licensed under the GNU General Public License, version 3';

/// Adds the licenses Flutter can't discover on its own to [LicenseRegistry].
///
/// Flutter's licenses page lists the LICENSE of every dependency, but not
/// the app's own license, the Rust crate (built by cargokit, not pub), or
/// the bundled font. Each NOTICE comes first so its attribution and
/// additional terms are read before the long license text.
///
/// The files are read lazily, only when the licenses page is opened.
void registerAppLicenses({AssetBundle? bundle}) {
  final AssetBundle assets = bundle ?? rootBundle;

  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      const [appLicensePackage],
      await assets.loadString('NOTICE'),
    );
    yield LicenseEntryWithLineBreaks(
      const [appLicensePackage],
      await assets.loadString('LICENSE'),
    );
    yield LicenseEntryWithLineBreaks(
      const [rustLicensePackage],
      await assets.loadString('rust/NOTICE'),
    );
    yield LicenseEntryWithLineBreaks(
      const [rustLicensePackage],
      await assets.loadString('rust/LICENSE'),
    );
    yield LicenseEntryWithLineBreaks(
      const ['Google Sans'],
      await assets.loadString('assets/fonts/OFL.txt'),
    );
  });
}
