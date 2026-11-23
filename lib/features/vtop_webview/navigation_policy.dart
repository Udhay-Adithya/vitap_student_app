import 'package:vit_ap_student_app/core/constants/server_constants.dart';

/// Whether the VTOP WebView may load [url] itself.
///
/// The WebView carries the student's authenticated VTOP session and runs
/// JavaScript, so it stays on VTOP's own origin. The host is compared after
/// parsing: a prefix check on the raw string also accepts
/// `https://vtop.vitap.ac.in.example.com/` and
/// `https://vtop.vitap.ac.in@example.com/`, whose real hosts are elsewhere.
bool isVtopNavigation(String url) {
  final uri = Uri.tryParse(url);
  return uri != null &&
      uri.scheme == 'https' &&
      uri.host == ServerConstants.vtopDomain &&
      uri.userInfo.isEmpty;
}
