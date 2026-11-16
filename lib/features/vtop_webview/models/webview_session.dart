import 'package:vit_ap_student_app/features/vtop_webview/models/webview_cookie_data.dart';

/// What the WebView needs to continue the app's VTOP session as the same
/// client: its cookies, the CSRF token and user id the portal's forms post,
/// and the user agent the session was opened with.
class WebViewSession {
  const WebViewSession({
    required this.cookies,
    required this.csrfToken,
    required this.authorizedId,
    required this.userAgent,
  });

  final List<WebViewCookieData> cookies;
  final String? csrfToken;
  final String? authorizedId;
  final String userAgent;
}
