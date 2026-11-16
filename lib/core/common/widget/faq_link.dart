import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/account/model/faq_content.dart';
import 'package:vit_ap_student_app/features/account/view/pages/faq_page.dart';

/// A short explanation with a way through to the full answer.
///
/// Exists because the FAQ was never the problem — findability was a symptom.
/// People form a theory at the moment something surprises them ("why is this
/// app demanding an OTP like a bank?") and act on that theory; they do not go
/// looking for a reference page. So the answer has to be at the point of
/// friction, with the depth one tap away.
class FaqLink extends ConsumerWidget {
  const FaqLink({
    super.key,
    required this.topic,
    required this.text,
    this.linkText = 'Learn more',
    this.icon = Icons.info_outline_rounded,
  });

  /// Which answer to open.
  final FaqTopic topic;

  /// The short version, shown inline. This is what most people will read, so it
  /// should stand on its own without the tap.
  final String text;

  final String linkText;
  final IconData? icon;

  void _open(BuildContext context, WidgetRef ref) {
    ref.read(analyticsServiceProvider).logEvent(
      AnalyticsEvents.faqTopicOpened,
      <String, Object?>{AnalyticsParams.topic: topic.name},
    );
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => FAQPage(topic: topic)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _open(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      linkText,
                      style: tt.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: cs.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
