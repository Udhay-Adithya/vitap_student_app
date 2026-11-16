import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/utils/avatar_image.dart';

void main() {
  // A one-pixel GIF: real bytes, small enough to inline.
  const String validPhoto =
      'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

  group('decodeVtopPfp', () {
    test('decodes a real payload', () {
      expect(decodeVtopPfp(validPhoto), base64Decode(validPhoto));
    });

    test('treats "no photo on file" as nothing to draw', () {
      // VTOP's parser yields an empty string when the profile page carries no
      // image, and demo mode has an explicit null.
      expect(decodeVtopPfp(null), isNull);
      expect(decodeVtopPfp(''), isNull);
      expect(decodeVtopPfp('   '), isNull);
    });

    test('returns null rather than throwing on a malformed payload', () {
      // Locks down that a truncated or non-base64 scrape degrades to the
      // default avatar instead of throwing inside a build.
      expect(decodeVtopPfp('not base64!!'), isNull);
      expect(decodeVtopPfp('R0lGODlhAQABAIAAAA'), isNull);
    });
  });

  group('hasVtopPfp', () {
    test('only true when there is a decodable photo', () {
      expect(hasVtopPfp(validPhoto), isTrue);
      expect(hasVtopPfp(''), isFalse);
      expect(hasVtopPfp(null), isFalse);
      expect(hasVtopPfp('not base64!!'), isFalse);
    });
  });

  group('avatarImageProvider', () {
    test('resolves a saved asset choice to that asset', () {
      final ImageProvider provider = avatarImageProvider(
        'assets/images/pfp/panda.png',
        validPhoto,
      );
      expect(provider, isA<AssetImage>());
      expect((provider as AssetImage).assetName, 'assets/images/pfp/panda.png');
    });

    test('resolves the sentinel to the decoded photo', () {
      final ImageProvider provider = avatarImageProvider(
        kVtopPfpPath,
        validPhoto,
      );
      expect(provider, isA<MemoryImage>());
      expect((provider as MemoryImage).bytes, base64Decode(validPhoto));
    });

    test('hands back the same instance for the same photo', () {
      // The caching contract: MemoryImage keys by byte-list identity, so a new
      // instance per build would miss Flutter's ImageCache and re-decode the
      // photo every frame.
      expect(
        identical(
          avatarImageProvider(kVtopPfpPath, validPhoto),
          avatarImageProvider(kVtopPfpPath, validPhoto),
        ),
        isTrue,
      );
    });

    test('falls back to the default avatar when the photo is unusable', () {
      // Someone picks their VTOP photo, then signs in to an account that has
      // none — the stale sentinel must still resolve to an avatar.
      for (final String? photo in <String?>[null, '', 'not base64!!']) {
        final ImageProvider provider = avatarImageProvider(kVtopPfpPath, photo);
        expect(provider, isA<AssetImage>());
        expect((provider as AssetImage).assetName, kDefaultPfpPath);
      }
    });
  });

  group('avatarChoices', () {
    test('leads with the photo when there is one', () {
      final List<String> choices = avatarChoices(validPhoto);
      expect(choices.first, kVtopPfpPath);
      expect(choices.length, kAvatarAssetPaths.length + 1);
      expect(choices.sublist(1), kAvatarAssetPaths);
    });

    test('is just the bundled avatars without a photo', () {
      expect(avatarChoices(null), kAvatarAssetPaths);
      expect(avatarChoices(''), kAvatarAssetPaths);
    });
  });
}
