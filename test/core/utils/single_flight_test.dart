import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/utils/single_flight.dart';

void main() {
  group('SingleFlight', () {
    // Locks down the duplicate-OTP bug: VtopClientService.getClient had no
    // in-flight guard, so every caller that arrived during a login started its
    // own. VTOP emails a fresh code for each credentials POST from an
    // unverified IP, so two concurrent callers meant two OTP emails.
    test(
      'concurrent callers for the same key run the operation once',
      () async {
        final flight = SingleFlight<String, int>();
        var invocations = 0;
        final completer = Completer<int>();

        Future<int> start() {
          final pending = flight.pendingFor('key');
          if (pending != null) return pending;
          return flight.run('key', () {
            invocations++;
            return completer.future;
          });
        }

        final results = <Future<int>>[start(), start(), start()];
        completer.complete(7);

        expect(await Future.wait(results), <int>[7, 7, 7]);
        expect(invocations, 1);
      },
    );

    // The losing caller used to be orphaned: a second login overwrote the
    // Completer the first was waiting on, and that first caller hung forever
    // with no error and no timeout. Everyone who joins must settle.
    test('a failure reaches every joined caller', () async {
      final flight = SingleFlight<String, int>();
      final completer = Completer<int>();

      final first = flight.run('key', () => completer.future);
      final second = flight.pendingFor('key')!;

      completer.completeError(StateError('login failed'));

      await expectLater(first, throwsStateError);
      await expectLater(second, throwsStateError);
    });

    test('the slot is released once the operation succeeds', () async {
      final flight = SingleFlight<String, int>();

      await flight.run('key', () async => 1);

      expect(flight.isRunning, isFalse);
      expect(flight.pendingFor('key'), isNull);
    });

    test('the slot is released after a failure, so a retry can run', () async {
      final flight = SingleFlight<String, int>();
      var invocations = 0;

      await expectLater(
        flight.run('key', () async {
          invocations++;
          throw StateError('nope');
        }),
        throwsStateError,
      );
      expect(flight.isRunning, isFalse);

      expect(await flight.run('key', () async => ++invocations), 2);
    });

    // A password change must not join the login it invalidates, and an account
    // switch must not be handed the previous account's session.
    test('a different key does not join the in-flight operation', () async {
      final flight = SingleFlight<String, int>();
      final completer = Completer<int>();

      final first = flight.run('user-a', () => completer.future);

      expect(flight.pendingFor('user-b'), isNull);
      expect(flight.isRunning, isTrue);

      completer.complete(1);
      expect(await first, 1);
    });

    test(
      'clear() stops new callers joining but still settles the old one',
      () async {
        final flight = SingleFlight<String, int>();
        final completer = Completer<int>();

        final abandoned = flight.run('key', () => completer.future);
        flight.clear();

        expect(flight.pendingFor('key'), isNull);
        expect(flight.isRunning, isFalse);

        completer.complete(1);
        expect(await abandoned, 1);
      },
    );

    // Guards the release path: a cleared-then-restarted slot must not be wiped
    // by the abandoned operation finishing afterwards, or the login that
    // replaced it would stop being joinable and callers would start new ones.
    test('a straggler completing does not release a newer claim', () async {
      final flight = SingleFlight<String, int>();
      final abandonedCompleter = Completer<int>();
      final currentCompleter = Completer<int>();

      final abandoned = flight.run('old', () => abandonedCompleter.future);
      flight.clear();
      final current = flight.run('new', () => currentCompleter.future);

      abandonedCompleter.complete(1);
      await abandoned;

      expect(flight.isRunning, isTrue);
      expect(flight.pendingFor('new'), isNotNull);

      currentCompleter.complete(2);
      expect(await current, 2);
    });
  });
}
