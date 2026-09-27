import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/vtop_errors.dart';

/// Turns whatever a repository call threw into the [Failure] a student sees.
///
/// [unexpected] words the message for anything nothing here recognises. By
/// default it is `'Unexpected error: <error>'`.
///
/// Call-specific cases — an OTP the upload flow handles itself, the outing
/// form VTOP only serves Tue–Sat — are caught before this, at the call site.
Failure failureFrom(
  Object error, {
  String Function(Object error) unexpected = _unexpectedError,
}) {
  if (error is! SocketException) debugPrint('Repository call failed: $error');

  return Failure(switch (error) {
    SocketException() => 'No internet connection',
    VtopError() => vtopErrorMessage(error),
    FormatException() => 'Invalid response format from server',
    _ => unexpected(error),
  });
}

String _unexpectedError(Object error) => 'Unexpected error: $error';

/// VTOP's own wording when an account is locked after too many failed logins.
///
/// Passed through untouched: it carries the unlock time, which no canned
/// message can.
const _lockoutMarker = 'Number Of Maximum Fail Attempts Reached';

/// The message shown for a [VtopError].
///
/// Deliberately exhaustive, with no default: a variant added in Rust is a
/// compile error here instead of silently reaching the student as whatever
/// the fallback happens to say.
String vtopErrorMessage(VtopError error) => switch (error) {
  VtopError_AuthenticationFailed(:final field0)
      when field0.contains(_lockoutMarker) =>
    'Authentication failed: $field0',
  VtopError_ParseError(:final field0) when field0.contains(_lockoutMarker) =>
    'Parse error: $field0',
  VtopError_ConfigurationError(:final field0)
      when field0.contains(_lockoutMarker) =>
    'Configuration error: $field0',
  VtopError_NetworkError() =>
    'No internet connection. Please check your network and try again.',
  VtopError_TimeoutError() =>
    'Connection timed out. The server is taking too long to respond. '
        'Please try again.',
  VtopError_SslError() =>
    'Secure connection failed. There may be an issue with the server\'s '
        'security certificate. Please try again later.',
  VtopError_DnsError() =>
    'Could not reach the server. Please check your internet connection or '
        'try again later.',
  VtopError_ConnectionRefused() =>
    'Unable to connect to VTOP server. The server may be down for '
        'maintenance. Please try again later.',
  VtopError_ResponseReadError() =>
    'Failed to read server response. Please try again.',
  VtopError_AuthenticationFailed() || VtopError_InvalidCredentials() =>
    'Invalid username or password. Please check your credentials and try '
        'again.',
  VtopError_SessionExpired() =>
    'Your session has expired. The app will automatically retry with a '
        'fresh session.',
  VtopError_CaptchaRequired() =>
    'Captcha verification is required. Please complete the captcha and try '
        'again.',
  VtopError_VtopServerError() =>
    'VTOP server is temporarily unavailable. The app will automatically '
        'retry.',
  VtopError_RegistrationParsingError() =>
    'Invalid registration number format. Please check your registration '
        'number.',
  VtopError_ParseError() =>
    'Unable to process server response. Please try again.',
  VtopError_ConfigurationError() =>
    'App configuration error. Please restart the app and try again.',
  VtopError_InvalidResponse() =>
    'Received invalid response from server. Please try again.',
  VtopError_LoginOtpRequired() => 'OTP verification is required for login.',
  VtopError_LoginOtpIncorrect() =>
    'Incorrect OTP entered for login. Please try again.',
  VtopError_LoginOtpExpired() =>
    'OTP for login has expired. Please request a new OTP and try again.',
  VtopError_InvalidSemesterId() =>
    'That semester could not be recognised. Please pick one from the '
        'semester list.',
  VtopError_MenuUnavailable() =>
    'VTOP is not serving this page right now. Please try again later.',
  VtopError_DigitalAssignmentFileNotFound() =>
    'Selected file is inaccessible or does not exist.',
  VtopError_DigitalAssignmentFileTypeNotSupported() =>
    'File type should be pdf, xls, xlsx, doc or docx.',
  VtopError_DigitalAssignmentFileSizeExceeded() =>
    'File size should not exceed 4 MB.',
  VtopError_DigitalAssignmentUploadOtpRequired() =>
    'OTP verification is required to upload this assignment.',
  VtopError_DigitalAssignmentUploadIncorrectOtp() =>
    'Incorrect OTP entered. Please try again.',
};
