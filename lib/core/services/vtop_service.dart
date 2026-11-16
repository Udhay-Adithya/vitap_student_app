import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/exceptions.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/utils/device_user_agent.dart';
import 'package:vit_ap_student_app/core/utils/single_flight.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/vtop_client.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/vtop_errors.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart';

part 'vtop_service.g.dart';

/// The app's one VTOP session. [VtopClientService.instance] is already a
/// process-wide singleton; this is how the rest of the app reaches it.
@Riverpod(keepAlive: true)
VtopClientService vtopClientService(Ref ref) => VtopClientService.instance;

/// The bridge calls this service depends on, named so tests can substitute
/// them. Their shapes mirror the generated functions in `vtop_get_client.dart`
/// exactly, so the production defaults are plain tear-offs.
typedef VtopClientFactory =
    VtopClient Function({
      required String username,
      required String password,
      required String userAgent,
    });
typedef VtopLoginCall = Future<void> Function({required VtopClient client});
typedef VtopOtpSubmitCall =
    Future<void> Function({
      required VtopClient client,
      required String otpCode,
    });
typedef VtopOtpResendCall = Future<void> Function({required VtopClient client});

/// Singleton service for managing VTOP client instances
/// Maintains a single VtopClient instance per session and persists login state
/// across multiple requests with the same credentials
///
/// Features:
/// - Automatic session expiry detection (15-minute timeout)
/// - Proactive session renewal before expiry
/// - Automatic retry mechanism for failed requests
/// - Proper error handling and session state management
/// - Transparent OTP handling via Completer pattern

class VtopClientService {
  static VtopClientService? _instance;
  VtopClient? _client;
  bool _isInitialized = false;
  bool _otpPending = false;
  String? _currentUsername;
  String? _currentPasswordDigest;
  DateTime? _sessionCreatedAt;
  Completer<void>? _otpCompleter;

  /// The login currently in flight, if there is one. Every caller that arrives
  /// while a login is running joins this future instead of starting its own.
  ///
  /// This is what stops the duplicate OTP emails. VTOP sends a fresh code for
  /// every credentials POST it sees from an untrusted IP, and each POST opens
  /// its own server session with its own pending code, so two concurrent
  /// logins are two emails of which only one can be the session the OTP sheet
  /// ends up validating — which is why a correctly typed code could come back
  /// as "Invalid OTP". A login is never more useful for being run twice: VTOP
  /// trusts an IP once it has been verified, so joining costs nothing.
  /// See https://github.com/Udhay-Adithya/vitap_student_app/issues/18
  final SingleFlight<String, VtopClient> _loginFlight =
      SingleFlight<String, VtopClient>();

  /// Bumped whenever the session is torn down or a new login is claimed. A
  /// login that finishes after its generation has passed must not write its
  /// result over the session that replaced it.
  int _generation = 0;
  final StreamController<void> _otpRequiredController =
      StreamController<void>.broadcast();
  final StreamController<String> _authFailureController =
      StreamController<String>.broadcast();

  // VTOP sessions expire after 15 minutes, we'll refresh at 14 minutes to be safe
  static const Duration _sessionExpiryDuration = Duration(minutes: 15);
  static const Duration _sessionRefreshThreshold = Duration(minutes: 14);

  final VtopClientFactory _createClient;
  final VtopLoginCall _performLogin;
  final VtopOtpSubmitCall _submitOtp;
  final VtopOtpResendCall _resendOtp;
  final DateTime Function() _now;
  final Future<String> Function() _resolveUserAgent;

  VtopClientService._({
    VtopClientFactory? createClient,
    VtopLoginCall? performLogin,
    VtopOtpSubmitCall? submitOtp,
    VtopOtpResendCall? resendOtp,
    DateTime Function()? now,
    Future<String> Function()? resolveUserAgent,
  }) : _createClient = createClient ?? getVtopClient,
       _performLogin = performLogin ?? vtopClientLogin,
       _submitOtp = submitOtp ?? handleLoginOtp,
       _resendOtp = resendOtp ?? handleLoginOtpResend,
       _now = now ?? DateTime.now,
       _resolveUserAgent = resolveUserAgent ?? getDeviceUserAgent;

  static VtopClientService get instance {
    _instance ??= VtopClientService._();
    return _instance!;
  }

  /// Same as [instance].
  factory VtopClientService() {
    return instance;
  }

