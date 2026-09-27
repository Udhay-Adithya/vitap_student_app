// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserPreferencesNotifier)
final userPreferencesProvider = UserPreferencesNotifierProvider._();

final class UserPreferencesNotifierProvider
    extends $NotifierProvider<UserPreferencesNotifier, UserPreferences> {
  UserPreferencesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPreferencesNotifierHash();

  @$internal
  @override
  UserPreferencesNotifier create() => UserPreferencesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserPreferences>(value),
    );
  }
}

String _$userPreferencesNotifierHash() =>
    r'66b6d71df1b4169ef714c0911aaad889967117cc';

abstract class _$UserPreferencesNotifier extends $Notifier<UserPreferences> {
  UserPreferences build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserPreferences, UserPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserPreferences, UserPreferences>,
              UserPreferences,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
