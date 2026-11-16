import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/common/widget/section_header.dart';
import 'package:vit_ap_student_app/features/home/model/for_you_item.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/for_you_meta.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/for_you_viewmodel.dart';

/// Width of a For You card for the current screen.
///
/// Lives outside the widget so the carousel and the View All grid lay out on
/// the same numbers. Two columns up to 540 logical pixels, three above it, with
/// [SectionHeader.gutter] on each outer edge and 12 between columns.
double forYouCardWidth(BuildContext context) {
  final available =
      MediaQuery.sizeOf(context).width - (SectionHeader.gutter * 2);
  final width = available < 540 ? (available - 12) / 2 : (available - 24) / 3;
  return width.clamp(150.0, 220.0);
}

const double _descriptionLineFactor = 1.4;
const double _descriptionLineHeight = 12 * _descriptionLineFactor;

class ForYouCard extends StatelessWidget {
  final ForYouItem item;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final bool showLikes;

  const ForYouCard({
    super.key,
    required this.item,
    required this.isLiked,
    required this.onTap,
    required this.onLike,
    this.showLikes = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final requirement = item.requirement;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: forYouCardWidth(context),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colors.surfaceContainerLow,
        ),
        // Sizes to its content. The carousel used to force a fixed height onto
        // this column, which left a strip of dead space under the last line on
        // every screen narrower than the guess.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: _ForYouCardImage(imageUrl: item.imageUrl),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // The chip and the badge share one flex child rather than each
                // being flexible next to a Spacer. Two flex children of equal
                // weight split the free space evenly, so the chip was capped at
                // half the row however little the label needed — fine for
                // "Tools", a clean cut through "Academics" and "Placement".
                Expanded(
                  child: Row(
                    children: [
                      Flexible(child: ForYouTypeChip(type: item.type)),
                      if (requirement != null) ...[
                        const SizedBox(width: 4),
                        ForYouRequirementBadge(requirement: requirement),
                      ],
                    ],
                  ),
                ),
                if (showLikes)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onLike,
                        child: Icon(
                          isLiked ? Iconsax.heart : Iconsax.heart_copy,
                          size: 18,
                          color: isLiked ? colors.primary : colors.outline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatLikesCount(item.likes),
                        style: TextStyle(fontSize: 12, color: colors.outline),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Flexible(
                  child: Text(
                    'by ${item.author}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (item.verified) ...[
                  const SizedBox(width: 4),
                  Icon(Iconsax.verify, size: 12, color: colors.primary),
                ],
              ],
            ),
            const SizedBox(height: 6),
            // Fixed two-line box rather than `maxLines: 2` alone: a one-line
            // description would otherwise make that card shorter than its
            // neighbours, and both the carousel row and the View All grid want
            // cards of a single height.
            SizedBox(
              height: _descriptionLineHeight * 2,
              child: Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  height: _descriptionLineFactor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Know more',
              style: TextStyle(fontSize: 13, color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thumbnail with a neutral placeholder. Cached to disk: without it every cold
/// start re-downloads every image, which is a large share of the feed's egress.
class _ForYouCardImage extends StatelessWidget {
  const _ForYouCardImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final url = imageUrl;

    Widget fallback() => ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(Iconsax.image, size: 40, color: colors.outlineVariant),
      ),
    );

    if (url == null || url.isEmpty) return fallback();

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (context, _) =>
          ColoredBox(color: colors.surfaceContainerHighest),
      errorWidget: (context, _, _) => fallback(),
    );
  }
}
