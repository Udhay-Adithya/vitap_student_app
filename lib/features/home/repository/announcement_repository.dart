import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/constants/server_constants.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/providers/http_client.dart';
import 'package:vit_ap_student_app/features/home/model/announcement.dart';

part 'announcement_repository.g.dart';

@riverpod
AnnouncementRepository announcementRepository(Ref ref) {
  final client = ref.watch(httpClientProvider);
  return AnnouncementRepository(client);
}

/// Fetches the announcement feed and hands it back raw.
///
/// Deliberately does no filtering or sorting: what a student should see depends
/// on their platform, app version and cohort, none of which belong in a
/// repository. That work lives in `announcement_targeting.dart`, where it is
/// testable without a network.
class AnnouncementRepository {
  AnnouncementRepository(this.client);

  final http.Client client;

  static const String _announcementsUrl =
      '${ServerConstants.githubBaseUrl}/announcements.json';

  Future<Either<Failure, List<Announcement>>> fetchAnnouncements() async {
    try {
      final response = await client.get(
        Uri.parse(_announcementsUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return Left(
          Failure('Failed to fetch announcements: ${response.statusCode}'),
        );
      }

      // Parsing is lenient by design — see [Announcement.tryParse]. A single
      // malformed entry is skipped; it used to take the entire feed with it.
      final AnnouncementResponse parsed = AnnouncementResponse.parse(
        jsonDecode(response.body),
      );
      return Right(parsed.announcements);
    } on SocketException {
      return Left(Failure('No internet connection'));
    } on FormatException catch (e) {
      return Left(Failure('Invalid response format: ${e.message}'));
    } catch (e) {
      return Left(Failure('Unexpected error: ${e.toString()}'));
    }
  }
}
