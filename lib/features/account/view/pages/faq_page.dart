import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/account/model/faq_content.dart';

/// The FAQ, optionally opened straight at one answer.
///
/// [topic] is a stable key rather than a list index: contextual links live all
/// over the app now, and a positional link would silently point at the wrong
/// answer as soon as a question was inserted above it.
class FAQPage extends ConsumerStatefulWidget {
  const FAQPage({super.key, this.topic});

  final FaqTopic? topic;

  @override
  ConsumerState<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends ConsumerState<FAQPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<FaqTopic, GlobalKey> _itemKeys = <FaqTopic, GlobalKey>{
    for (final FaqEntry entry in faqEntries) entry.topic: GlobalKey(),
  };

  late final Set<FaqTopic> _expanded = <FaqTopic>{
    if (widget.topic != null) widget.topic!,
  };

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logScreen('FAQPage');

    // Expanding an entry that sits below the fold looks like nothing happened,
    // so bring it into view once the list has been laid out.
    final FaqTopic? topic = widget.topic;
    if (topic != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollTo(topic));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(FaqTopic topic) {
    final BuildContext? itemContext = _itemKeys[topic]?.currentContext;
    if (itemContext == null) return;
    Scrollable.ensureVisible(
      itemContext,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      alignment: 0.1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQs',
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: faqEntries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          final FaqEntry entry = faqEntries[index];
          final bool isOpen = _expanded.contains(entry.topic);

          return Container(
            key: _itemKeys[entry.topic],
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              initiallyExpanded: isOpen,
              shape: const Border(),
              collapsedShape: const Border(),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              onExpansionChanged: (bool open) => setState(
                () => open
                    ? _expanded.add(entry.topic)
                    : _expanded.remove(entry.topic),
              ),
              title: Text(
                entry.question,
                style: tt.titleSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: <Widget>[
                Text(
                  entry.answer,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
