import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vit_ap_student_app/core/utils/remote_link.dart';
import 'package:vit_ap_student_app/features/home/model/announcement.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/announcement_detail_sheet.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/announcement_viewmodel.dart';

/// Announcements on the home page, one card each.
///
/// They used to share a single box with hairline dividers, so a campus
/// emergency and a tech-fest advert sat at identical weight, separated only by
/// the tint of a 16pt icon. Importance now drives the card itself.
class AnnouncementContainer extends ConsumerWidget {
  const AnnouncementContainer({super.key});

  static const int _maxVisible = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Announcement>>? announcements = ref.watch(
      announcementViewModelProvider,
    );

    return announcements?.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (List<Announcement> all) {
            if (all.isEmpty) return const SizedBox.shrink();
            final List<Announcement> visible = all.take(_maxVisible).toList();

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final Announcement announcement in visible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AnnouncementCard(
                        key: ValueKey<String>(announcement.id),
                        announcement: announcement,
                        onDismiss: () => ref
                            .read(announcementViewModelProvider.notifier)
                            .dismiss(announcement.id),
                      ),
                    ),
                ],
              ),
            );
          },
        ) ??
        const SizedBox.shrink();
  }
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onDismiss,
  });

  final Announcement announcement;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final _CardStyle style = _CardStyle.of(context, announcement.importance);

    return Material(
      color: style.background,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // The message used to truncate at five lines with no way to read on.
        onTap: () => showAnnouncementDetailSheet(context, announcement),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(_typeIcon(announcement.type), size: 20, color: style.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      announcement.title,
                      style: tt.titleSmall?.copyWith(
                        color: style.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      announcement.message,
                      style: tt.bodySmall?.copyWith(
                        color: style.muted,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (announcement.createdAt != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        timeago.format(announcement.createdAt!),
                        style: tt.labelSmall?.copyWith(color: style.muted),
                      ),
                    ],
                    if (announcement.hasAction) ...<Widget>[
                      const SizedBox(height: 8),
                      // A real button: this was a GestureDetector around a
                      // Container about 28pt tall, well under the minimum tap
                      // target and with no press feedback at all.
                      TextButton.icon(
                        onPressed: () => _openAction(context),
                        style: TextButton.styleFrom(
                          foregroundColor: style.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(Iconsax.arrow_right_3, size: 16),
                        iconAlignment: IconAlignment.end,
                        label: Text(announcement.actionText!),
                      ),
                    ],
                  ],
                ),
              ),
              if (announcement.dismissible)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: style.muted,
                  tooltip: 'Dismiss',
                  visualDensity: VisualDensity.compact,
                )
              else
                const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAction(BuildContext context) async {
    final bool launched = await openRemoteLink(announcement.actionUrl!);
    // A bad URL in a hand-edited file used to be an invisible dead tap.
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Couldn't open that link")));
    }
  }

  static IconData _typeIcon(AnnouncementType type) => switch (type) {
    AnnouncementType.academic => Iconsax.book,
    AnnouncementType.facility => Iconsax.building,
    AnnouncementType.maintenance => Iconsax.setting_2,
    AnnouncementType.system => Iconsax.monitor,
    AnnouncementType.general => Iconsax.info_circle,
  };
}

/// Importance mapped onto the scheme.
///
/// Replaces `Colors.red/orange/blue/green`, which sat off the seeded palette in
/// light mode and glared in dark. Only `critical` gets a filled treatment — if
/// everything is loud, nothing is.
class _CardStyle {
  const _CardStyle({
    required this.background,
    required this.foreground,
    required this.muted,
    required this.accent,
  });

  final Color background;
  final Color foreground;
  final Color muted;
  final Color accent;

  factory _CardStyle.of(BuildContext context, AnnouncementImportance level) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return switch (level) {
      AnnouncementImportance.critical => _CardStyle(
        background: cs.errorContainer,
        foreground: cs.onErrorContainer,
        muted: cs.onErrorContainer.withValues(alpha: 0.78),
        accent: cs.onErrorContainer,
      ),
      AnnouncementImportance.high => _CardStyle(
        background: cs.surfaceContainerHigh,
        foreground: cs.onSurface,
        muted: cs.onSurfaceVariant,
        accent: cs.tertiary,
      ),
      AnnouncementImportance.medium || AnnouncementImportance.low => _CardStyle(
        background: cs.surfaceContainerLow,
        foreground: cs.onSurface,
        muted: cs.onSurfaceVariant,
        accent: cs.primary,
      ),
    };
  }
}
