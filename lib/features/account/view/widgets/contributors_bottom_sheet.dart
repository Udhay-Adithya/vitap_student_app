import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/models/contributor.dart';
import 'package:vit_ap_student_app/core/utils/launch_web.dart';
import 'package:vit_ap_student_app/features/account/viewmodel/github_viewmodel.dart';

class ContributorsBottomSheet extends ConsumerWidget {
  const ContributorsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributorsState = ref.watch(contributorsViewModelProvider);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width),
            Text(
              'Contributors',
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Thanks to everyone who contributed!',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(indent: 40, endIndent: 40),
            const SizedBox(height: 16),
            Flexible(child: _buildContent(context, ref, contributorsState)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Contributor>> contributorsState,
  ) {
    if (contributorsState is AsyncLoading) {
      return const SizedBox(height: 150, child: Center(child: Loader()));
    }

    if (contributorsState is AsyncError) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load contributors',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final contributors = contributorsState.value!;

    if (contributors.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No additional contributors yet',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 24,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: contributors.map((contributor) {
            return _buildContributorTile(context, contributor);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContributorTile(BuildContext context, Contributor contributor) {
    return GestureDetector(
      onTap: () => directToWeb(contributor.htmlUrl),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                '${contributor.avatarUrl}&size=120',
              ),
              onBackgroundImageError: (_, __) {},
              child: null,
            ),
            const SizedBox(height: 6),
            Text(
              contributor.login,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
