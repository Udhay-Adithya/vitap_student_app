/// Simple cookie model for parsing HTTP cookies.
class WebViewCookieData {
  final String name;
  final String value;

  const WebViewCookieData({required this.name, required this.value});

  @override
  String toString() => '$name=$value';
}

/// Parses a cookie string into individual cookie objects.
///
/// The cookie string should be in the format: "name1=value1; name2=value2; ..."
List<WebViewCookieData> parseCookieString(String cookieString) {
  final cookies = <WebViewCookieData>[];

  final parts = cookieString.split(';');

  for (final part in parts) {
    final trimmedPart = part.trim();
    if (trimmedPart.isEmpty) continue;

    final equalsIndex = trimmedPart.indexOf('=');
    if (equalsIndex == -1) continue;

    final name = trimmedPart.substring(0, equalsIndex).trim();
    final value = trimmedPart.substring(equalsIndex + 1).trim();

    if (name.isNotEmpty) {
      cookies.add(WebViewCookieData(name: name, value: value));
    }
  }

  return cookies;
}
