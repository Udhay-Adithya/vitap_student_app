import 'package:shared_preferences/shared_preferences.dart';

/// How much good use someone has got out of the app.
///
/// Shared by the review prompt and the support card so both are gated on the
/// same evidence — a success recorded once counts for both, and neither has to
/// invent its own idea of an engaged user.
class EngagementStore {
  const EngagementStore();

  static const String _countKey = 'review_happy_moment_count';
  static const String _firstSeenKey = 'review_first_happy_moment_at';
  static const String _reviewPromptedKey = 'review_last_prompted_at';
  static const String _supportDismissedKey = 'support_card_dismissed_at';

  /// Records a success and returns the running total.
  Future<int> recordHappyMoment() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int total = (prefs.getInt(_countKey) ?? 0) + 1;
    await prefs.setInt(_countKey, total);

    // Stamped on the first success rather than at install: that is the first
    // moment we know someone is actually using the app rather than that it
    // happens to be on their phone.
    if (prefs.getString(_firstSeenKey) == null) {
      await prefs.setString(_firstSeenKey, DateTime.now().toIso8601String());
    }
    return total;
  }

  Future<EngagementSnapshot> read() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return EngagementSnapshot(
      happyMoments: prefs.getInt(_countKey) ?? 0,
      firstSeenAt: _date(prefs.getString(_firstSeenKey)),
      reviewPromptedAt: _date(prefs.getString(_reviewPromptedKey)),
      supportDismissedAt: _date(prefs.getString(_supportDismissedKey)),
    );
  }

  Future<void> markReviewPrompted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reviewPromptedKey, DateTime.now().toIso8601String());
  }

  Future<void> markSupportCardDismissed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _supportDismissedKey,
      DateTime.now().toIso8601String(),
    );
  }

  static DateTime? _date(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw);
}

class EngagementSnapshot {
  const EngagementSnapshot({
    required this.happyMoments,
    required this.firstSeenAt,
    required this.reviewPromptedAt,
    required this.supportDismissedAt,
  });

  final int happyMoments;
  final DateTime? firstSeenAt;
  final DateTime? reviewPromptedAt;
  final DateTime? supportDismissedAt;
}
