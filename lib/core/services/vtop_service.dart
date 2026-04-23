import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:vit_ap_student_app/core/error/exceptions.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/vtop_client.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/vtop_errors.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart';

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
  DateTime? _otpCanBeRequestedAt;
  Completer<void>? _otpCompleter;
  final StreamController<void> _otpRequiredController =
      StreamController<void>.broadcast();
  final StreamController<String> _authFailureController =
      StreamController<String>.broadcast();

  // VTOP sessions expire after 15 minutes, we'll refresh at 14 minutes to be safe
  static const Duration _sessionExpiryDuration = Duration(minutes: 15);
  static const Duration _sessionRefreshThreshold = Duration(minutes: 14);

  VtopClientService._();

  static VtopClientService get instance {
    _instance ??= VtopClientService._();
    return _instance!;
  }

  // Factory constructor for service locator compatibility
  factory VtopClientService() {
    return instance;
  }

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

  /// Get the VTOP client instance, initializing if necessary
  /// Automatically handles session expiry and re-authentication
  /// If OTP is pending, waits for OTP resolution before returning
  Future<VtopClient> getClient({
    required String username,
    required String password,
  }) async {
    // If OTP is pending, wait for resolution instead of returning partial client
    if (_otpPending && _otpCompleter != null) {
      await _otpCompleter!.future;
      if (_client != null && _isInitialized) {
        return _client!;
      }
    }

    final bool needsNewClient =
        _client == null ||
        !_isInitialized ||
        _currentUsername != username ||
        _currentPasswordDigest != _digestOf(password) ||
        _isSessionNearExpiry();

    if (needsNewClient) {
      await _initializeClient(username: username, password: password);
    }

    return _client!;
  }

  /// Check if session is near expiry (within refresh threshold)
  bool _isSessionNearExpiry() {
    if (_sessionCreatedAt == null) return true;

    final sessionAge = DateTime.now().difference(_sessionCreatedAt!);
    final isNearExpiry = sessionAge >= _sessionRefreshThreshold;

    // Debug logging to understand the issue
    return isNearExpiry;
  }

  /// Check if session is completely expired
  bool _isSessionExpired() {
    if (_sessionCreatedAt == null) return true;

    final sessionAge = DateTime.now().difference(_sessionCreatedAt!);
    return sessionAge >= _sessionExpiryDuration;
  }

  /// Get session age as human-readable string
  String _getSessionAge() {
    if (_sessionCreatedAt == null) return 'unknown';

    final sessionAge = DateTime.now().difference(_sessionCreatedAt!);
    final hours = sessionAge.inHours;
    final minutes = sessionAge.inMinutes % 60;
    final seconds = sessionAge.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  /// Get reason for client creation (for debugging)
  String _getClientCreationReason(String username, String password) {
    if (_client == null) return 'No existing client';
    if (!_isInitialized) return 'Not initialized';
    if (_currentUsername != username ||
        _currentPasswordDigest != _digestOf(password)) {
      return 'Different credentials';
    }
    if (_isSessionExpired()) {
      return 'Session expired (${_getSessionAge()})';
    }
    if (_isSessionNearExpiry()) {
      return 'Session near expiry (${_getSessionAge()})';
    }
    return 'Unknown reason';
  }

  /// Initialize the VTOP client and login
  /// When OTP is required, pauses and waits for the user to verify via the
  /// global OTP bottom sheet. The operation that triggered this call
  /// transparently resumes once OTP is verified.
  Future<void> _initializeClient({
    required String username,
    required String password,
  }) async {
    try {
      // Create client
      _client = getVtopClient(username: username, password: password);

      // Login
      await vtopClientLogin(client: _client!);

      // Store current credentials and session timestamp
      _currentUsername = username;
      _currentPasswordDigest = _digestOf(password);
      _sessionCreatedAt = DateTime.now();
      _isInitialized = true;
    } on VtopError_AuthenticationFailed catch (e) {
      _isInitialized = false;
      _client = null;
      _currentUsername = null;
      _currentPasswordDigest = null;
      _sessionCreatedAt = null;
      _authFailureController.add(e.field0);
      rethrow;
    } on VtopError_InvalidCredentials {
      _isInitialized = false;
      _client = null;
      _currentUsername = null;
      _currentPasswordDigest = null;
      _sessionCreatedAt = null;
      _authFailureController.add('Invalid username or password.');
      rethrow;
    } on VtopError_LoginOtpRequired {
      // Keep the client alive — OTP must be submitted on the same session
      _currentUsername = username;
      _currentPasswordDigest = _digestOf(password);
      _otpPending = true;
      _otpCanBeRequestedAt = DateTime.now().add(const Duration(seconds: 180));
      _otpCompleter = Completer<void>();

      // Notify the global UI listener to show the OTP bottom sheet
      _otpRequiredController.add(null);

      try {
        // Wait for OTP to be resolved (submitLoginOtp completes this)
        await _otpCompleter!.future;
        // OTP verified successfully — session is now established
      } catch (e) {
        // OTP was cancelled — clean up
        _isInitialized = false;
        _client = null;
        _currentUsername = null;
        _currentPasswordDigest = null;
        _sessionCreatedAt = null;
        _otpPending = false;
        _otpCompleter = null;
        rethrow;
      }
    } catch (e) {
      _isInitialized = false;
      _client = null;
      _currentUsername = null;
      _currentPasswordDigest = null;
      _sessionCreatedAt = null;
      rethrow;
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
          resetClient();
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
    await handleLoginOtp(client: _client!, otpCode: otpCode);
    _otpPending = false;
    _isInitialized = true;
    _sessionCreatedAt = DateTime.now();
    final completer = _otpCompleter;
    _otpCompleter = null;
    completer?.complete();
  }

  /// Resend login OTP on the pending client session
  Future<void> resendLoginOtp() async {
    if (!_otpPending || _client == null) {
      throw StateError('No OTP-pending session');
    }else if (_otpCanBeRequestedAt != null && DateTime.now().isBefore(_otpCanBeRequestedAt!)) {
      final waitDuration = _otpCanBeRequestedAt!.difference(DateTime.now());
      throw OtpResendException('OTP can be resent in ${waitDuration.inSeconds} seconds');
    }
    await handleLoginOtpResend(client: _client!);
    _otpCanBeRequestedAt = DateTime.now().add(const Duration(seconds: 180));
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

  /// Check if an error is retryable (session-related)
  bool _isRetryableError(dynamic error) {
    // OTP and auth errors are not retryable — they require user interaction.
    // Retrying auth failures worsens account locks.
    if (error is VtopError_LoginOtpRequired ||
        error is VtopError_LoginOtpIncorrect ||
        error is VtopError_LoginOtpExpired ||
        error is VtopError_AuthenticationFailed ||
        error is VtopError_InvalidCredentials) {
      return false;
    }

    final errorString = error.toString().toLowerCase();

    // Only session expiry is retryable — not auth failures
    return errorString.contains('session') ||
        errorString.contains('expired') ||
        errorString.contains('unauthorized');
  }

  /// Reset the client (for logout or credential changes)
  void resetClient() {
    if (_otpPending && _otpCompleter != null) {
      cancelOtp();
    }
    _client = null;
    _isInitialized = false;
    _otpPending = false;
    _otpCompleter = null;
    _currentUsername = null;
    _currentPasswordDigest = null;
    _sessionCreatedAt = null;
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
    final timeRemaining = expiryTime.difference(DateTime.now());

    return timeRemaining.isNegative ? Duration.zero : timeRemaining;
  }

  /// Dispose of the service resources
  void dispose() {
    _otpRequiredController.close();
    _authFailureController.close();
  }
}
