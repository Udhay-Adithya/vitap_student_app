import 'package:url_launcher/url_launcher.dart';

/// Opens the device's mail composer for [address].
///
/// Returns false rather than throwing when nothing can handle it — a phone with
/// no mail app configured is a normal state, not an error worth a crash.
Future<bool> launchEmail(String address) =>
    _launch(Uri(scheme: 'mailto', path: address.trim()));

/// Opens the dialer with [number] filled in, without placing the call.
Future<bool> launchPhone(String number) =>
    _launch(Uri(scheme: 'tel', path: _dialable(number)));

/// VTOP hands back numbers with spaces and dashes in them, which `tel:` will
/// not accept.
String _dialable(String number) => number.replaceAll(RegExp(r'[^\d+]'), '');

Future<bool> _launch(Uri uri) async {
  try {
    return await launchUrl(uri);
  } catch (_) {
    return false;
  }
}
