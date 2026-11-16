import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/utils/format_to_12_hour.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/upcoming_classes/class_occurrence.dart';

/// A class in the stack that isn't the open one.
///
/// The time leads at a fixed width so a run of strips scans as a single column
/// of times, which is what you actually look for when checking the rest of a day.
/// Strips stay on [ColorScheme.surfaceContainer] rather than taking a colour per
/// course — a row of saturated strips would be noise, and the open card is meant
/// to be the only tinted thing in the section.
class CollapsedClassStrip extends StatelessWidget {
  const CollapsedClassStrip({
    super.key,
    required this.occurrence,
    required this.now,
    required this.onTap,
    this.dimmed = false,
  });

  final ClassOccurrence occurrence;
  final DateTime now;
  final VoidCallback onTap;

  /// Completed classes render muted inside the "done earlier" group.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final ClassPhase phase = occurrence.phaseAt(now);
    final bool isOngoing = phase == ClassPhase.ongoing;
    final bool isCompleted = phase == ClassPhase.completed;
    final String venue = (occurrence.info.venue ?? '').trim();

    final Widget strip = Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            horizontalTitleGap: 8,
            minLeadingWidth: 72,
            leading: SizedBox(
              width: 72,
              child: Text(
                formatTo12Hour(occurrence.info.startTime),
                style: tt.labelLarge?.copyWith(
                  color: isOngoing ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            title: Text(
              occurrence.info.courseName ?? 'Class',
              style: tt.bodyMedium?.copyWith(
                color: dimmed ? cs.onSurfaceVariant : cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  )
                : venue.isEmpty
                ? null
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 96),
                    child: Text(
                      venue,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
          ),
          // A collapsed class that is still running keeps its progress line, so
          // opening another card never costs you the "happening now" signal.
          if (isOngoing)
            LinearProgressIndicator(
              value: occurrence.progressAt(now),
              minHeight: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
        ],
      ),
    );

    return dimmed ? Opacity(opacity: 0.62, child: strip) : strip;
  }
}
