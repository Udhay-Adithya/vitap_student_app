import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/features/home/model/for_you_item.dart';
import 'package:vit_ap_student_app/features/home/repository/for_you_repository.dart';

part 'for_you_viewmodel.g.dart';

/// Provider to track liked items in current session (resets on app restart)
@riverpod
class LikedItemsSession extends _$LikedItemsSession {
  @override
  Set<String> build() => {};

  bool isLiked(String itemId) => state.contains(itemId);

  void addLike(String itemId) {
    state = {...state, itemId};
  }
}

/// Main ViewModel - holds all items and provides filtered views
///
/// Kept alive for the life of the app. The home tab is torn down and rebuilt
/// every time the user switches tabs, and an auto-disposed provider turned each
/// of those into a fresh fetch of a list that changes a few times a month.
@Riverpod(keepAlive: true)
class ForYouViewModel extends _$ForYouViewModel {
  List<ForYouItem> _allItems = [];

  @override
  AsyncValue<List<ForYouItem>> build() {
    _fetchItems(markLoading: false);
    return const AsyncValue.loading();
  }

  Future<void> _fetchItems({
    bool forceRefresh = false,
    // `state` cannot be read until `build` has returned, and `build` starts
    // this fetch synchronously — touching it there throws "Tried to read the
    // state of an uninitialized provider". The initial call doesn't need to
    // anyway, since `build` returns the loading state itself.
    bool markLoading = true,
  }) async {
    // Only blank the screen when there is nothing to show. A refresh over an
    // already populated list should leave the list on screen rather than
    // replacing it with a spinner.
    if (markLoading && !state.hasValue) state = const AsyncValue.loading();

    final repository = ref.read(forYouRepositoryProvider);
    final result = await repository.fetchItems(forceRefresh: forceRefresh);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (items) {
        _allItems = items;
        state = AsyncValue.data(items);
      },
    );
  }

  /// Refresh items from server, bypassing the cache TTL.
  Future<void> refresh() async {
    await _fetchItems(forceRefresh: true);
  }

  /// Filter and sort items locally (no server request)
  void filterItems({
    String? searchQuery,
    String? typeFilter,
    String sortBy = 'likes',
    bool ascending = false,
  }) {
    var filteredItems = List<ForYouItem>.from(_allItems);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredItems = filteredItems.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.author.toLowerCase().contains(query) ||
            item.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Apply type filter
    if (typeFilter != null && typeFilter.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        return item.type.toLowerCase() == typeFilter.toLowerCase();
      }).toList();
    }

    // Apply sorting
    filteredItems.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'likes':
          comparison = a.likes.compareTo(b.likes);
          break;
        case 'created_at':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        default:
          comparison = a.likes.compareTo(b.likes);
      }
      return ascending ? comparison : -comparison;
    });

    state = AsyncValue.data(filteredItems);
  }

  /// Reset filters and show all items
  void resetFilters() {
    state = AsyncValue.data(_allItems);
  }

  /// Like an item
  Future<void> likeItem(String itemId) async {
    final likedSession = ref.read(likedItemsSessionProvider.notifier);
    if (likedSession.isLiked(itemId)) return;

    final repository = ref.read(forYouRepositoryProvider);
    final result = await repository.likeItem(itemId);

    result.fold((failure) => null, (updatedItem) {
      likedSession.addLike(itemId);

      // Update in _allItems
      _allItems = _allItems.map((item) {
        if (item.id == itemId) return updatedItem;
        return item;
      }).toList();

      // Update current state
      state = state.whenData((items) {
        return items.map((item) {
          if (item.id == itemId) return updatedItem;
          return item;
        }).toList();
      });
    });
  }
}

/// Provider for featured items - derived from main items list
@riverpod
List<ForYouItem> featuredItems(Ref ref) {
  final itemsAsync = ref.watch(forYouViewModelProvider);
  return itemsAsync.maybeWhen(
    data: (items) =>
        items.where((item) => item.isFeatured).toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
    orElse: () => [],
  );
}

/// Provider for available types - derived from main items list
@riverpod
List<String> forYouTypes(Ref ref) {
  final itemsAsync = ref.watch(forYouViewModelProvider);
  return itemsAsync.maybeWhen(
    data: (items) => items.map((item) => item.type).toSet().toList(),
    orElse: () => [],
  );
}

/// Provider for submit state
@riverpod
class ForYouSubmit extends _$ForYouSubmit {
  @override
  AsyncValue<bool> build() => const AsyncValue.data(false);

  Future<bool> submitItem(ForYouItemSubmission submission) async {
    state = const AsyncValue.loading();
    final repository = ref.read(forYouRepositoryProvider);
    final result = await repository.submitItem(submission);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(true);
        return true;
      },
    );
  }

  void reset() {
    state = const AsyncValue.data(false);
  }
}

/// Helper function to format likes count (1K, 2K, etc.)
String formatLikesCount(int likes) {
  if (likes >= 1000000) {
    return '${(likes / 1000000).toStringAsFixed(likes % 1000000 == 0 ? 0 : 1)}M';
  } else if (likes >= 1000) {
    return '${(likes / 1000).toStringAsFixed(likes % 1000 == 0 ? 0 : 1)}K';
  }
  return likes.toString();
}
