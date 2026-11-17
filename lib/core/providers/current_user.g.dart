// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in student, or null when nobody is.
///
/// Storage belongs to [SessionRepository] and reminders follow this state on
/// their own (see `reminderSchedulerProvider`). State is assigned once per
/// transition, after storage has succeeded, so listeners never see a user that
/// was not actually saved.

@ProviderFor(CurrentUserNotifier)
final currentUserProvider = CurrentUserNotifierProvider._();

/// The signed-in student, or null when nobody is.
///
/// Storage belongs to [SessionRepository] and reminders follow this state on
/// their own (see `reminderSchedulerProvider`). State is assigned once per
/// transition, after storage has succeeded, so listeners never see a user that
/// was not actually saved.
final class CurrentUserNotifierProvider
    extends $NotifierProvider<CurrentUserNotifier, User?> {
  /// The signed-in student, or null when nobody is.
  ///
  /// Storage belongs to [SessionRepository] and reminders follow this state on
  /// their own (see `reminderSchedulerProvider`). State is assigned once per
  /// transition, after storage has succeeded, so listeners never see a user that
  /// was not actually saved.
  CurrentUserNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserNotifierHash();

  @$internal
  @override
  CurrentUserNotifier create() => CurrentUserNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$currentUserNotifierHash() =>
    r'065ca32b82307152a6f945df48e32356d6d8322e';

/// The signed-in student, or null when nobody is.
///
/// Storage belongs to [SessionRepository] and reminders follow this state on
/// their own (see `reminderSchedulerProvider`). State is assigned once per
/// transition, after storage has succeeded, so listeners never see a user that
/// was not actually saved.

abstract class _$CurrentUserNotifier extends $Notifier<User?> {
  User? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<User?, User?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<User?, User?>,
              User?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
