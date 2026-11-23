import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/remote_link.dart';
import 'package:vit_ap_student_app/features/account/viewmodel/github_viewmodel.dart';

class ChangelogPage extends ConsumerStatefulWidget {
  const ChangelogPage({super.key});

  @override
  ConsumerState<ChangelogPage> createState() => _ChangelogPageState();
}

class _ChangelogPageState extends ConsumerState<ChangelogPage> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logScreen('ChangelogPage');
    Future.microtask(
      () => ref.read(changelogViewModelProvider.notifier).fetchChangelog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final changelogState = ref.watch(changelogViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Changelog',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: _buildBody(changelogState),
    );
  }

  Widget _buildBody(AsyncValue<String>? changelogState) {
    if (changelogState == null || changelogState is AsyncLoading) {
      return const Center(child: Loader());
    }

    if (changelogState is AsyncError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load changelog',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () {
                  ref
                      .read(changelogViewModelProvider.notifier)
                      .fetchChangelog();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final markdown = changelogState.value!;

    return Markdown(
      data: markdown,
      selectable: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      styleSheet: MarkdownStyleSheet(
        blockSpacing: 12,
        h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        h2: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
        h3: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        p: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        listBullet: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        a: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null) openRemoteLink(href);
      },
    );
  }
}
