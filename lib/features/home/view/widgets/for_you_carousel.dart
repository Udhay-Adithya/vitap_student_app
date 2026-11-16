import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/common/widget/section_header.dart';
import 'package:vit_ap_student_app/features/home/model/for_you_item.dart';
import 'package:vit_ap_student_app/features/home/view/pages/tile_detail_page.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/for_you_card.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/for_you_viewmodel.dart';

class ForYouCarousel extends ConsumerWidget {
  const ForYouCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredItems = ref.watch(featuredItemsProvider);
    final itemsAsync = ref.watch(forYouViewModelProvider);
    final likedItems = ref.watch(likedItemsSessionProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemsAsync.when(
          data: (_) => featuredItems.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SectionHeader.gutter,
                  ),
                  child: _buildEmptyState(context),
                )
              // A horizontal ListView hands its children a tight cross-axis
              // constraint, so it needs an outer height and every card was
              // stretched to that guess — leaving dead space under the last
              // line on any screen where the content came out shorter. A Row
              // inside a horizontal scroll view takes its height from the
              // cards instead, so there is no number to keep in sync. Featured
              // is capped at a handful of items, so losing lazy building costs
              // nothing.
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  // The scroll view owns the gutter so the first card lines up
                  // with the "For You" heading while the rest still scroll off
                  // the edge.
                  padding: const EdgeInsets.symmetric(
                    horizontal: SectionHeader.gutter,
                  ),
                  child: Row(
                    children: [
                      for (final (index, item) in featuredItems.indexed) ...[
                        if (index > 0) const SizedBox(width: 12),
                        ForYouCard(
                          item: item,
                          isLiked: likedItems.contains(item.id),
                          showLikes: false,
                          onTap: () => _navigateToDetail(context, item),
                          onLike: () => ref
                              .read(forYouViewModelProvider.notifier)
                              .likeItem(item.id),
                        ),
                      ],
                    ],
                  ),
                ),
          loading: () => const SizedBox(
            height: 260,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => _buildErrorState(context, ref, error.toString()),
        ),
      ],
    );
  }

  void _navigateToDetail(BuildContext context, ForYouItem item) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => TileDetailPage(item: item)),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.box_1,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No featured tools yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load tools',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () {
                ref.read(forYouViewModelProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
