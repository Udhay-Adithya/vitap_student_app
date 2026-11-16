import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vit_ap_student_app/core/constants/server_constants.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/providers/http_client.dart';
import 'package:vit_ap_student_app/features/home/model/for_you_item.dart';
import 'package:vit_ap_student_app/features/home/repository/for_you_feed.dart';

part 'for_you_repository.g.dart';

@riverpod
ForYouRepository forYouRepository(Ref ref) {
  final client = ref.watch(httpClientProvider);
  return ForYouRepository(client);
}

/// The For You feed is hand-curated and changes a few times a month, but the
/// home tab is rebuilt from scratch every time the user returns to it. Fetching
/// on each of those rebuilds is what made a nearly static list the app's most
/// requested endpoint, so reads go through a disk cache and only revalidate
/// once the entries go stale — and then with an `ETag`, so an unchanged feed
/// costs a 304 rather than the whole body.
class ForYouRepository {
  static const String _cacheBodyKey = 'for_you_items_body';
  static const String _cacheEtagKey = 'for_you_items_etag';
  static const String _cacheFetchedAtKey = 'for_you_items_fetched_at';

  final http.Client _client;
  final String _baseUrl = ServerConstants.forYouApiBaseUrl;

  ForYouRepository(this._client);

  Map<String, String> get _headers {
    final apiKey = dotenv.env['FOR_YOU_API_KEY'] ?? '';
    return {'X-API-Key': apiKey, 'Content-Type': 'application/json'};
  }

  /// Every approved, active item, newest first.
  ///
  /// Filtering, searching and sorting stay in the view model — they run against
  /// this list without a request, so they must not be a reason to call the
  /// network. Pass [forceRefresh] for an explicit pull-to-refresh.
  Future<Either<Failure, List<ForYouItem>>> fetchItems({
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedBody = prefs.getString(_cacheBodyKey);
    final fetchedAt = prefs.getInt(_cacheFetchedAtKey);

    final isFresh = isForYouCacheFresh(
      fetchedAt: fetchedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(fetchedAt),
      now: DateTime.now(),
    );

    if (!forceRefresh && cachedBody != null && isFresh) {
      final cached = parseForYouFeed(cachedBody);
      if (cached != null) return Right(cached);
    }

    try {
      final etag = prefs.getString(_cacheEtagKey);
      final response = await _client.get(
        Uri.parse('$_baseUrl/items'),
        headers: {
          ..._headers,
          if (etag != null && cachedBody != null) 'If-None-Match': etag,
        },
      );

      if (response.statusCode == 304 && cachedBody != null) {
        final cached = parseForYouFeed(cachedBody);
        if (cached != null) {
          await prefs.setInt(
            _cacheFetchedAtKey,
            DateTime.now().millisecondsSinceEpoch,
          );
          return Right(cached);
        }
      }

      if (response.statusCode == 200) {
        final items = parseForYouFeed(response.body);
        if (items == null) {
          return _cacheFallback(cachedBody, 'Failed to read items');
        }
        await prefs.setString(_cacheBodyKey, response.body);
        await prefs.setInt(
          _cacheFetchedAtKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        final responseEtag = response.headers['etag'];
        if (responseEtag != null) {
          await prefs.setString(_cacheEtagKey, responseEtag);
        } else {
          await prefs.remove(_cacheEtagKey);
        }
        return Right(items);
      }

      return _cacheFallback(
        cachedBody,
        'Failed to fetch items: ${response.statusCode}',
      );
    } catch (e) {
      return _cacheFallback(cachedBody, 'Failed to fetch items: $e');
    }
  }

  /// A stale feed beats an error screen when the network is the thing that
  /// failed, so the cache is served past its TTL rather than discarded.
  Either<Failure, List<ForYouItem>> _cacheFallback(
    String? cachedBody,
    String message,
  ) {
    if (cachedBody != null) {
      final cached = parseForYouFeed(cachedBody);
      if (cached != null) return Right(cached);
    }
    return Left(Failure(message));
  }

  /// Submit a new item for approval
  /// Returns Unit on success since unapproved items won't be visible
  Future<Either<Failure, Unit>> submitItem(
    ForYouItemSubmission submission,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/items'),
        headers: _headers,
        body: json.encode(submission.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(unit);
      } else {
        return Left(Failure('Failed to submit item: ${response.statusCode}'));
      }
    } catch (e) {
      log(e.toString());
      return Left(Failure('Failed to submit item: ${e.toString()}'));
    }
  }

  /// Increment like count for an item.
  ///
  /// The cached body keeps the pre-like count; the view model patches its own
  /// copy, and the next revalidation picks up the real number. Rewriting the
  /// cache here would mean re-encoding the whole feed for one integer.
  Future<Either<Failure, ForYouItem>> likeItem(String itemId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/items/$itemId/like'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final item = ForYouItem.fromJson(data);
        return Right(item);
      } else {
        return Left(Failure('Failed to like item: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Failed to like item: ${e.toString()}'));
    }
  }
}
