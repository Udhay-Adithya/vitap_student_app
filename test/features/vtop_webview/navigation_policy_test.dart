import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/features/vtop_webview/navigation_policy.dart';

void main() {
  group('isVtopNavigation', () {
    test('allows pages on the VTOP origin', () {
      expect(isVtopNavigation('https://vtop.vitap.ac.in/vtop/content'), isTrue);
      expect(
        isVtopNavigation('https://vtop.vitap.ac.in:443/vtop/open/page'),
        isTrue,
      );
      expect(isVtopNavigation('https://VTOP.vitap.ac.in/vtop/login'), isTrue);
    });

    test('refuses hosts that only start with the VTOP origin', () {
      // The check used to be `url.startsWith('https://vtop.vitap.ac.in')`,
      // which let both of these load inside the signed-in WebView: the first
      // is another domain, the second sends the user to example.com with the
      // VTOP host as a username.
      expect(
        isVtopNavigation('https://vtop.vitap.ac.in.example.com/login'),
        isFalse,
      );
      expect(
        isVtopNavigation('https://vtop.vitap.ac.in@example.com/'),
        isFalse,
      );
    });

    test('refuses other schemes and hosts', () {
      expect(isVtopNavigation('http://vtop.vitap.ac.in/vtop/content'), isFalse);
      expect(isVtopNavigation('https://vitap.ac.in/'), isFalse);
      expect(isVtopNavigation('https://example.com/vtop.vitap.ac.in'), isFalse);
      expect(isVtopNavigation('javascript:alert(1)'), isFalse);
      expect(isVtopNavigation(''), isFalse);
    });
  });
}