  /// An isolated instance with the VTOP bridge calls and the clock replaced.
  ///
  /// Deliberately does not touch [instance]: the singleton the app runs on is
  /// never the one under test, so tests cannot leak session state into each
  /// other or into the running app.
  @visibleForTesting
  factory VtopClientService.withOverrides({
    required VtopClientFactory createClient,
    required VtopLoginCall performLogin,
    VtopOtpSubmitCall? submitOtp,
    VtopOtpResendCall? resendOtp,
    DateTime Function()? now,
    Future<String> Function()? resolveUserAgent,
  }) => VtopClientService._(
    createClient: createClient,
    performLogin: performLogin,
    submitOtp: submitOtp,
    resendOtp: resendOtp,
    now: now,
    resolveUserAgent: resolveUserAgent ?? (() async => 'test-user-agent'),
  );

  /// Compute a SHA-256 digest of a password for change-detection only.
  String _digestOf(String value) =>
      sha256.convert(utf8.encode(value)).toString();

  /// Stream that emits when OTP verification is required.
  /// The global UI listener subscribes to this to show the OTP bottom sheet.
  Stream<void> get onOtpRequired => _otpRequiredController.stream;

  /// Stream that emits the error message when authentication fails due to
  /// invalid credentials or account lock (max attempts reached).
  /// The global UI listener subscribes to show the auth failure bottom sheet.
  Stream<String> get onAuthFailure => _authFailureController.stream;

  /// Get the VTOP client instance, initializing if necessary.
  ///
  /// At most one login runs at a time. A caller that arrives while one is in
  /// flight — including while it is paused waiting for the user to type an OTP
  /// — joins it and gets the same session, rather than starting a second login
  /// and triggering a second OTP email. See [_loginFlight] and [SingleFlight].
  ///
  /// Deliberately **not** `async`: the body must run to the point where the
  /// login slot is claimed without yielding, or a second caller could slip
  /// through the window this method exists to close.
  Future<VtopClient> getClient({
    required String username,
    required String password,
  }) {
    // Safety net: the demo account must never contact VTOP. Feature view models
    // short-circuit to bundled sample data before reaching this point; if any
    // path slips through, fail fast with a friendly message instead of trying
    // to authenticate with placeholder demo credentials.
    if (DemoService.isDemoMode) {
      return Future<VtopClient>.error(const DemoModeException());
    }

    final String passwordDigest = _digestOf(password);

    if (!_needsNewClient(username, passwordDigest)) {
      return Future<VtopClient>.value(_client!);
    }

    final String key = _loginKey(username, passwordDigest);
    final Future<VtopClient>? joined = _loginFlight.pendingFor(key);
    if (joined != null) {
      return joined;
    }

    if (_loginFlight.isRunning) {
      // A login is in flight for *different* credentials: an account or
      // password change. That session is for an account we no longer care
      // about, so drop it and let the new one take over. The generation bump
      // inside resetClient() keeps the abandoned login from writing its result
      // back over ours when it finishes.
      resetClient();
    }

    return _claimLogin(
      key: key,
      username: username,
      password: password,
      passwordDigest: passwordDigest,
    );
  }

  /// Two calls are the same login only if both the account and the password
  /// match — a password change must not join the login it invalidates.
  String _loginKey(String username, String passwordDigest) =>
      '$username:$passwordDigest';

  /// Whether the cached session is unusable for these credentials.
  bool _needsNewClient(String username, String passwordDigest) =>
      _client == null ||
      !_isInitialized ||
      _currentUsername != username ||
      _currentPasswordDigest != passwordDigest ||
      _isSessionNearExpiry();

  /// Take ownership of the single login slot and start logging in.
  Future<VtopClient> _claimLogin({
    required String key,
    required String username,
    required String password,
    required String passwordDigest,
  }) {
    final int generation = ++_generation;

    return _loginFlight.run(
      key,
      () => _initializeClient(
        username: username,
        password: password,
        generation: generation,
      ).then((_) => _client!),
    );
  }

  /// Check if session is near expiry (within refresh threshold)
  bool _isSessionNearExpiry() {
    if (_sessionCreatedAt == null) return true;

    final sessionAge = _now().difference(_sessionCreatedAt!);
    final isNearExpiry = sessionAge >= _sessionRefreshThreshold;

    // Debug logging to understand the issue
    return isNearExpiry;
  }

  /// Check if session is completely expired
  bool _isSessionExpired() {
    if (_sessionCreatedAt == null) return true;

    final sessionAge = _now().difference(_sessionCreatedAt!);
    return sessionAge >= _sessionExpiryDuration;
  }

