import 'package:objectbox/objectbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'store.g.dart';

/// The app's ObjectBox store.
///
/// Opening a store is asynchronous and has to finish before the first frame,
/// so there is nothing here to build: `initDependencies` opens it and supplies
/// it as an override, and tests override it with a throwaway store.
@Riverpod(keepAlive: true)
Store store(Ref ref) => throw UnimplementedError(
  'storeProvider has no default. Override it with an opened store.',
);
