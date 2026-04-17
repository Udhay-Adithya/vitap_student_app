import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/contributor.dart';
import 'package:vit_ap_student_app/features/account/repository/github_repository.dart';

part 'github_viewmodel.g.dart';

@riverpod
class ChangelogViewModel extends _$ChangelogViewModel {
  late GithubRepository _githubRepository;

  @override
  AsyncValue<String>? build() {
    _githubRepository = ref.watch(githubRepositoryProvider);
    return null;
  }

  Future<void> fetchChangelog() async {
    state = const AsyncValue.loading();

    final result = await _githubRepository.fetchChangelog();

    state = switch (result) {
      Left(value: final failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      Right(value: final changelog) => AsyncValue.data(changelog),
    };
  }
}

@riverpod
class ContributorsViewModel extends _$ContributorsViewModel {
  late GithubRepository _githubRepository;

  @override
  AsyncValue<List<Contributor>> build() {
    _githubRepository = ref.watch(githubRepositoryProvider);
    Future(fetchContributors);
    return const AsyncValue.loading();
  }

  Future<void> fetchContributors() async {
    state = const AsyncValue.loading();

    final result = await _githubRepository.fetchContributors();

    state = switch (result) {
      Left(value: final failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      Right(value: final contributors) => AsyncValue.data(contributors),
    };
  }
}
