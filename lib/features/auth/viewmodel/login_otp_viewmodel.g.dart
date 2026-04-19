// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_otp_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoginOtpViewModel)
final loginOtpViewModelProvider = LoginOtpViewModelProvider._();

final class LoginOtpViewModelProvider
    extends $NotifierProvider<LoginOtpViewModel, AsyncValue<void>?> {
  LoginOtpViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginOtpViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginOtpViewModelHash();

  @$internal
  @override
  LoginOtpViewModel create() => LoginOtpViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>?>(value),
    );
  }
}

String _$loginOtpViewModelHash() => r'b2bf6e78723df5802c6d2bb3c20b0ef73584a442';

abstract class _$LoginOtpViewModel extends $Notifier<AsyncValue<void>?> {
  AsyncValue<void>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>?, AsyncValue<void>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>?, AsyncValue<void>?>,
              AsyncValue<void>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
