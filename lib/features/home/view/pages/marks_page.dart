import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vit_ap_student_app/core/common/widget/empty_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/error_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/home/view/pages/mark_detail_page.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/marks_viewmodel.dart';

class MarksPage extends ConsumerStatefulWidget {
  const MarksPage({super.key});

  @override
  ConsumerState<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends ConsumerState<MarksPage> {
  DateTime? lastSynced;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logScreen('MarksPage');
    loadLastSynced();
  }

  Future<void> loadLastSynced() async {
    final prefs = ref.read(userPreferencesProvider);
    final DateTime? lastSyncedString = prefs.marksLastSync;
    if (lastSyncedString != null) {
      setState(() {
        lastSynced = lastSyncedString;
      });
    }
  }

  Future<void> saveLastSynced() async {
    final prefs = ref.read(userPreferencesProvider);
    await ref
        .read(userPreferencesProvider.notifier)
        .updatePreferences(prefs.copyWith(marksLastSync: lastSynced!));
  }

  Future<void> refreshMarksData() async {
    await ref.read(marksViewModelProvider.notifier).refreshMarks();
    ref.read(analyticsServiceProvider).logEvent(AnalyticsEvents.refreshInitiated,
        {AnalyticsParams.dataType: 'marks'});

    final state = ref.read(marksViewModelProvider);
    if (state != null && !state.hasError) {
      lastSynced = DateTime.now();
      await saveLastSynced();
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = ref.watch(currentUserProvider);
    final isLoading = ref.watch(
      marksViewModelProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(marksViewModelProvider, (_, next) {
      next?.when(
        data: (data) {},
        loading: () {},
        error: (error, st) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Marks',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            if (lastSynced != null)
              Text(
                'Last Synced: ${timeago.format(lastSynced!)} 💾',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.refresh_copy,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: refreshMarksData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : RefreshIndicator(
        onRefresh: refreshMarksData,
        child: _buildBody(user),
      ),
    );
  }

  Widget _buildBody(User? user) {
    if (user == null) {
      return const ErrorContentView(error: 'User not found!');
    }

    // Call the static helper method from the ViewModel
    final groupedMarksLists = MarksViewModel.groupMarks(user.marks.toList());

    if (groupedMarksLists.isEmpty) {
      return const EmptyContentView(
        primaryText: 'No Courses found',
        secondaryText: 'Keep calm and come back later! 🕒😌',
      );
    }

    return ListView.builder(
      itemCount: groupedMarksLists.length,
      itemBuilder: (context, index) {
        final components = groupedMarksLists[index];
        final primary = components.firstWhere((c) => c.grade != null, orElse: () => components.first);

        final combinedType = components
            .map((c) => c.courseType.replaceAll('Embedded ', '').replaceAll('Regular ', ''))
            .join(' + ');

        double totalWeightage = 0;
        double maxWeightage = 0;
        for (var comp in components) {
          final hasReEval = comp.details.any(
                (d) => d.markTitle.trim().toLowerCase().contains('re evaluation fat'),
          );

          for (var detail in comp.details) {
            final title = detail.markTitle.trim().toLowerCase();
            if (hasReEval && title == 'fat') continue;

            totalWeightage += double.tryParse(detail.weightageMark) ?? 0;
            maxWeightage += double.tryParse(detail.weightage) ?? 0;
          }
        }

        String displayGained = totalWeightage.toStringAsFixed(1);
        String displayMax = maxWeightage.toStringAsFixed(0);

        if (primary.grade != null && primary.grandTotal != null && primary.grandTotal!.trim().isNotEmpty) {
          displayGained = primary.grandTotal!.trim();
          displayMax = '100';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  primary.courseTitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${primary.courseCode} · $combinedType',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: displayGained,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' / $displayMax',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: primary.grade != null && primary.grade!.isNotEmpty
                ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                primary.grade!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MarkDetailPage(components: components),
                ),
              );
            },
          ),
        );
      },
    );
  }
}