import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/utils/semantic_version.dart';
import 'package:vit_ap_student_app/features/home/model/announcement.dart';
import 'package:vit_ap_student_app/features/home/utils/announcement_targeting.dart';

final DateTime now = DateTime(2026, 8, 10, 12);

AnnouncementAudience audience({
  AnnouncementPlatform platform = AnnouncementPlatform.android,
  String? version = '2.3.4',
  String? joiningYear = '2023',
  String? branch = 'BCE',
}) => AnnouncementAudience(
  platform: platform,
  appVersion: SemanticVersion.tryParse(version),
  joiningYear: joiningYear,
  branch: branch,
);

Map<String, dynamic> raw({
  String id = 'a1',
  String? title = 'Title',
  String? message = 'Message',
  String type = 'system',
  String importance = 'high',
  bool isActive = true,
  bool? dismissible,
  String? createdAt = '2026-08-01T00:00:00Z',
  String? startsAt,
  String? expiresAt = '2026-12-01T00:00:00Z',
  Object? targets,
}) => <String, dynamic>{
  'id': id,
  'title': title,
  'message': message,
  'type': type,
  'importance': importance,
  'isActive': isActive,
  if (dismissible != null) 'dismissible': dismissible,
  'createdAt': createdAt,
  if (startsAt != null) 'startsAt': startsAt,
  'expiresAt': expiresAt,
  if (targets != null) 'targets': targets,
};

Announcement parse(Map<String, dynamic> json) => Announcement.tryParse(json)!;

