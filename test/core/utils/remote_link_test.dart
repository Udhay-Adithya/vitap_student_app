import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/utils/remote_link.dart';

void main() {
  group('isOpenableRemoteLink', () {
    bool allowed(String url) => isOpenableRemoteLink(Uri.parse(url));

    test('allows web pages', () {
      expect(allowed('https://example.com/tool'), isTrue);
      expect(allowed('HTTPS://Example.com'), isTrue);
      // Campus-only tools are sometimes served without TLS.
      expect(allowed('http://172.18.10.10:1000/login'), isTrue);
    });

    test('refuses schemes the OS would act on', () {
      // Links from the For You feed, announcements and the changelog were
      // launched with any scheme. An `intent:` or `file:` URL in content
      // written outside the app would have been handed to the OS as-is.
      expect(allowed('intent://scan/#Intent;scheme=zxing;end'), isFalse);
      expect(allowed('file:///sdcard/Download/x.apk'), isFalse);
      expect(allowed('tel:+911234567890'), isFalse);
      expect(allowed('sms:+911234567890'), isFalse);
      expect(allowed('javascript:alert(1)'), isFalse);
      expect(allowed('upi://pay?pa=someone@bank'), isFalse);
    });

    test('refuses web schemes without a host', () {
      expect(allowed('https:///path-only'), isFalse);
      expect(allowed('/relative/path'), isFalse);
      expect(allowed('#section'), isFalse);
    });
  });
}