  /// Get session age as human-readable string
  String _getSessionAge() {
    if (_sessionCreatedAt == null) return 'unknown';

    final sessionAge = _now().difference(_sessionCreatedAt!);
    final hours = sessionAge.inHours;
    final minutes = sessionAge.inMinutes % 60;
    final seconds = sessionAge.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  /// Initialize the VTOP client and login
  /// When OTP is required, pauses and waits for the user to verify via the
  /// global OTP bottom sheet. The operation that triggered this call
  /// transparently resumes once OTP is verified.
  Future<void> _initializeClient({
    required String username,
    required String password,
    required int generation,
  }) async {
    try {
      // Every request on this session carries this identity, and VTOP binds the
      // session to it: the in-app WebView is refused unless it presents the
      // same string. Resolved from the device rather than invented per session.
      final String userAgent = await _resolveUserAgent();

      // Create client
      _client = _createClient(
        username: username,
        password: password,
        userAgent: userAgent,
      );

      // Login
      await _performLogin(client: _client!);

      _throwIfSuperseded(generation);

      // Store current credentials and session timestamp
      _currentUsername = username;
      _currentPasswordDigest = _digestOf(password);
      _sessionCreatedAt = _now();
      _isInitialized = true;
    } on VtopError_AuthenticationFailed catch (e) {
      _clearSessionIfCurrent(generation);
      _authFailureController.add(e.field0);
      rethrow;
    } on VtopError_InvalidCredentials {
      _clearSessionIfCurrent(generation);
      _authFailureController.add('Invalid username or password.');
      rethrow;
    } on VtopError_LoginOtpRequired {
      _throwIfSuperseded(generation);

      // Keep the client alive — OTP must be submitted on the same session
      _currentUsername = username;
      _currentPasswordDigest = _digestOf(password);
      _otpPending = true;
      _otpCompleter = Completer<void>();

      // Notify the global UI listener to show the OTP bottom sheet
      _otpRequiredController.add(null);

      try {
        // Wait for OTP to be resolved (submitLoginOtp completes this). Callers
        // that arrive during this pause join the same login, so nobody
        // starts a competing login — and therefore no second OTP is sent —
        // while the sheet is open.
        await _otpCompleter!.future;
        // OTP verified successfully — session is now established
      } catch (e) {
        // OTP was cancelled — clean up
        if (_clearSessionIfCurrent(generation)) {
          _otpPending = false;
          _otpCompleter = null;
        }
        rethrow;
      }
    } catch (e) {
      _clearSessionIfCurrent(generation);
      rethrow;
    }
  }

  /// Clear the session, unless a newer login already owns it.
  ///
  /// Without the guard, a superseded login failing on its way out wiped the
  /// session that replaced it: switch accounts while the first login is still
  /// in flight, and the second account's freshly established session was torn
  /// down by the first one's error handler a microtask later.
  ///
  /// Returns whether the state was actually cleared.
  bool _clearSessionIfCurrent(int generation) {
    if (_generation != generation) return false;
    _isInitialized = false;
    _client = null;
    _currentUsername = null;
    _currentPasswordDigest = null;
    _sessionCreatedAt = null;
    return true;
  }

  /// Abort a login whose session has since been reset or replaced, so that a
  /// late-finishing login cannot overwrite the newer one.
  void _throwIfSuperseded(int generation) {
    if (_generation != generation) {
      throw Exception(
        'The session was reset while signing in. Please try again.',
      );
    }
  }

  /// Get client from saved credentials
  Future<VtopClient> getClientFromCredentials(Credentials credentials) async {
    return await getClient(
      username: credentials.registrationNumber,
      password: credentials.password,
    );
  }

  /// Execute a VTOP API call with automatic retry on session expiry
  /// This method wraps any VTOP client operation and handles session expiry gracefully
  ///
  /// Example usage:
  /// ```dart
  /// final timetable = await service.executeWithRetry(
  ///   credentials: credentials,
  ///   operation: (client) => client.getTimetable(semesterId),
  /// );
  /// ```
  Future<T> executeWithRetry<T>({
    required Credentials credentials,
    required Future<T> Function(VtopClient client) operation,
    int maxRetries = 2,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        attempts++;
        final client = await getClientFromCredentials(credentials);
        return await operation(client);
      } catch (e) {
        // If this was our last attempt, rethrow the error
        if (attempts >= maxRetries) {
          rethrow;
        }

        // Check if this is a session-related error that we can retry
        if (_isRetryableError(e)) {
          // Never tear down a session another caller is mid-OTP on: that
          // cancels the sheet under them and wastes the code they just
          // received. Leaving it alone means the retry's getClient() joins the
          // pending login instead of starting a second one.
          if (!_otpPending) {
            resetClient();
          }
          // Brief delay before retry to avoid rapid successive requests
          await Future<void>.delayed(const Duration(milliseconds: 500));
        } else {
          // For non-retryable errors, fail immediately
          rethrow;
        }
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// Submit login OTP on the pending client session.
  /// On success, completes the internal Completer, which unblocks the
  /// original getClient/executeWithRetry call transparently.
  Future<void> submitLoginOtp(String otpCode) async {
    if (!_otpPending || _client == null) {
      throw StateError('No OTP-pending session');
    }
    await _submitOtp(client: _client!, otpCode: otpCode);
    _otpPending = false;
    _isInitialized = true;
    _sessionCreatedAt = _now();
    final completer = _otpCompleter;
    _otpCompleter = null;
    completer?.complete();
  }

  /// Resend login OTP on the pending client session
  Future<void> resendLoginOtp() async {
    if (!_otpPending || _client == null) {
      throw StateError('No OTP-pending session');
    }
    await _resendOtp(client: _client!);
  }

  /// Whether an OTP is pending on the current client session
  bool get isOtpPending => _otpPending;

  /// Cancel the pending OTP verification.
  /// Completes the internal Completer with an error so that the blocked
  /// getClient/executeWithRetry call propagates a cancellation failure.
  void cancelOtp() {
    if (!_otpPending || _otpCompleter == null) return;
    _otpPending = false;
    final completer = _otpCompleter!;
    _otpCompleter = null;
    completer.completeError(
      Exception('Login verification was cancelled. Please try again.'),
    );
  }

  /// Check if an error is retryable (session-related).
  ///
  /// Matched on the error *type*, never on its message. A retry means another
  /// credentials POST, and on a network VTOP has not seen before that is
  /// another OTP email — so the set of errors worth paying that for is exactly
  /// one: an expired session. Substring matching used to pull in anything
  /// whose text happened to contain "session" or "expired", including
  /// `LoginOtpExpired` ("OTP for login has expired"), which turned a wrong
  /// moment into a second email.
  bool _isRetryableError(Object error) => error is VtopError_SessionExpired;

  /// Reset the client (for logout or credential changes).
  ///
  /// Bumps the generation so a login still in flight cannot write its result
  /// back over the cleared session once it finishes.
  void resetClient() {
    if (_otpPending && _otpCompleter != null) {
      cancelOtp();
    }
    _generation++;
    _client = null;
    _isInitialized = false;
    _otpPending = false;
    _otpCompleter = null;
    _currentUsername = null;
    _currentPasswordDigest = null;
    _sessionCreatedAt = null;
    _loginFlight.clear();
  }

  /// Get the current client instance if available
  VtopClient? get currentClient => _isInitialized ? _client : null;

  /// Check if client is initialized
  bool get isInitialized => _isInitialized && _client != null;

  /// Check if current session matches provided credentials
  bool hasSessionFor({required String username, required String password}) {
    return _isInitialized &&
        _currentUsername == username &&
        _currentPasswordDigest == _digestOf(password) &&
        !_isSessionExpired();
  }

  /// Get session information for debugging
  Map<String, dynamic> getSessionInfo() {
    return {
      'isInitialized': _isInitialized,
      'hasClient': _client != null,
      'hasUser': _currentUsername != null,
      'sessionCreatedAt': _sessionCreatedAt?.toIso8601String(),
      'sessionAge': _getSessionAge(),
      'isNearExpiry': _isSessionNearExpiry(),
      'isExpired': _isSessionExpired(),
    };
  }

  /// Get time remaining until session expiry
  Duration? getTimeUntilExpiry() {
    if (_sessionCreatedAt == null) return null;

    final expiryTime = _sessionCreatedAt!.add(_sessionExpiryDuration);
    final timeRemaining = expiryTime.difference(_now());

    return timeRemaining.isNegative ? Duration.zero : timeRemaining;
  }

  /// Dispose of the service resources
  void dispose() {
    _otpRequiredController.close();
    _authFailureController.close();
  }
}