void main() {
  group('Announcement.tryParse', () {
    test('reads a well-formed entry', () {
      final Announcement a = parse(raw());
      expect(a.type, AnnouncementType.system);
      expect(a.importance, AnnouncementImportance.high);
      expect(a.dismissible, isTrue);
      expect(a.expiresAt, isNotNull);
    });

    // A typo in importance should not bury the announcement at the quietest
    // level — it falls back to medium.
    test('falls back on unknown enum values', () {
      expect(
        parse(raw(importance: 'crticial')).importance,
        AnnouncementImportance.medium,
      );
      expect(parse(raw(type: 'weather')).type, AnnouncementType.general);
    });

    // Regression: three unguarded DateTime.parse calls used to make one bad
    // date either blank the whole feed or throw inside build().
    test('survives unusable dates', () {
      final Announcement a = parse(
        raw(createdAt: 'yesterday', expiresAt: 'soon'),
      );
      expect(a.createdAt, isNull);
      expect(a.expiresAt, isNull);
    });

    test('skips an entry with nothing to show', () {
      expect(Announcement.tryParse(raw(title: null)), isNull);
      expect(Announcement.tryParse(raw(message: null)), isNull);
      expect(Announcement.tryParse(raw(id: '')), isNull);
      expect(Announcement.tryParse('not a map'), isNull);
    });

    test('defaults dismissible to true and honours an explicit false', () {
      expect(parse(raw()).dismissible, isTrue);
      expect(parse(raw(dismissible: false)).dismissible, isFalse);
    });
  });

  group('AnnouncementResponse.parse', () {
    test('keeps the good entries and drops the bad ones', () {
      final AnnouncementResponse response = AnnouncementResponse.parse(
        <String, dynamic>{
          'announcements': <Object?>[
            raw(id: 'good'),
            raw(id: 'bad', title: null),
            'garbage',
          ],
        },
      );
      expect(response.announcements.map((Announcement a) => a.id), <String>[
        'good',
      ]);
    });

    // Regression: `metadata` was a required field nothing read, so leaving it
    // out failed the whole parse and blanked the feature.
    test('does not need version or metadata', () {
      final AnnouncementResponse response = AnnouncementResponse.parse(
        <String, dynamic>{
          'announcements': <Object?>[raw()],
        },
      );
      expect(response.announcements, hasLength(1));
    });

    test('degrades to empty on a malformed body', () {
      expect(AnnouncementResponse.parse(null).announcements, isEmpty);
      expect(
        AnnouncementResponse.parse(<String, dynamic>{}).announcements,
        isEmpty,
      );
    });
  });

  group('targets', () {
    test('an absent block reaches everyone', () {
      expect(matchesAudience(parse(raw()), audience()), isTrue);
      expect(
        matchesAudience(
          parse(raw()),
          audience(platform: AnnouncementPlatform.ios, joiningYear: '2019'),
        ),
        isTrue,
      );
    });

    test('platform gate', () {
      final Announcement a = parse(
        raw(
          targets: <String, dynamic>{
            'platforms': <String>['ios'],
          },
        ),
      );
      expect(
        matchesAudience(a, audience(platform: AnnouncementPlatform.ios)),
        isTrue,
      );
      expect(
        matchesAudience(a, audience(platform: AnnouncementPlatform.android)),
        isFalse,
      );
    });

    test('version bounds are inclusive', () {
      final Announcement a = parse(
        raw(targets: <String, dynamic>{'maxAppVersion': '2.3.3'}),
      );
      expect(matchesAudience(a, audience(version: '2.3.3')), isTrue);
      expect(matchesAudience(a, audience(version: '2.3.4')), isFalse);
      expect(matchesAudience(a, audience(version: '2.0.0')), isTrue);
    });

    // The reason SemanticVersion exists: '2.10.0' is above '2.9.0'.
    test('version bounds compare numerically', () {
      final Announcement a = parse(
        raw(targets: <String, dynamic>{'minAppVersion': '2.9.0'}),
      );
      expect(matchesAudience(a, audience(version: '2.10.0')), isTrue);
      expect(matchesAudience(a, audience(version: '2.8.9')), isFalse);
    });

    test(
      'holds back a version-gated notice when the version is unreadable',
      () {
        final Announcement a = parse(
          raw(targets: <String, dynamic>{'maxAppVersion': '2.3.3'}),
        );
        expect(matchesAudience(a, audience(version: null)), isFalse);
      },
    );

    test('cohort gates', () {
      final Announcement a = parse(
        raw(
          targets: <String, dynamic>{
            'joiningYears': <String>['2023'],
            'branches': <String>['bce'],
          },
        ),
      );
      expect(matchesAudience(a, audience()), isTrue);
      expect(matchesAudience(a, audience(joiningYear: '2024')), isFalse);
      expect(matchesAudience(a, audience(branch: 'BME')), isFalse);
      expect(matchesAudience(a, audience(branch: null)), isFalse);
    });

    // A mis-targeted announcement is worse than a missing one.
    test('a malformed block skips the announcement entirely', () {
      expect(
        Announcement.tryParse(
          raw(
            targets: <String, dynamic>{
              'platforms': <String>['windows'],
            },
          ),
        ),
        isNull,
      );
      expect(
        Announcement.tryParse(
          raw(targets: <String, dynamic>{'minAppVersion': 'latest'}),
        ),
        isNull,
      );
      expect(Announcement.tryParse(raw(targets: 'android')), isNull);
    });
  });

  group('isWithinSchedule', () {
    test('respects isActive', () {
      expect(isWithinSchedule(parse(raw(isActive: false)), now: now), isFalse);
    });

    test('holds an announcement until startsAt', () {
      final Announcement a = parse(raw(startsAt: '2026-09-01T00:00:00Z'));
      expect(isWithinSchedule(a, now: now), isFalse);
      expect(isWithinSchedule(a, now: DateTime(2026, 9, 2)), isTrue);
    });

    test('drops it once expired', () {
      final Announcement a = parse(raw(expiresAt: '2026-08-01T00:00:00Z'));
      expect(isWithinSchedule(a, now: now), isFalse);
    });

    test('never expires without an expiresAt', () {
      final Announcement a = parse(raw(expiresAt: null));
      expect(isWithinSchedule(a, now: DateTime(2099)), isTrue);
    });
  });

  group('visibleAnnouncements', () {
    test('sorts by importance then recency', () {
      final List<Announcement> feed = <Announcement>[
        parse(raw(id: 'low', importance: 'low')),
        parse(
          raw(
            id: 'old-critical',
            importance: 'critical',
            createdAt: '2026-07-01T00:00:00Z',
          ),
        ),
        parse(
          raw(
            id: 'new-critical',
            importance: 'critical',
            createdAt: '2026-08-05T00:00:00Z',
          ),
        ),
      ];

      expect(
        visibleAnnouncements(
          feed,
          audience: audience(),
          now: now,
        ).map((Announcement a) => a.id),
        <String>['new-critical', 'old-critical', 'low'],
      );
    });

    test('hides dismissed announcements but not undismissable ones', () {
      final List<Announcement> feed = <Announcement>[
        parse(raw(id: 'normal')),
        parse(raw(id: 'forced', dismissible: false)),
      ];

      expect(
        visibleAnnouncements(
          feed,
          audience: audience(),
          dismissedIds: <String>{'normal', 'forced'},
          now: now,
        ).map((Announcement a) => a.id),
        <String>['forced'],
      );
    });
  });

  group('prunedDismissedIds', () {
    test('forgets ids that have left the feed', () {
      expect(
        prunedDismissedIds(
          <String>{'a', 'gone'},
          <Announcement>[parse(raw(id: 'a'))],
        ),
        <String>{'a'},
      );
    });
  });
}
