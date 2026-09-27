class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class SecureStorageException implements Exception {
  final String message;
  SecureStorageException(this.message);

  @override
  String toString() => 'SecureStorageException: $message';
}

/// Exception thrown when a live VTOP operation is attempted while the app is
/// running in demo mode. Demo sessions never contact VTOP; this acts as a
/// safety net so any un-gated code path fails fast with a friendly message
/// instead of trying to authenticate with placeholder demo credentials.
class DemoModeException implements Exception {
  final String message;
  const DemoModeException([
    this.message = 'This feature is not available in the demo account.',
  ]);

  @override
  String toString() => 'DemoModeException: $message';
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
