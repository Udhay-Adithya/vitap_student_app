import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vit_ap_student_app/core/utils/remote_link.dart';
import 'package:vit_ap_student_app/features/home/model/announcement.dart';

/// The full announcement.
///
/// The card truncates its message so three announcements can share the top of
/// the home page; without somewhere to read the rest, a long announcement was a
/// dead end.
void showAnnouncementDetailSheet(
  BuildContext context,
  Announcement announcement,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (BuildContext context) =>
        _AnnouncementDetailSheet(announcement: announcement),
  );
}

class _AnnouncementDetailSheet extends StatelessWidget {
  const _AnnouncementDetailSheet({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              announcement.title,
              style: tt.headlineSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
            if (announcement.createdAt != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                timeago.format(announcement.createdAt!),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              announcement.message,
              style: tt.bodyLarge?.copyWith(color: cs.onSurface, height: 1.45),
            ),
            if (announcement.hasAction) ...<Widget>[
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => _openAction(context),
                child: Text(announcement.actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openAction(BuildContext context) async {
    final bool launched = await openRemoteLink(announcement.actionUrl!);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Couldn't open that link")));
    }
  }
}
