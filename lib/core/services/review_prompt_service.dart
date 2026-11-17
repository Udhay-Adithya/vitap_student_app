import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/services/engagement_store.dart';
import 'package:vit_ap_student_app/core/services/review_prompt_policy.dart';

part 'review_prompt_service.g.dart';

@riverpod
ReviewPromptService reviewPromptService(Ref ref) => ReviewPromptService(
  ref.watch(analyticsServiceProvider),
  isDemoMode: ref.watch(demoModeProvider),
);

/// Asks for a store rating after something has just gone right.
///
/// Call [recordHappyMoment] at the end of a task that **finished** — an outing
/// applied, an assignment uploaded. Deliberately not after a refresh: people
/// refresh in order to read the result, so a sheet lands on top of the very
/// thing they asked for.
///
/// The rating sheet is drawn by the OS (Play In-App Review on Android, StoreKit
/// on iOS) and both platforms enforce their own quotas, so a call may
/// legitimately show nothing. [reviewPromptCooldown] is what stops the app
/// retrying a silently-ignored prompt forever.
class ReviewPromptService {
  const ReviewPromptService(this._analytics, {required bool isDemoMode})
    : _isDemoMode = isDemoMode;

  final AnalyticsService _analytics;
  final bool _isDemoMode;

  static const EngagementStore _store = EngagementStore();

  /// Records a success and asks for a review if the moment is right.
  ///
  /// Fire and forget: this must never delay or interrupt the flow that called
  /// it, and a failure here is never worth surfacing.
  Future<void> recordHappyMoment(String source) async {
    try {
      final int happyMoments = await _store.recordHappyMoment();
      final EngagementSnapshot snapshot = await _store.read();

      if (!shouldRequestReview(
        happyMoments: happyMoments,
        firstSeenAt: snapshot.firstSeenAt,
        lastPromptedAt: snapshot.reviewPromptedAt,
        now: DateTime.now(),
        isDemoMode: _isDemoMode,
      )) {
        return;
      }

      final InAppReview review = InAppReview.instance;
      if (!await review.isAvailable()) return;

      await _store.markReviewPrompted();
      await review.requestReview();

      // Records that we asked, not that anyone rated — neither store tells us
      // the outcome, by design.
      _analytics.logEvent(AnalyticsEvents.reviewPromptShown, <String, Object?>{
        AnalyticsParams.source: source,
      });
    } catch (e) {
      debugPrint('Review prompt skipped: $e');
    }
  }
}
