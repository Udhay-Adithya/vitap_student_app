// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_session_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The VTOP session the WebView continues. Null until [open] is called.

@ProviderFor(WebViewSessionViewModel)
final webViewSessionViewModelProvider = WebViewSessionViewModelProvider._();

/// The VTOP session the WebView continues. Null until [open] is called.
final class WebViewSessionViewModelProvider
    extends
        $NotifierProvider<
          WebViewSessionViewModel,
          AsyncValue<WebViewSession>?
        > {
  /// The VTOP session the WebView continues. Null until [open] is called.
  WebViewSessionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webViewSessionViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webViewSessionViewModelHash();

  @$internal
  @override
  WebViewSessionViewModel create() => WebViewSessionViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<WebViewSession>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<WebViewSession>?>(value),
    );
  }
}

String _$webViewSessionViewModelHash() =>
    r'c91dc11d11b8fb3ec2478294ddb3b8a59583be02';

/// The VTOP session the WebView continues. Null until [open] is called.

abstract class _$WebViewSessionViewModel
    extends $Notifier<AsyncValue<WebViewSession>?> {
  AsyncValue<WebViewSession>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<WebViewSession>?, AsyncValue<WebViewSession>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<WebViewSession>?,
                AsyncValue<WebViewSession>?
              >,
              AsyncValue<WebViewSession>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
