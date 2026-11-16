/// The announcement feed, parsed defensively.
///
/// Every field here comes from a JSON file edited by hand and pushed to GitHub
/// with no validation step, usually in a hurry to announce something urgent. So
/// parsing never throws: unknown enum values fall back, unusable dates become
/// null, and an entry that cannot be read at all is skipped while the rest of
/// the feed still shows. Generated `fromJson` was the wrong tool for that — it
/// throws on a type mismatch and takes the whole response with it.
library;

import 'package:vit_ap_student_app/core/utils/semantic_version.dart';

/// What an announcement is about. Drives the icon only.
enum AnnouncementType {
  academic,
  facility,
  maintenance,
  system,
  general;

  static AnnouncementType parse(Object? value) =>
      _matchName(values, value) ?? AnnouncementType.general;
}

/// How loudly an announcement should be presented.
enum AnnouncementImportance {
  low,
  medium,
  high,
  critical;

  /// Sort weight — critical first.
  int get rank => switch (this) {
    AnnouncementImportance.critical => 4,
    AnnouncementImportance.high => 3,
    AnnouncementImportance.medium => 2,
    AnnouncementImportance.low => 1,
  };

  /// Falls back to [medium] rather than to the quietest level: a typo in
  /// `"crticial"` should still be seen, not buried.
  static AnnouncementImportance parse(Object? value) =>
      _matchName(values, value) ?? AnnouncementImportance.medium;
}

/// Which devices an announcement is for.
enum AnnouncementPlatform {
  android,
  ios;

  static AnnouncementPlatform? tryParse(Object? value) =>
      _matchName(values, value);
}

T? _matchName<T extends Enum>(List<T> values, Object? value) {
  if (value is! String) return null;
  final String needle = value.trim().toLowerCase();
  for (final T candidate in values) {
    if (candidate.name == needle) return candidate;
  }
  return null;
}

/// Who should see an announcement.
///
/// Every field is optional and an absent field means "no restriction", so the
/// announcements already in the feed — which carry no `targets` block at all —
/// keep reaching everyone untouched.
class AnnouncementTargets {
  const AnnouncementTargets({
    this.platforms = const <AnnouncementPlatform>[],
    this.minAppVersion,
    this.maxAppVersion,
    this.joiningYears = const <String>[],
    this.branches = const <String>[],
  });

  /// Empty means every platform.
  final List<AnnouncementPlatform> platforms;

  /// Inclusive bounds: `maxAppVersion: "2.3.3"` still reaches 2.3.3.
  final SemanticVersion? minAppVersion;
  final SemanticVersion? maxAppVersion;

  /// Four-digit joining years, e.g. `2023`. Empty means every year.
  final List<String> joiningYears;

  /// Branch codes, e.g. `BCE`. Empty means every branch.
  final List<String> branches;

  /// Parses a `targets` block, or returns `null` when the block is present but
  /// unusable.
  ///
  /// A `null` here means **skip the announcement**, not "show it to everyone" —
  /// a mis-targeted announcement (a Play Store link on an iPhone) is worse than
  /// a missing one, and a missing one is the kind of mistake you notice.
  static AnnouncementTargets? tryParse(Map<String, dynamic> json) {
    final List<AnnouncementPlatform>? platforms = _parsePlatforms(
      json['platforms'],
    );
    if (platforms == null) return null;

    final SemanticVersion? minVersion = _parseBound(json['minAppVersion']);
    if (minVersion == _invalidVersion) return null;
    final SemanticVersion? maxVersion = _parseBound(json['maxAppVersion']);
    if (maxVersion == _invalidVersion) return null;

    final List<String>? years = _parseStrings(json['joiningYears']);
    if (years == null) return null;
    final List<String>? branches = _parseStrings(json['branches']);
    if (branches == null) return null;

    return AnnouncementTargets(
      platforms: platforms,
      minAppVersion: minVersion,
      maxAppVersion: maxVersion,
      joiningYears: years,
      branches: branches.map((String b) => b.toUpperCase()).toList(),
    );
  }

  /// Sentinel distinguishing "absent" (null, fine) from "present but junk".
  static const SemanticVersion _invalidVersion = SemanticVersion(-1, -1, -1);

  static SemanticVersion? _parseBound(Object? value) {
    if (value == null) return null;
    if (value is! String) return _invalidVersion;
    return SemanticVersion.tryParse(value) ?? _invalidVersion;
  }

