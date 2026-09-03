import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vit_ap_student_app/core/constants/server_constants.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_bundle.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_cache_result.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_entry.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_hostel.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';

class MessMenuRepository {
  const MessMenuRepository();

  static const String _cacheBodyKeyPrefix = 'mess_menu_cached_body_';
  static const String _cacheFetchedAtKeyPrefix = 'mess_menu_cached_fetched_at_';
  static const String _cacheMonthKeyPrefix = 'mess_menu_cached_month_';

  Future<Either<Failure, void>> clearMenuCache() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      for (final MessMenuHostel hostel in MessMenuHostel.values) {
        await prefs.remove(_cacheBodyKey(hostel));
        await prefs.remove(_cacheFetchedAtKey(hostel));
        await prefs.remove(_cacheMonthKey(hostel));
      }
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to clear menu cache: $e'));
    }
  }

  Future<Either<Failure, void>> syncMenu({
    required MessMenuHostel hostel,
  }) async {
    final String? apiDomain = dotenv.env['MENU_API_DOMAIN']?.trim();
    if (apiDomain == null || apiDomain.isEmpty) {
      return Left(Failure('MENU_API_DOMAIN is not configured'));
    }

    final String normalizedDomain =
        apiDomain.startsWith('http://') || apiDomain.startsWith('https://')
        ? apiDomain
        : 'https://$apiDomain';

    final Uri uri = Uri.parse(
      '$normalizedDomain/api/menu?type=${hostel.apiType}',
    );
    final http.Client client = serviceLocator<http.Client>();

    try {
      final response = await client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(ServerConstants.apiTimeout);

      if (response.statusCode != 200) {
        return Left(Failure('Failed to fetch menu: ${response.statusCode}'));
      }

      final List<MessMenuEntry> entries = _parseMenuEntries(response.body);
      if (entries.isEmpty) {
        return Left(Failure('The menu response did not contain any entries'));
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheBodyKey(hostel), response.body);
      final DateTime now = DateTime.now();
      await prefs.setInt(
        _cacheFetchedAtKey(hostel),
        now.millisecondsSinceEpoch,
      );
      await prefs.setString(_cacheMonthKey(hostel), _monthKey(now));

      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to sync menu: $e'));
    }
  }

  Future<MessMenuCacheResult> loadForDate(
    DateTime date, {
    required MessMenuHostel hostel,
  }) async {
    final _CachedMenu cached = await _loadCachedMenu(hostel);
    final String? inferredMonthKey =
        cached.cachedMonthKey ??
        (cached.lastSyncedAt == null ? null : _monthKey(cached.lastSyncedAt!));

    if (cached.entries.isEmpty) {
      return MessMenuCacheResult(
        bundle: null,
        lastSyncedAt: cached.lastSyncedAt,
        isStale: false,
        message:
            'Offline copy unavailable. Open Settings and tap Sync when the menu service is reachable.',
      );
    }

    final String requestedMonthKey = _monthKey(date);
    if (inferredMonthKey != null && inferredMonthKey != requestedMonthKey) {
      return MessMenuCacheResult(
        bundle: null,
        lastSyncedAt: cached.lastSyncedAt,
        isStale: true,
        message:
            'Saved menu is for ${_prettyMonth(inferredMonthKey)}. Sync in Settings to load ${_prettyMonth(requestedMonthKey)}.',
      );
    }

    final List<MessMenuEntry> matches = cached.entries
        .where((MessMenuEntry entry) => entry.date == date.day)
        .toList(growable: false);

    final MessMenuEntry? regular = _firstWhereOrNull(
      matches,
      (MessMenuEntry entry) => !entry.isSpecial,
    );
    final MessMenuEntry? special = _firstWhereOrNull(
      matches,
      (MessMenuEntry entry) => entry.isSpecial,
    );

    if (regular == null && special == null) {
      return MessMenuCacheResult(
        bundle: null,
        lastSyncedAt: cached.lastSyncedAt,
        isStale: false,
        message:
            'No saved menu is available for ${_prettyDay(date)}. The offline copy may be from another month or incomplete. Sync in Settings to refresh it.',
      );
    }

    return MessMenuCacheResult(
      bundle: MessMenuBundle(
        date: date,
        regular: regular ?? special!,
        special: special,
      ),
      lastSyncedAt: cached.lastSyncedAt,
      isStale: false,
    );
  }

  Future<DateTime?> getLastSyncedAt({required MessMenuHostel hostel}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? timestamp = prefs.getInt(_cacheFetchedAtKey(hostel));
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<_CachedMenu> _loadCachedMenu(MessMenuHostel hostel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_cacheBodyKey(hostel));
    final int? fetchedAt = prefs.getInt(_cacheFetchedAtKey(hostel));
    final String? cachedMonthKey = prefs.getString(_cacheMonthKey(hostel));

    if (jsonString == null || jsonString.isEmpty) {
      return const _CachedMenu(
        entries: <MessMenuEntry>[],
        lastSyncedAt: null,
        cachedMonthKey: null,
      );
    }

    return _CachedMenu(
      entries: _parseMenuEntries(jsonString),
      lastSyncedAt: fetchedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(fetchedAt),
      cachedMonthKey: cachedMonthKey,
    );
  }

  String _cacheBodyKey(MessMenuHostel hostel) =>
      '$_cacheBodyKeyPrefix${hostel.apiType}';

  String _cacheFetchedAtKey(MessMenuHostel hostel) =>
      '$_cacheFetchedAtKeyPrefix${hostel.apiType}';

  String _cacheMonthKey(MessMenuHostel hostel) =>
      '$_cacheMonthKeyPrefix${hostel.apiType}';

  List<MessMenuEntry> _parseMenuEntries(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    List<dynamic> rawEntries = const <dynamic>[];
    if (decoded is List<dynamic>) {
      rawEntries = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final dynamic menu = decoded['menu'];
      if (menu is List<dynamic>) {
        rawEntries = menu;
      }
    }

    return rawEntries
        .whereType<Map<String, dynamic>>()
        .map(MessMenuEntry.fromJson)
        .toList(growable: false);
  }

  MessMenuEntry? _firstWhereOrNull(
    List<MessMenuEntry> entries,
    bool Function(MessMenuEntry entry) test,
  ) {
    for (final MessMenuEntry entry in entries) {
      if (test(entry)) return entry;
    }
    return null;
  }

  String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  String _prettyMonth(String monthKey) {
    final List<String> parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;
    final int? year = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    if (year == null || month == null || month < 1 || month > 12) {
      return monthKey;
    }
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[month - 1]} $year';
  }

  String _prettyDay(DateTime date) {
    const List<String> weekdays = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day}';
  }
}

class _CachedMenu {
  const _CachedMenu({
    required this.entries,
    required this.lastSyncedAt,
    required this.cachedMonthKey,
  });

  final List<MessMenuEntry> entries;
  final DateTime? lastSyncedAt;
  final String? cachedMonthKey;
}
