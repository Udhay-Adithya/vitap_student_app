import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/core/common/widget/empty_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/home/model/general_outing_report.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/outing/general_outing_card.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/outing_reports_viewmodel.dart';

class GeneralOutingHistoryPage extends ConsumerStatefulWidget {
  const GeneralOutingHistoryPage({super.key});

  @override
  ConsumerState<GeneralOutingHistoryPage> createState() =>
      _GeneralOutingHistoryPageState();
}

class _GeneralOutingHistoryPageState
    extends ConsumerState<GeneralOutingHistoryPage> {
  DateTime? lastSynced;
  String searchQuery = '';
  bool isRecentFirst = true; // true = recent on top, false = oldest on top
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _fetchData() async {
    return ref
        .read(generalOutingReportsViewModelProvider.notifier)
        .fetchGeneralOutingReports();
  }

  Future<void> _refreshData() async {
    await AnalyticsService.logEvent('refresh_general_outing_history');
    final didSync = await _fetchData();
    // Only stamp "last synced" when a fresh remote copy was actually fetched.
    if (didSync && mounted) {
      setState(() {
        lastSynced = DateTime.now();
      });
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // Try parsing common date formats
      final formats = [
        'dd-MMM-yyyy',
        'dd/MM/yyyy',
        'yyyy-MM-dd',
        'dd-MM-yyyy',
      ];
      for (final format in formats) {
        try {
          return DateFormat(format).parse(dateStr);
        } catch (_) {}
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<GeneralOutingReport> _getFilteredAndSortedReports(
      List<GeneralOutingReport> reports) {
    List<GeneralOutingReport> filteredReports = reports.toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filteredReports = filteredReports
          .where((report) =>
              report.purposeOfVisit
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              report.placeOfVisit
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              report.status.toLowerCase().contains(searchQuery.toLowerCase()) ||
              report.fromDate
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              report.toDate.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Sort by fromDate
    filteredReports.sort((a, b) {
      final dateA = _parseDate(a.fromDate);
      final dateB = _parseDate(b.fromDate);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return isRecentFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return filteredReports;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generalOutingReportsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('General Outing History'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: state?.when(
              data: (reports) {
                if (reports.isEmpty) {
                  return const Center(
                    child: EmptyContentView(
                      primaryText: 'No general outing applications found',
                      secondaryText:
                          'Your outing applications will appear here',
                    ),
                  );
                }

                final filteredReports = _getFilteredAndSortedReports(reports);

                return Column(
                  children: [
                    // Search bar with filter button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search outings...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            searchQuery = '';
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filledTonal(
                            onPressed: () {
                              setState(() {
                                isRecentFirst = !isRecentFirst;
                              });
                            },
                            tooltip: isRecentFirst
                                ? 'Recent on top'
                                : 'Oldest on top',
                            icon: Icon(
                              isRecentFirst
                                  ? Icons.vertical_align_top_rounded
                                  : Icons.vertical_align_bottom_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // List
                    Expanded(
                      child: filteredReports.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No outings found',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your search criteria',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: filteredReports.length,
                              itemBuilder: (context, index) {
                                return GeneralOutingCard(
                                  outing: filteredReports[index],
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
              loading: () => const Loader(),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ) ??
            const Loader(),
      ),
    );
  }
}
