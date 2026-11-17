import 'package:flutter/material.dart';
import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/services/engagement_store.dart';
import 'package:vit_ap_student_app/core/services/support_prompt_policy.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/support_developer_sheet.dart';

/// A quiet, earned request for support on the home page.
///
/// Appears only once someone has had real use out of the app, and disappears
/// for months once dismissed — the opposite of an ambient banner. Scattering
/// dismissible cards teaches people to dismiss without reading, which would
/// cost the announcement cards that sit in this same column.
class SupportPromptCard extends ConsumerStatefulWidget {
  const SupportPromptCard({super.key});

  @override
  ConsumerState<SupportPromptCard> createState() => _SupportPromptCardState();
}

class _SupportPromptCardState extends ConsumerState<SupportPromptCard> {
  static const EngagementStore _store = EngagementStore();

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final EngagementSnapshot snapshot = await _store.read();
    if (!mounted) return;
    setState(() {
      _visible = shouldShowSupportCard(
        happyMoments: snapshot.happyMoments,
        firstSeenAt: snapshot.firstSeenAt,
        dismissedAt: snapshot.supportDismissedAt,
        now: DateTime.now(),
        isDemoMode: ref.read(demoModeProvider),
      );
    });
  }

  Future<void> _dismiss() async {
    setState(() => _visible = false);
    await _store.markSupportCardDismissed();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showSupportDeveloperSheet(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                M3EContainer.pill(
                  height: 62,
                  width: 62,
                  color: Colors.blueAccent,
                  child: Icon(
                    Iconsax.heart,
                    color: Colors.redAccent.shade200,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enjoying the app?',
                            style: tt.titleSmall?.copyWith(
                              color: cs.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: _dismiss,
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: cs.onSecondaryContainer.withValues(
                              alpha: 0.8,
                            ),
                            tooltip: 'Dismiss',
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      Text(
                        'It is built by a student in his own time, free and '
                        'without ads. Starring it on GitHub helps, and so does '
                        'a coffee.',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSecondaryContainer.withValues(
                            alpha: 0.82,
                          ),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
