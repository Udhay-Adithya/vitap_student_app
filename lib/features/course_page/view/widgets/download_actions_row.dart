import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Course-level actions: the syllabus, and every material as one ZIP.
///
/// The syllabus can be viewed or downloaded. "Download All" is a ZIP archive,
/// so there is nothing to view — it only saves.
///
/// Each button carries its own busy state so the one that was tapped is the one
/// that spins, and the rest go quiet until it finishes.
class DownloadActionsRow extends StatelessWidget {
  final VoidCallback? onViewSyllabus;
  final VoidCallback? onDownloadSyllabus;
  final VoidCallback? onDownloadAll;

  final bool viewSyllabusBusy;
  final bool downloadSyllabusBusy;
  final bool downloadAllBusy;

  /// False while any download on the page is in flight.
  final bool enabled;

  const DownloadActionsRow({
    super.key,
    this.onViewSyllabus,
    this.onDownloadSyllabus,
    this.onDownloadAll,
    this.viewSyllabusBusy = false,
    this.downloadSyllabusBusy = false,
    this.downloadAllBusy = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasSyllabus = onViewSyllabus != null || onDownloadSyllabus != null;

    return Column(
      children: [
        if (hasSyllabus)
          Row(
            children: [
              if (onViewSyllabus != null)
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Iconsax.eye,
                    label: 'View Syllabus',
                    onTap: onViewSyllabus!,
                    color: colors.secondary,
                    busy: viewSyllabusBusy,
                  ),
                ),
              if (onViewSyllabus != null && onDownloadSyllabus != null)
                const SizedBox(width: 12),
              if (onDownloadSyllabus != null)
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Iconsax.document_download,
                    label: 'Syllabus',
                    onTap: onDownloadSyllabus!,
                    color: colors.secondary,
                    busy: downloadSyllabusBusy,
                  ),
                ),
            ],
          ),
        if (hasSyllabus && onDownloadAll != null) const SizedBox(height: 12),
        if (onDownloadAll != null)
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              context,
              icon: Iconsax.folder_2,
              label: 'Download All',
              onTap: onDownloadAll!,
              color: colors.primary,
              busy: downloadAllBusy,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required bool busy,
  }) {
    return OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: busy
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
