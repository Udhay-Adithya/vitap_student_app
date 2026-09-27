import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/common/widget/section_header.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/home/model/for_you_item.dart';
import 'package:vit_ap_student_app/features/home/view/pages/for_you_add_page.dart';
import 'package:vit_ap_student_app/features/home/view/pages/tile_detail_page.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/for_you_card.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/for_you_viewmodel.dart';

class ForYouViewAllPage extends ConsumerStatefulWidget {
  const ForYouViewAllPage({super.key});

  @override
  ConsumerState<ForYouViewAllPage> createState() => _ForYouViewAllPageState();
}

class _ForYouViewAllPageState extends ConsumerState<ForYouViewAllPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedType;
  String _sortBy = 'likes';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logScreen('ForYouViewAllPage');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref
        .read(forYouViewModelProvider.notifier)
        .filterItems(
          searchQuery: _searchController.text,
          typeFilter: _selectedType,
          sortBy: _sortBy,
          ascending: _sortAscending,
        );
  }

  void _showSortOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.heart),
              title: const Text('Most Liked'),
              trailing: _sortBy == 'likes' && !_sortAscending
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'likes';
                  _sortAscending = false;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.calendar),
              title: const Text('Newest First'),
              trailing: _sortBy == 'created_at' && !_sortAscending
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'created_at';
                  _sortAscending = false;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.calendar_1),
              title: const Text('Oldest First'),
              trailing: _sortBy == 'created_at' && _sortAscending
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'created_at';
                  _sortAscending = true;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.text),
              title: const Text('Alphabetical (A-Z)'),
              trailing: _sortBy == 'title' && _sortAscending
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                setState(() {
                  _sortBy = 'title';
                  _sortAscending = true;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(forYouViewModelProvider);
    final types = ref.watch(forYouTypesProvider);
    final likedItems = ref.watch(likedItemsSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'For you',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const ForYouAddPage(),
            ),
          );
        },
        icon: const Icon(Iconsax.add),
        label: const Text('Add Tool'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search tools & resources...',
                      prefixIcon: const Icon(Iconsax.search_normal_1_copy),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLow,
                    ),
                    onSubmitted: (_) => _applyFilters(),
                    onChanged: (value) {
                      setState(() {});
                      // Debounce search
                      Future<void>.delayed(
                        const Duration(milliseconds: 500),
                        () {
                          if (_searchController.text == value) {
                            _applyFilters();
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Iconsax.filter_copy),
                  onPressed: _showSortOptions,
                  tooltip: 'Sort',
                ),
              ],
            ),
          ),
          // Type Filter Chips
          if (types.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedType == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = null;
                      });
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  ...types.map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type.toUpperCase()),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Items Grid
          Expanded(
            child: itemsAsync.when(
              data: (items) => items.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(forYouViewModelProvider.notifier).refresh(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        // Bottom inset clears the "Add Tool" FAB; the
                        // horizontal gutter matches the width the cards size
                        // themselves against.
                        padding: const EdgeInsets.fromLTRB(
                          SectionHeader.gutter,
                          0,
                          SectionHeader.gutter,
                          96,
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: items.map((item) {
                            return ForYouCard(
                              item: item,
                              isLiked: likedItems.contains(item.id),
                              onTap: () => _navigateToDetail(item),
                              onLike: () => _likeItem(item.id),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.warning_2,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load items',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          ref.read(forYouViewModelProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_status,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No tools found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(ForYouItem item) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => TileDetailPage(item: item)),
    );
  }

  void _likeItem(String itemId) {
    ref.read(forYouViewModelProvider.notifier).likeItem(itemId);
  }
}
