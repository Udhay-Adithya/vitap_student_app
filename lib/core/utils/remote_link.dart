import 'package:url_launcher/url_launcher.dart';

/// Whether a link that arrived over the network may be opened.
///
/// For You items, announcements and the changelog are written outside the app
/// (submitted by students, hand-edited, or fetched from GitHub), so their links
/// are only allowed to be web pages. Anything else, such as `intent:`, `file:`,
/// `tel:` or `sms:`, would be handed to the OS as-is. `http` stays allowed
/// because some campus-only tools are served without TLS.
bool isOpenableRemoteLink(Uri uri) =>
    (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;

/// Opens [url] in the browser if [isOpenableRemoteLink] allows it.
///
/// Returns whether anything was opened, so the caller can say so when not.
/// Links the app defines itself (UPI, mail, its own pages) go through
/// `directToWeb` or `launchContact` instead.
Future<bool> openRemoteLink(String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !isOpenableRemoteLink(uri)) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
