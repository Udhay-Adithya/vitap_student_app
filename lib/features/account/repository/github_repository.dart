import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/constants/app_constants.dart';
import 'package:vit_ap_student_app/core/constants/server_constants.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/models/contributor.dart';
import 'package:vit_ap_student_app/core/providers/http_client.dart';

part 'github_repository.g.dart';

@riverpod
GithubRepository githubRepository(Ref ref) {
  final client = ref.watch(httpClientProvider);
  return GithubRepository(client);
}

class GithubRepository {
  final http.Client client;

  static const String _changelogUrl =
      '${ServerConstants.githubBaseUrl}/CHANGELOG.md';

  static const String _contributorsUrl =
      'https://api.github.com/repos/Udhay-Adithya/vitap_student_app/contributors';

  GithubRepository(this.client);

  /// Fetches the CHANGELOG.md content from the GitHub repository
  Future<Either<Failure, String>> fetchChangelog() async {
    try {
      final response = await client.get(
        Uri.parse(_changelogUrl),
        headers: {'Accept': 'text/plain'},
      );

      if (response.statusCode == 200) {
        return Right(utf8.decode(response.bodyBytes));
      } else {
        return Left(
          Failure('Failed to fetch changelog: ${response.statusCode}'),
        );
      }
    } on SocketException {
      return Left(Failure('No internet connection'));
    } catch (e) {
      return Left(Failure('Unexpected error: ${e.toString()}'));
    }
  }

  /// Fetches the list of contributors from the GitHub API,
  /// excluding the main developers and bots
  Future<Either<Failure, List<Contributor>>> fetchContributors() async {
    try {
      final response = await client.get(
        Uri.parse(_contributorsUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final contributors = data
            .map((json) => Contributor.fromJson(json as Map<String, dynamic>))
            .where(
              (contributor) =>
                  !AppConstants.excludedGithubUsernames.contains(
                    contributor.login,
                  ) &&
                  !contributor.login.contains('[bot]'),
            )
            .toList();

        return Right(contributors);
      } else {
        return Left(
          Failure('Failed to fetch contributors: ${response.statusCode}'),
        );
      }
    } on SocketException {
      return Left(Failure('No internet connection'));
    } catch (e) {
      return Left(Failure('Unexpected error: ${e.toString()}'));
    }
  }
}
