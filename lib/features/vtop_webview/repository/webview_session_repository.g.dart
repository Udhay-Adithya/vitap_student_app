// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_session_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(webViewSessionRepository)
final webViewSessionRepositoryProvider = WebViewSessionRepositoryProvider._();

final class WebViewSessionRepositoryProvider
    extends
        $FunctionalProvider<
          WebViewSessionRepository,
          WebViewSessionRepository,
          WebViewSessionRepository
        >
    with $Provider<WebViewSessionRepository> {
  WebViewSessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webViewSessionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webViewSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<WebViewSessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WebViewSessionRepository create(Ref ref) {
    return webViewSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebViewSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebViewSessionRepository>(value),
    );
  }
}

String _$webViewSessionRepositoryHash() =>
    r'd7863717d4171464eaad4b5b3efafa12a92cafd2';
