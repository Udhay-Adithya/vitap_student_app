import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/common/widget/app_feedback.dart';
import 'package:wiredash/wiredash.dart';

void main() {
  group('AppWiredashLocalizationsDelegate', () {
    const delegate = AppWiredashLocalizationsDelegate();

    test(
      // A real Future here makes Localizations rebuild its subtree after the
      // load completes, so opening Wiredash tears down and rebuilds the whole
      // app — the user loses whatever they were in the middle of. Wiredash
      // warns about it at startup; this fails the build instead.
      'load resolves synchronously',
      () {
        expect(
          delegate.load(const Locale('en', 'US')),
          isA<SynchronousFuture<WiredashLocalizations>>(),
        );
      },
    );

    test('serves the same strings for any locale', () async {
      // English-only app: a device set to another language should still get
      // this wording rather than falling back to Wiredash's defaults.
      expect(delegate.isSupported(const Locale('ta')), isTrue);
      expect(delegate.isSupported(const Locale('en')), isTrue);

      final tamil = await delegate.load(const Locale('ta'));
      final english = await delegate.load(const Locale('en'));
      expect(
        tamil.feedbackStep1MessageTitle,
        english.feedbackStep1MessageTitle,
      );
    });

    test('says who actually receives the feedback', () async {
      // The default reads "Send us your feedback", which in an app full of VTOP
      // data implies the university receives it. It does not.
      final strings = await delegate.load(const Locale('en'));
      expect(strings.feedbackStep1MessageDescription, contains('VIT-AP'));
    });

    test('falls back to the SDK wording for screens we did not reword', () {
      // Overriding a subclass rather than implementing all 56 getters means an
      // SDK upgrade that adds a screen still has copy for it.
      expect(AppWiredashLocalizations().feedbackBackButton, isNotEmpty);
    });
  });
}
