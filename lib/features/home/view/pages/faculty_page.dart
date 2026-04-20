import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/home/model/faculty.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/faculty/faculty_details_sheet.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/faculty/faculty_list_tile.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/faculty/faculty_search_bar.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/faculty_viewmodel.dart';

class FacultiesPage extends ConsumerStatefulWidget {
  const FacultiesPage({super.key});

  @override
  ConsumerState<FacultiesPage> createState() => _FacultiesPageState();
}

class _FacultiesPageState extends ConsumerState<FacultiesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final q = _searchController.text.toLowerCase();
      if (q != _query) {
        setState(() => _query = q);
        if (q.isNotEmpty) {
          AnalyticsService.logEvent('faculty_search', {
            'query_length': q.length,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }
    });
    AnalyticsService.logScreen('FacultiesPage');

    // Trigger fetch on first build if not already loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(facultyListViewModelProvider);
      if (state == null) {
        ref.read(facultyListViewModelProvider.notifier).fetchFacultyList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FacultyListItem> _filtered(List<FacultyListItem> all) {
    if (_query.isEmpty) return all;
    return all
        .where((f) => f.facultyName.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(facultyListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Faculties',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: switch (state) {
        null => _IdleView(
          onLoad: () => ref
              .read(facultyListViewModelProvider.notifier)
              .fetchFacultyList(),
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => _ErrorView(
          message: error.toString(),
          onRetry: () => ref
              .read(facultyListViewModelProvider.notifier)
              .fetchFacultyList(),
        ),
        AsyncData(:final value) => Column(
          children: [
            FacultySearchBar(controller: _searchController),
            Expanded(child: _FacultyList(items: _filtered(value))),
          ],
        ),
      },
    );
  }
}

class _IdleView extends StatelessWidget {
  final VoidCallback onLoad;
  const _IdleView({required this.onLoad});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Tap to load the faculty list'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onLoad, child: const Text('Load')),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _FacultyList extends ConsumerWidget {
  final List<FacultyListItem> items;
  const _FacultyList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(child: Text('No faculty found'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final faculty = items[index];
        return FacultyListTile(
          faculty: faculty,
          onTap: () {
            AnalyticsService.logEvent('faculty_clicked', {
              'name': faculty.facultyName,
            });
            // Reset details state before opening the sheet so stale data isn't shown.
            ref.invalidate(facultyDetailsViewModelProvider);

            showModalBottomSheet<void>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              isScrollControlled: true,
              context: context,
              builder: (_) => FacultyDetailsSheet(faculty: faculty),
            );
          },
        );
      },
    );
  }
}
