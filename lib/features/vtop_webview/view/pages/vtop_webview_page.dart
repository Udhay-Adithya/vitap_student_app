import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/constants/server_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/secure_store_service.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/core/utils/device_user_agent.dart';
import 'package:vit_ap_student_app/features/vtop_webview/models/webview_cookie_data.dart';
import 'package:vit_ap_student_app/features/vtop_webview/view/widgets/url_bar.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart';
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
    _initializeWebView();
    AnalyticsService.logScreen('VtopWebViewPage');
  }

  /// Initialize the WebView with cookies from the authenticated Rust session
  Future<void> _initializeWebView() async {
    try {
      setState(() {
        _isLoading = true;
        _isContentLoaded = false;
        _errorMessage = null;
      });

      // Get credentials from secure storage
      final credentials =
          await serviceLocator<SecureStorageService>().getCredentials();

      if (credentials == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No credentials found. Please login first.';
        });
        return;
      }

      // Get or create an authenticated VTOP client
      final vtopService = serviceLocator<VtopClientService>();
      final client = await vtopService.getClientFromCredentials(credentials);

      // Check if client is authenticated
      final isAuth = await fetchIsAuth(client: client);
      if (!isAuth) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Session not authenticated. Please refresh.';
        });
        return;
      }

      // Fetch cookies from the authenticated session
      final cookieBytes = await fetchCookies(client: client);
      final cookieString = String.fromCharCodes(cookieBytes);

      if (cookieString.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No session cookies found. Please refresh.';
        });
        return;
      }

      // Get CSRF token and username from Rust session
      _csrfToken = await fetchCsrfToken(client: client);
      _authorizedId = await fetchUsername(client: client);

      await _injectCookies(cookieString);

      final userAgent = await getDeviceUserAgent();

      // Create and configure the WebView controller
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              setState(() {
                _loadingProgress = progress / 100;
              });
            },
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
                _currentUrl = url;
              });
              debugPrint('Page started: $url');
            },
            onPageFinished: (String url) async {
              setState(() {
                _isLoading = false;
                _currentUrl = url;
              });
              debugPrint('Page finished: $url');

              // Extract CSRF token from the page for potential future use
              await _extractCsrfToken();

              // If we're on the open/page, auto-navigate to content page
              if (url.contains(ServerConstants.vtopOpenPage) &&
                  _csrfToken != null) {
                debugPrint('On open page with CSRF, navigating to content...');
                await Future<void>.delayed(const Duration(milliseconds: 300));
                await _navigateWithPost(ServerConstants.vtopContentPage);
              }
              // Content page loaded - reveal the WebView!
              else if (url.contains(ServerConstants.vtopContentPage)) {
                debugPrint('Content page loaded - showing WebView');
                setState(() {
                  _isContentLoaded = true;
                });
              }
              // Check if redirected to login page (session expired)
              else if (url.contains(ServerConstants.vtopLoginPage) ||
                  url.contains(ServerConstants.vtopPreLoginPage)) {
                debugPrint(
                    'Detected login/prelogin page - session may have expired');
                setState(() {
                  _errorMessage =
                      'Session expired. Please go back and try again.';
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('WebView error: ${error.description}');
              // Only show error if it's a main frame error
              if (error.isForMainFrame ?? false) {
                setState(() {
                  _errorMessage = 'Failed to load page: ${error.description}';
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              debugPrint('Navigation request: ${request.url}');
              // Allow all VTOP navigation
              if (request.url.startsWith(ServerConstants.vtopBaseUrl)) {
                return NavigationDecision.navigate;
              }
              // Block external links
              debugPrint('Blocked external navigation: ${request.url}');
              return NavigationDecision.prevent;
            },
       
          ),
        )
        .. setUserAgent(userAgent);

      // Load the VTOP open page to establish cookie context
      // The authenticated cookies + CSRF from Rust will be used for POST navigation
      await _controller!.loadRequest(
        Uri.parse(
            '${ServerConstants.vtopBaseUrl}${ServerConstants.vtopOpenPage}'),
      );

      // Wait a moment for page load, then navigate to timetable/semester selection page
      // which will show us the authenticated dashboard
      await Future<void>.delayed(const Duration(milliseconds: 500));

      setState(() {});
    } catch (e) {
      debugPrint('Error initializing WebView: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load VTOP: ${e.toString()}';
      });
    }
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
      if (token.isNotEmpty) {
        _csrfToken = token;
      }
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

  Future<void> _navigateWithPost(String path,
      {Map<String, String>? additionalParams, bool verifyMenu = true}) async {
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
        .map((e) =>
            '<input type="hidden" name="${_htmlAttrEscape(e.key)}" value="${_htmlAttrEscape(e.value)}">')
        .join('');

    final jsCode = '''
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

  /// Parse the cookie string and inject each cookie into the WebView
  Future<void> _injectCookies(String cookieString) async {
    final cookieManager = WebViewCookieManager();

    await cookieManager.clearCookies();

    final cookies = parseCookieString(cookieString);

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

  /// Refresh the session by resetting the client and reinitializing
  Future<void> _refreshSession() async {
    serviceLocator<VtopClientService>().resetClient();
    await _initializeWebView();
  }

  @override
  Widget build(BuildContext context) {
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
    if (_errorMessage != null) {
      return _buildErrorView();
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

  Widget _buildErrorView() {
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
              _errorMessage ?? 'An unknown error occurred',
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
