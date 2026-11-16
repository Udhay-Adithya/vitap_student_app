import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/features/home/model/for_you_item.dart';
import 'package:vit_ap_student_app/features/home/repository/for_you_repository.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/for_you_viewmodel.dart';

ForYouItem item(String id) => ForYouItem(
  id: id,
  title: 'Tool $id',
  author: 'Someone',
  authorEmail: 'someone@vitapstudent.ac.in',
  type: 'tools',
  description: 'Does a thing',
  url: 'https://example.com',
  isApproved: true,
  isFeatured: true,
  displayOrder: 0,
  likes: 0,
  createdAt: '2026-01-01T00:00:00Z',
);

/// Answers without touching SharedPreferences or the network, and records how
/// often it was asked.
class StubRepository implements ForYouRepository {
  StubRepository(this.result);

  final Either<Failure, List<ForYouItem>> result;
  final List<bool> calls = [];

  @override
  Future<Either<Failure, List<ForYouItem>>> fetchItems({
    bool forceRefresh = false,
  }) async {
    calls.add(forceRefresh);
    return result;
  }

  @override
  Future<Either<Failure, Unit>> submitItem(
    ForYouItemSubmission submission,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, ForYouItem>> likeItem(String itemId) async =>
      Right(item(itemId));
}

ProviderContainer containerWith(StubRepository repository) {
  final container = ProviderContainer(
    overrides: [forYouRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('ForYouViewModel', () {
    testWidgets(
      // `build` kicks off the fetch synchronously, so anything that reads
      // `state` on that path throws "Tried to read the state of an
      // uninitialized provider" and takes the whole home page down. The
      // carousel test can't catch this: it stubs `build` out.
      'builds without reading its own state',
      (tester) async {
        final repository = StubRepository(Right([item('a')]));
        final container = containerWith(repository);

        final sub = container.listen(
          forYouViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );

        expect(sub.read(), const AsyncValue<List<ForYouItem>>.loading());

        await tester.pump(Duration.zero);

        expect(sub.read().value, hasLength(1));
        expect(repository.calls, [false], reason: 'first load is not forced');
      },
    );

    testWidgets('surfaces a failure as an error state', (tester) async {
      final container = containerWith(StubRepository(Left(Failure('nope'))));

      final sub = container.listen(
        forYouViewModelProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await tester.pump(Duration.zero);

      expect(sub.read().hasError, isTrue);
    });

    testWidgets('refresh bypasses the cache TTL', (tester) async {
      final repository = StubRepository(Right([item('a')]));
      final container = containerWith(repository);

      container.listen(
        forYouViewModelProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await tester.pump(Duration.zero);

      await container.read(forYouViewModelProvider.notifier).refresh();

      expect(repository.calls, [false, true]);
    });
  });
}