  static List<AnnouncementPlatform>? _parsePlatforms(Object? value) {
    if (value == null) return const <AnnouncementPlatform>[];
    if (value is! List) return null;
    final List<AnnouncementPlatform> parsed = <AnnouncementPlatform>[];
    for (final Object? entry in value) {
      final AnnouncementPlatform? platform = AnnouncementPlatform.tryParse(
        entry,
      );
      if (platform == null) return null;
      parsed.add(platform);
    }
    return parsed;
  }

  static List<String>? _parseStrings(Object? value) {
    if (value == null) return const <String>[];
    if (value is! List) return null;
    final List<String> parsed = <String>[];
    for (final Object? entry in value) {
      if (entry is! String || entry.trim().isEmpty) return null;
      parsed.add(entry.trim());
    }
    return parsed;
  }
}

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.importance,
    required this.isActive,
    required this.dismissible,
    this.createdAt,
    this.startsAt,
    this.expiresAt,
    this.actionUrl,
    this.actionText,
    this.targets = const AnnouncementTargets(),
  });

  final String id;
  final String title;
  final String message;
  final AnnouncementType type;
  final AnnouncementImportance importance;
  final bool isActive;

  /// Whether a student may swipe this away. Default `true`; reserve `false` for
  /// something genuinely unavoidable, since an undismissable card sits on the
  /// home screen until it expires.
  final bool dismissible;

  final DateTime? createdAt;

  /// When the announcement starts showing. Null means immediately.
  ///
  /// Without this you could only control when something *stopped*, so
  /// scheduling meant pushing a commit at the exact minute.
  final DateTime? startsAt;

  /// Null means it never expires on its own.
  final DateTime? expiresAt;

  final String? actionUrl;
  final String? actionText;
  final AnnouncementTargets targets;

  bool get hasAction =>
      (actionUrl ?? '').trim().isNotEmpty &&
      (actionText ?? '').trim().isNotEmpty;

  /// Reads one entry, or returns `null` when it cannot be trusted.
  ///
  /// Returning null skips this announcement and leaves the rest of the feed
  /// intact — the old behaviour let one bad row blank the whole thing.
  static Announcement? tryParse(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;

    final String id = _string(raw['id']) ?? '';
    final String title = _string(raw['title']) ?? '';
    final String message = _string(raw['message']) ?? '';
    // Without these three there is nothing to show and nothing to dismiss.
    if (id.isEmpty || title.isEmpty || message.isEmpty) return null;

    final Object? rawTargets = raw['targets'];
    AnnouncementTargets targets = const AnnouncementTargets();
    if (rawTargets != null) {
      if (rawTargets is! Map<String, dynamic>) return null;
      final AnnouncementTargets? parsed = AnnouncementTargets.tryParse(
        rawTargets,
      );
      if (parsed == null) return null;
      targets = parsed;
    }

    return Announcement(
      id: id,
      title: title,
      message: message,
      type: AnnouncementType.parse(raw['type']),
      importance: AnnouncementImportance.parse(raw['importance']),
      isActive: raw['isActive'] is bool ? raw['isActive'] as bool : true,
      dismissible: raw['dismissible'] is bool
          ? raw['dismissible'] as bool
          : true,
      createdAt: parseIsoDate(raw['createdAt']),
      startsAt: parseIsoDate(raw['startsAt']),
      expiresAt: parseIsoDate(raw['expiresAt']),
      actionUrl: _string(raw['actionUrl']),
      actionText: _string(raw['actionText']),
      targets: targets,
    );
  }

  static String? _string(Object? value) {
    if (value is! String) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Parses an ISO 8601 timestamp, or `null`.
///
/// The old code called `DateTime.parse` unguarded in three places — twice in
/// the repository, where the failure was swallowed and silently emptied the
/// feed, and once inside `build`, where it threw a red screen onto the home
/// page.
DateTime? parseIsoDate(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value.trim())?.toLocal();
}

/// The parsed feed.
class AnnouncementResponse {
  const AnnouncementResponse({required this.announcements});

  final List<Announcement> announcements;

  /// `metadata` and `version` are deliberately not modelled: they were required
  /// fields that nothing read, so omitting the block from the JSON failed the
  /// whole parse and blanked the feature.
  static AnnouncementResponse parse(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return const AnnouncementResponse(announcements: <Announcement>[]);
    }
    final Object? list = raw['announcements'];
    if (list is! List) {
      return const AnnouncementResponse(announcements: <Announcement>[]);
    }
    return AnnouncementResponse(
      announcements: list
          .map(Announcement.tryParse)
          .whereType<Announcement>()
          .toList(),
    );
  }
}
