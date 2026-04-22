import 'package:flutter/foundation.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/vtop_errors.dart';

class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class OtpResendException implements Exception {
  final String message;
  const OtpResendException(this.message);

  @override
  String toString() => message;
}

class SecureStorageException implements Exception {
  final String message;
  SecureStorageException(this.message);

  @override
  String toString() => 'SecureStorageException: $message';
}

/// Wrapper class to provide consistent error handling for VTOP errors
/// This converts VtopError (from Rust) into a standard Dart Exception
class VtopException implements Exception {
  final VtopError _error;
  String? _cachedMessage;
  String? _cachedErrorType;

  VtopException(this._error);

  /// Get user-friendly error message (cached after first call)
  Future<String> get message async {
    _cachedMessage ??= await _error.message();
    return _cachedMessage!;
  }

  /// Get error type for programmatic handling (cached after first call)
  Future<String> get errorType async {
    _cachedErrorType ??= await _error.errorType();
    return _cachedErrorType!;
  }

  /// Get debug message for logging (not cached)
  Future<String> get debugMessage async {
    return await _error.debugMessage();
  }

  /// Access the original VtopError for pattern matching
  VtopError get originalError => _error;

  /// Synchronous toString for logging (uses cached message if available)
  @override
  String toString() {
    if (_cachedMessage != null) {
      return 'VtopException: $_cachedMessage';
    }
    return 'VtopException: ${_error.runtimeType}';
  }

  /// Convenience method to create VtopException from VtopError
  static VtopException from(VtopError error) => VtopException(error);

  /// Static method to handle VtopError and convert to appropriate Failure message
  static Future<String> getFailureMessage(VtopError error) async {
    final vtopException = VtopException.from(error);
    final errorType = await vtopException.errorType;
    // final message = await vtopException.message;

    // Log for debugging purposes (not shown to user)
    final debugMessage = await vtopException.debugMessage;
    debugPrint('VTOP Error [$errorType]: $debugMessage');

    // Return appropriate failure message based on error type
    return _createFailureMessage(errorType, debugMessage);
  }

  /// Check if this error indicates session expiry or authentication issues
  static Future<bool> isSessionRelatedError(VtopError error) async {
    final vtopException = VtopException.from(error);
    final errorType = await vtopException.errorType;

    return errorType == 'SessionExpired' ||
        errorType == 'AuthenticationFailed' ||
        errorType == 'InvalidCredentials';
  }

  /// Check if this error should trigger a retry with a fresh session
  static Future<bool> isRetryableError(VtopError error) async {
    final vtopException = VtopException.from(error);
    final errorType = await vtopException.errorType;

    // These errors can be resolved by creating a fresh session or retrying
    return errorType == 'SessionExpired' ||
        errorType == 'AuthenticationFailed' ||
        errorType == 'InvalidCredentials' ||
        errorType ==
            'VtopServerError' || // Sometimes server errors are transient
        errorType == 'TimeoutError' || // Timeouts may succeed on retry
        errorType ==
            'ResponseReadError'; // Response read errors may be transient
  }

  /// Check if this is a network-related error that might resolve itself
  static Future<bool> isNetworkRelatedError(VtopError error) async {
    final vtopException = VtopException.from(error);
    final errorType = await vtopException.errorType;

    return errorType == 'NetworkError' ||
        errorType == 'TimeoutError' ||
        errorType == 'SslError' ||
        errorType == 'DnsError' ||
        errorType == 'ConnectionRefused' ||
        errorType == 'ResponseReadError';
  }

  /// Create appropriate failure message based on VtopError type
  static String _createFailureMessage(String errorType, String message) {
    if (message.contains('Number Of Maximum Fail Attempts Reached')) {
      return message;
    }
    switch (errorType) {
      case 'NetworkError':
        return 'No internet connection. Please check your network and try again.';

      case 'TimeoutError':
        return 'Connection timed out. The server is taking too long to respond. Please try again.';

      case 'SslError':
        return "Secure connection failed. There may be an issue with the server's security certificate. Please try again later.";

      case 'DnsError':
        return 'Could not reach the server. Please check your internet connection or try again later.';

      case 'ConnectionRefused':
        return 'Unable to connect to VTOP server. The server may be down for maintenance. Please try again later.';

      case 'ResponseReadError':
        return 'Failed to read server response. Please try again.';

      case 'AuthenticationFailed':
      case 'InvalidCredentials':
        return 'Invalid username or password. Please check your credentials and try again.';

      case 'SessionExpired':
        return 'Your session has expired. The app will automatically retry with a fresh session.';

      case 'CaptchaRequired':
        return 'Captcha verification is required. Please complete the captcha and try again.';

      case 'VtopServerError':
        return 'VTOP server is temporarily unavailable. The app will automatically retry.';

      case 'RegistrationParsingError':
        return 'Invalid registration number format. Please check your registration number.';

      case 'ParseError':
        return 'Unable to process server response. Please try again.';

      case 'ConfigurationError':
        return 'App configuration error. Please restart the app and try again.';

      case 'InvalidResponse':
        return 'Received invalid response from server. Please try again.';

      case 'LoginOtpRequired':
        return 'OTP verification is required for login.';

      case 'LoginOtpIncorrect':
        return 'Incorrect OTP entered for login. Please try again.';

      case 'LoginOtpExpired':
        return 'OTP for login has expired. Please request a new OTP and try again.';

      default:
        // For any unknown error types, return the user-friendly message from Rust
        return message;
    }
  }

  /// Check if this is a specific error type without async
  bool isErrorType(String type) {
    return _cachedErrorType == type;
  }

  /// Quick checks for common error types (requires errorType to be cached)
  bool get isNetworkError => _cachedErrorType == 'NetworkError';
  bool get isTimeoutError => _cachedErrorType == 'TimeoutError';
  bool get isSslError => _cachedErrorType == 'SslError';
  bool get isDnsError => _cachedErrorType == 'DnsError';
  bool get isConnectionRefused => _cachedErrorType == 'ConnectionRefused';
  bool get isResponseReadError => _cachedErrorType == 'ResponseReadError';
  bool get isAuthenticationError => _cachedErrorType == 'AuthenticationFailed';
  bool get isSessionExpired => _cachedErrorType == 'SessionExpired';
  bool get isCaptchaRequired => _cachedErrorType == 'CaptchaRequired';
  bool get isInvalidCredentials => _cachedErrorType == 'InvalidCredentials';
  bool get isVtopServerError => _cachedErrorType == 'VtopServerError';

  /// Check if this is any kind of connectivity issue
  bool get isConnectivityIssue =>
      isNetworkError ||
      isTimeoutError ||
      isSslError ||
      isDnsError ||
      isConnectionRefused ||
      isResponseReadError;
}

/// Exception for general app errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    if (code != null) {
      return 'AppException($code): $message';
    }
    return 'AppException: $message';
  }
}

/// Exception for network-related errors
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(
    this.message, {
    this.statusCode,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'NetworkException($statusCode): $message';
    }
    return 'NetworkException: $message';
  }
}

/// Exception for validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(
    this.message, {
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message';
}
