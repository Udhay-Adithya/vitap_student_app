/// Deciding which announcements a given student should actually see.
library;

import 'package:vit_ap_student_app/core/utils/semantic_version.dart';
import 'package:vit_ap_student_app/features/home/model/announcement.dart';

/// Everything about the current install that an announcement can target.
class AnnouncementAudience {
  const AnnouncementAudience({
    required this.platform,
    this.appVersion,
    this.joiningYear,
    this.branch,
  });

  final AnnouncementPlatform platform;
  final SemanticVersion? appVersion;

  /// Four-digit joining year and branch code, as derived from the registration
  /// number — the same buckets analytics already computes.
  final String? joiningYear;
  final String? branch;
}

/// Whether [announcement] is meant for [audience].
///
/// An absent target is no restriction, so announcements written before
/// targeting existed reach everyone unchanged.
bool matchesAudience(Announcement announcement, AnnouncementAudience audience) {
  final AnnouncementTargets targets = announcement.targets;

  if (targets.platforms.isNotEmpty &&
      !targets.platforms.contains(audience.platform)) {
    return false;
  }

  final SemanticVersion? version = audience.appVersion;
  if (targets.minAppVersion != null || targets.maxAppVersion != null) {
    // A version-gated announcement with no readable version to compare against
    // is exactly the case the gate exists to prevent, so hold it back.
    if (version == null) return false;
    if (targets.minAppVersion != null && version < targets.minAppVersion!) {
      return false;
    }
    if (targets.maxAppVersion != null && version > targets.maxAppVersion!) {
      return false;
    }
  }

  if (targets.joiningYears.isNotEmpty &&
      (audience.joiningYear == null ||
          !targets.joiningYears.contains(audience.joiningYear))) {
    return false;
  }

  if (targets.branches.isNotEmpty &&
      (audience.branch == null ||
          !targets.branches.contains(audience.branch!.toUpperCase()))) {
    return false;
  }

  return true;
}

/// Whether [announcement] is live at [now] — switched on, started, not expired.
bool isWithinSchedule(Announcement announcement, {DateTime? now}) {
  if (!announcement.isActive) return false;
  final DateTime moment = now ?? DateTime.now();

  final DateTime? startsAt = announcement.startsAt;
  if (startsAt != null && moment.isBefore(startsAt)) return false;

  final DateTime? expiresAt = announcement.expiresAt;
  if (expiresAt != null && !moment.isBefore(expiresAt)) return false;

  return true;
}

/// The feed as it should be shown: live, targeted, undismissed, most important
/// first, newest first within a level.
List<Announcement> visibleAnnouncements(
  List<Announcement> announcements, {
  required AnnouncementAudience audience,
  Set<String> dismissedIds = const <String>{},
  DateTime? now,
}) {
  final List<Announcement> visible = announcements
      .where(
        (Announcement a) =>
            isWithinSchedule(a, now: now) &&
            matchesAudience(a, audience) &&
            !(a.dismissible && dismissedIds.contains(a.id)),
      )
      .toList();

  visible.sort((Announcement a, Announcement b) {
    final int byImportance = b.importance.rank.compareTo(a.importance.rank);
    if (byImportance != 0) return byImportance;

    // Undated entries sort last rather than winning the comparison by accident.
    final DateTime? left = a.createdAt;
    final DateTime? right = b.createdAt;
    if (left == null && right == null) return 0;
    if (left == null) return 1;
    if (right == null) return -1;
    return right.compareTo(left);
  });

  return visible;
}

/// Dismissed ids worth keeping.
///
/// Anything no longer in the feed is dropped, so the stored set cannot grow
/// without bound as announcements come and go.
Set<String> prunedDismissedIds(
  Set<String> dismissedIds,
  List<Announcement> announcements,
) {
  final Set<String> known = announcements.map((Announcement a) => a.id).toSet();
  return dismissedIds.where(known.contains).toSet();
}
