import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/constants/server_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/vtop_webview/models/webview_cookie_data.dart';
import 'package:vit_ap_student_app/features/vtop_webview/models/webview_session.dart';
import 'package:vit_ap_student_app/features/vtop_webview/view/widgets/url_bar.dart';
import 'package:vit_ap_student_app/features/vtop_webview/viewmodel/webview_session_viewmodel.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A page that displays VTOP portal in a WebView with authenticated session.
///
/// This page injects the cookies from the Rust backend's authenticated session
/// into the WebView, allowing users to access VTOP in a logged-in state.
class VtopWebViewPage extends ConsumerStatefulWidget {
  const VtopWebViewPage({super.key});

  @override
  ConsumerState<VtopWebViewPage> createState() => _VtopWebViewPageState();
}

class _VtopWebViewPageState extends ConsumerState<VtopWebViewPage> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isContentLoaded = false;
  String? _errorMessage;
  double _loadingProgress = 0;
  String _currentUrl = '';
  String? _csrfToken;
  String? _authorizedId;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logScreen('VtopWebViewPage');
    // Opened by an explicit tap, so the session is fetched straight away.
    // After the first frame: a provider cannot change while the tree builds.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(webViewSessionViewModelProvider.notifier).open(),
    );
  }

  /// Points a fresh WebView at the portal, continuing [session].
  Future<void> _loadSession(WebViewSession session) async {
    try {
      _setState(() {
        _isLoading = true;
        _isContentLoaded = false;
        _errorMessage = null;
        _controller = null;
      });
      _csrfToken = session.csrfToken;
      _authorizedId = session.authorizedId;

      await _injectCookies(session.cookies);

      final userAgent = session.userAgent;
      _trace('session user agent: $userAgent');

      // Configured with awaits rather than a cascade so the order is
      // guaranteed: the user agent must be in place before the first request
      // goes out, or the portal sees a different client than the one that owns
      // the session and bounces it to the login page.
      final WebViewController controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setUserAgent(userAgent);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            _setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
            _trace('started  -> $url');
          },
          onPageFinished: (String url) async {
            _setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
            _trace('finished -> $url');

            // Extract CSRF token from the page for potential future use
            await _extractCsrfToken();

            // If we're on the open/page, auto-navigate to content page
            if (url.contains(ServerConstants.vtopOpenPage) &&
                _csrfToken != null) {
              _trace('on open page with csrf, posting to content');
              await Future<void>.delayed(const Duration(milliseconds: 300));
              await _navigateWithPost(ServerConstants.vtopContentPage);
            }
            // Content page loaded - reveal the WebView!
            else if (url.contains(ServerConstants.vtopContentPage)) {
              _trace('REACHED CONTENT - session accepted');
              _setState(() {
                _isContentLoaded = true;
              });
            }
            // Check if redirected to login page (session expired)
            else if (url.contains(ServerConstants.vtopLoginPage) ||
                url.contains(ServerConstants.vtopPreLoginPage)) {
              _trace('BOUNCED TO LOGIN - session not accepted by the portal');
              _setState(() {
                _errorMessage =
                    'Session expired. Please go back and try again.';
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            // Only show error if it's a main frame error
            if (error.isForMainFrame ?? false) {
              _setState(() {
                _errorMessage = 'Failed to load page: ${error.description}';
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            _trace('request  -> ${request.url}');
            // Allow all VTOP navigation
            if (request.url.startsWith(ServerConstants.vtopBaseUrl)) {
              return NavigationDecision.navigate;
            }
            // Block external links
            _trace('blocked external -> ${request.url}');
            return NavigationDecision.prevent;
          },
        ),
      );
      _controller = controller;

      // Load the VTOP open page to establish cookie context
      // The authenticated cookies + CSRF from Rust will be used for POST navigation
      await controller.loadRequest(
        Uri.parse(
          '${ServerConstants.vtopBaseUrl}${ServerConstants.vtopOpenPage}',
        ),
      );

      _setState(() {});
    } catch (e) {
      _trace('webview setup failed: $e');
      _setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load VTOP: ${e.toString()}';
      });
    }
  }

  /// [setState] that tolerates the page having been popped.
  ///
  /// Everything here runs after an await on the network or the platform
  /// channel, and the user can leave at any point during a load. Calling
  /// setState on a disposed State throws.
  void _setState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  /// Diagnostic trail for the page chain this WebView walks.
  ///
  /// The portal answers a request it does not accept with a redirect to the
  /// login page rather than an error, so "where did it end up" is the only way
  /// to tell an authenticated session from a rejected one.
  void _trace(String message) {
    if (kDebugMode) debugPrint('[vtop-webview] $message');
  }

  /// Extract CSRF token from the current page using JavaScript
  Future<void> _extractCsrfToken() async {
    if (_controller == null) return;

    try {
      final result = await _controller!.runJavaScriptReturningResult('''
        (function() {
          var csrfInput = document.querySelector('input[name="_csrf"]');
          return csrfInput ? csrfInput.value : '';
        })()
      ''');

      final token = result.toString().replaceAll('"', '');
      if (token.isEmpty) return;

      // The login and OTP pages carry their own _csrf, belonging to an
      // unauthenticated session. Taking it would overwrite the token handed
      // over by the Rust session and make every later POST fail for a second,
      // unrelated reason.
      if (_currentUrl.contains(ServerConstants.vtopLoginPage) ||
          _currentUrl.contains(ServerConstants.vtopPreLoginPage)) {
        _trace('ignoring csrf from an unauthenticated page');
        return;
      }

      _csrfToken = token;
    } catch (e) {
      debugPrint('Failed to extract CSRF token');
    }
  }

  /// Navigate to a VTOP page using POST with CSRF token
  /// Escape a string for safe inclusion in an HTML attribute.
  String _htmlAttrEscape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  Future<void> _navigateWithPost(
    String path, {
    Map<String, String>? additionalParams,
    bool verifyMenu = true,
  }) async {
    if (_controller == null || _csrfToken == null) {
      return;
    }

    final params = {
      '_csrf': _csrfToken!,
      if (_authorizedId != null) 'authorizedID': _authorizedId!,
      if (verifyMenu) 'verifyMenu': 'true',
      'nocache': '@(new Date().getTime())',
      ...?additionalParams,
    };

    final formFields = params.entries
        .map(
          (e) =>
              '<input type="hidden" name="${_htmlAttrEscape(e.key)}" value="${_htmlAttrEscape(e.value)}">',
        )
        .join('');

    final jsCode =
        '''
      (function() {
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '${ServerConstants.vtopBaseUrl}$path';
        form.innerHTML = '$formFields';
        document.body.appendChild(form);
        form.submit();
      })()
    ''';

    debugPrint('Navigating to $path with POST');
    try {
      await _controller!.runJavaScript(jsCode);
    } catch (e) {
      debugPrint('Failed to navigate with POST: $e');
    }
  }

  /// Replaces the WebView's cookies with the session's.
  Future<void> _injectCookies(List<WebViewCookieData> cookies) async {
    final cookieManager = WebViewCookieManager();

    await cookieManager.clearCookies();

    for (final cookie in cookies) {
      await cookieManager.setCookie(
        WebViewCookie(
          name: cookie.name,
          value: cookie.value,
          domain: ServerConstants.vtopDomain,
          path: '/',
        ),
      );
    }
  }

  /// Starts over with a fresh VTOP login.
  void _refreshSession() {
    // Drop the old WebView too: the portal it shows is the one that just
    // failed, and logging in again can take a while.
    _setState(() {
      _isLoading = true;
      _isContentLoaded = false;
      _errorMessage = null;
      _controller = null;
    });
    ref.read(webViewSessionViewModelProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(webViewSessionViewModelProvider, (_, next) {
      if (next case AsyncData(value: final session)) _loadSession(session);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
        title: UrlBar(
          url: _currentUrl,
          isLoading: _isLoading && _isContentLoaded,
          isSecure: _currentUrl.startsWith('https'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller?.reload,
            tooltip: 'Refresh Page',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final session = ref.watch(webViewSessionViewModelProvider);
    final String? error = session?.hasError == true
        ? session!.error.toString()
        : _errorMessage;
    if (error != null) {
      return _buildErrorView(error);
    }

    if (_controller == null) {
      return _buildInitializingView();
    }

    return Stack(
      children: [
        // WebView is always rendered but hidden until content loads
        Opacity(
          opacity: _isContentLoaded ? 1.0 : 0.0,
          child: WebViewWidget(controller: _controller!),
        ),
        // Show loading overlay until content page is loaded
        if (!_isContentLoaded) _buildLoadingOverlay(),
        // Show progress bar when navigating within the portal
        if (_isContentLoaded && _isLoading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _loadingProgress > 0 ? _loadingProgress : null,
            ),
          ),
      ],
    );
  }

  Widget _buildInitializingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initializing VTOP session...'),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Loading VTOP Portal...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we log you in',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (_loadingProgress > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: LinearProgressIndicator(value: _loadingProgress),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load VTOP',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _refreshSession,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
