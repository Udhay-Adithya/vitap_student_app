import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/common/widget/styled_sheet.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/launch_web.dart';
import 'package:vit_ap_student_app/features/home/model/for_you_item.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/for_you_meta.dart';

class TileDetailPage extends ConsumerStatefulWidget {
  /// Takes the whole item rather than four loose strings, so a new field on
  /// [ForYouItem] doesn't need a new constructor argument threaded through
  /// every caller.
  final ForYouItem item;

  const TileDetailPage({super.key, required this.item});

  @override
  ConsumerState<TileDetailPage> createState() => _TileDetailPageState();
}

class _TileDetailPageState extends ConsumerState<TileDetailPage> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logScreen('TileDetailPage');
  }

  /// Community tools are submitted by students and run by them, not by this
  /// app. Naming the host and saying so before leaving is the honest version of
  /// a link the user has no other way to inspect.
  Future<void> _openLink(ForYouItem item) async {
    final host = Uri.tryParse(item.url)?.host;

    final confirmed = await StyledSheet.show(
      context,
      icon: Icons.open_in_new_rounded,
      title: 'Leaving the app',
      message:
          'This opens ${host == null || host.isEmpty ? 'an external site' : host} '
          'in your browser. It is run by whoever submitted it, not by this app, '
          'so we cannot vouch for its content or for what it does with anything '
          'you enter there.',
      confirmLabel: 'Continue',
    );

    if (!confirmed || !mounted) return;

    // Read before the launch: the page can be closed while the browser opens.
    final analytics = ref.read(analyticsServiceProvider);
    await directToWeb(item.url);
    analytics.logEvent(AnalyticsEvents.tileDetailLinkOpened, {
      AnalyticsParams.target: item.title,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final item = widget.item;
    final requirement = item.requirement;
    final note = item.note;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'by ${item.author}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ForYouTypeChip(type: item.type),
                if (item.verified) ...[
                  const SizedBox(width: 8),
                  Icon(Iconsax.verify, size: 14, color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ],
            ),

            if (requirement != null) ...[
              const SizedBox(height: 16),
              ForYouRequirementCallout(requirement: requirement),
            ],
            if (note != null && note.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              ForYouNoteCallout(note: note.trim()),
            ],
            const SizedBox(height: 16),
            Text(item.description, style: const TextStyle(fontSize: 16)),
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in item.tags)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _openLink(item),
                label: const Text('Visit Now'),
                iconAlignment: IconAlignment.start,
                icon: const Icon(Iconsax.export_3_copy, size: 16),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: colors.secondaryContainer,
                  minimumSize: Size(MediaQuery.sizeOf(context).width - 150, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
