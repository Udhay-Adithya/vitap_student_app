// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_scheduler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one queue every writer of class and exam reminders goes through.
///
/// Knows nothing of the current user, so the current user's own notifier can
/// wait on it. The listener lives apart, in [reminderSync].

@ProviderFor(reminderScheduler)
final reminderSchedulerProvider = ReminderSchedulerProvider._();

/// The one queue every writer of class and exam reminders goes through.
///
/// Knows nothing of the current user, so the current user's own notifier can
/// wait on it. The listener lives apart, in [reminderSync].

final class ReminderSchedulerProvider
    extends
        $FunctionalProvider<
          ReminderScheduler,
          ReminderScheduler,
          ReminderScheduler
        >
    with $Provider<ReminderScheduler> {
  /// The one queue every writer of class and exam reminders goes through.
  ///
  /// Knows nothing of the current user, so the current user's own notifier can
  /// wait on it. The listener lives apart, in [reminderSync].
  ReminderSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderSchedulerHash();

  @$internal
  @override
  $ProviderElement<ReminderScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReminderScheduler create(Ref ref) {
    return reminderScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderScheduler>(value),
    );
  }
}

String _$reminderSchedulerHash() => r'd0f0a40fdf9e1d63520b7284c81b55fdac7389c6';

/// Keeps reminders in step with the signed-in user.
///
/// Read once at startup so the listener is in place: every change to the
/// current user rebuilds the schedule from it, and signing out cancels it.

@ProviderFor(reminderSync)
final reminderSyncProvider = ReminderSyncProvider._();

/// Keeps reminders in step with the signed-in user.
///
/// Read once at startup so the listener is in place: every change to the
/// current user rebuilds the schedule from it, and signing out cancels it.

final class ReminderSyncProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Keeps reminders in step with the signed-in user.
  ///
  /// Read once at startup so the listener is in place: every change to the
  /// current user rebuilds the schedule from it, and signing out cancels it.
  ReminderSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return reminderSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$reminderSyncHash() => r'd8ed4ac4af636d290faae86fdca4427e047fca7b';
