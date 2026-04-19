// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vtop_errors.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VtopError {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError()';
}


}

/// @nodoc
class $VtopErrorCopyWith<$Res>  {
$VtopErrorCopyWith(VtopError _, $Res Function(VtopError) __);
}


/// Adds pattern-matching-related methods to [VtopError].
extension VtopErrorPatterns on VtopError {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VtopError_NetworkError value)?  networkError,TResult Function( VtopError_TimeoutError value)?  timeoutError,TResult Function( VtopError_SslError value)?  sslError,TResult Function( VtopError_DnsError value)?  dnsError,TResult Function( VtopError_ConnectionRefused value)?  connectionRefused,TResult Function( VtopError_VtopServerError value)?  vtopServerError,TResult Function( VtopError_AuthenticationFailed value)?  authenticationFailed,TResult Function( VtopError_RegistrationParsingError value)?  registrationParsingError,TResult Function( VtopError_InvalidCredentials value)?  invalidCredentials,TResult Function( VtopError_SessionExpired value)?  sessionExpired,TResult Function( VtopError_ParseError value)?  parseError,TResult Function( VtopError_ConfigurationError value)?  configurationError,TResult Function( VtopError_CaptchaRequired value)?  captchaRequired,TResult Function( VtopError_InvalidResponse value)?  invalidResponse,TResult Function( VtopError_ResponseReadError value)?  responseReadError,TResult Function( VtopError_DigitalAssignmentFileNotFound value)?  digitalAssignmentFileNotFound,TResult Function( VtopError_DigitalAssignmentFileTypeNotSupported value)?  digitalAssignmentFileTypeNotSupported,TResult Function( VtopError_DigitalAssignmentFileSizeExceeded value)?  digitalAssignmentFileSizeExceeded,TResult Function( VtopError_DigitalAssignmentUploadOtpRequired value)?  digitalAssignmentUploadOtpRequired,TResult Function( VtopError_DigitalAssignmentUploadIncorrectOtp value)?  digitalAssignmentUploadIncorrectOtp,TResult Function( VtopError_LoginOtpRequired value)?  loginOtpRequired,TResult Function( VtopError_LoginOtpIncorrect value)?  loginOtpIncorrect,TResult Function( VtopError_LoginOtpExpired value)?  loginOtpExpired,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VtopError_NetworkError() when networkError != null:
return networkError(_that);case VtopError_TimeoutError() when timeoutError != null:
return timeoutError(_that);case VtopError_SslError() when sslError != null:
return sslError(_that);case VtopError_DnsError() when dnsError != null:
return dnsError(_that);case VtopError_ConnectionRefused() when connectionRefused != null:
return connectionRefused(_that);case VtopError_VtopServerError() when vtopServerError != null:
return vtopServerError(_that);case VtopError_AuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that);case VtopError_RegistrationParsingError() when registrationParsingError != null:
return registrationParsingError(_that);case VtopError_InvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case VtopError_SessionExpired() when sessionExpired != null:
return sessionExpired(_that);case VtopError_ParseError() when parseError != null:
return parseError(_that);case VtopError_ConfigurationError() when configurationError != null:
return configurationError(_that);case VtopError_CaptchaRequired() when captchaRequired != null:
return captchaRequired(_that);case VtopError_InvalidResponse() when invalidResponse != null:
return invalidResponse(_that);case VtopError_ResponseReadError() when responseReadError != null:
return responseReadError(_that);case VtopError_DigitalAssignmentFileNotFound() when digitalAssignmentFileNotFound != null:
return digitalAssignmentFileNotFound(_that);case VtopError_DigitalAssignmentFileTypeNotSupported() when digitalAssignmentFileTypeNotSupported != null:
return digitalAssignmentFileTypeNotSupported(_that);case VtopError_DigitalAssignmentFileSizeExceeded() when digitalAssignmentFileSizeExceeded != null:
return digitalAssignmentFileSizeExceeded(_that);case VtopError_DigitalAssignmentUploadOtpRequired() when digitalAssignmentUploadOtpRequired != null:
return digitalAssignmentUploadOtpRequired(_that);case VtopError_DigitalAssignmentUploadIncorrectOtp() when digitalAssignmentUploadIncorrectOtp != null:
return digitalAssignmentUploadIncorrectOtp(_that);case VtopError_LoginOtpRequired() when loginOtpRequired != null:
return loginOtpRequired(_that);case VtopError_LoginOtpIncorrect() when loginOtpIncorrect != null:
return loginOtpIncorrect(_that);case VtopError_LoginOtpExpired() when loginOtpExpired != null:
return loginOtpExpired(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VtopError_NetworkError value)  networkError,required TResult Function( VtopError_TimeoutError value)  timeoutError,required TResult Function( VtopError_SslError value)  sslError,required TResult Function( VtopError_DnsError value)  dnsError,required TResult Function( VtopError_ConnectionRefused value)  connectionRefused,required TResult Function( VtopError_VtopServerError value)  vtopServerError,required TResult Function( VtopError_AuthenticationFailed value)  authenticationFailed,required TResult Function( VtopError_RegistrationParsingError value)  registrationParsingError,required TResult Function( VtopError_InvalidCredentials value)  invalidCredentials,required TResult Function( VtopError_SessionExpired value)  sessionExpired,required TResult Function( VtopError_ParseError value)  parseError,required TResult Function( VtopError_ConfigurationError value)  configurationError,required TResult Function( VtopError_CaptchaRequired value)  captchaRequired,required TResult Function( VtopError_InvalidResponse value)  invalidResponse,required TResult Function( VtopError_ResponseReadError value)  responseReadError,required TResult Function( VtopError_DigitalAssignmentFileNotFound value)  digitalAssignmentFileNotFound,required TResult Function( VtopError_DigitalAssignmentFileTypeNotSupported value)  digitalAssignmentFileTypeNotSupported,required TResult Function( VtopError_DigitalAssignmentFileSizeExceeded value)  digitalAssignmentFileSizeExceeded,required TResult Function( VtopError_DigitalAssignmentUploadOtpRequired value)  digitalAssignmentUploadOtpRequired,required TResult Function( VtopError_DigitalAssignmentUploadIncorrectOtp value)  digitalAssignmentUploadIncorrectOtp,required TResult Function( VtopError_LoginOtpRequired value)  loginOtpRequired,required TResult Function( VtopError_LoginOtpIncorrect value)  loginOtpIncorrect,required TResult Function( VtopError_LoginOtpExpired value)  loginOtpExpired,}){
final _that = this;
switch (_that) {
case VtopError_NetworkError():
return networkError(_that);case VtopError_TimeoutError():
return timeoutError(_that);case VtopError_SslError():
return sslError(_that);case VtopError_DnsError():
return dnsError(_that);case VtopError_ConnectionRefused():
return connectionRefused(_that);case VtopError_VtopServerError():
return vtopServerError(_that);case VtopError_AuthenticationFailed():
return authenticationFailed(_that);case VtopError_RegistrationParsingError():
return registrationParsingError(_that);case VtopError_InvalidCredentials():
return invalidCredentials(_that);case VtopError_SessionExpired():
return sessionExpired(_that);case VtopError_ParseError():
return parseError(_that);case VtopError_ConfigurationError():
return configurationError(_that);case VtopError_CaptchaRequired():
return captchaRequired(_that);case VtopError_InvalidResponse():
return invalidResponse(_that);case VtopError_ResponseReadError():
return responseReadError(_that);case VtopError_DigitalAssignmentFileNotFound():
return digitalAssignmentFileNotFound(_that);case VtopError_DigitalAssignmentFileTypeNotSupported():
return digitalAssignmentFileTypeNotSupported(_that);case VtopError_DigitalAssignmentFileSizeExceeded():
return digitalAssignmentFileSizeExceeded(_that);case VtopError_DigitalAssignmentUploadOtpRequired():
return digitalAssignmentUploadOtpRequired(_that);case VtopError_DigitalAssignmentUploadIncorrectOtp():
return digitalAssignmentUploadIncorrectOtp(_that);case VtopError_LoginOtpRequired():
return loginOtpRequired(_that);case VtopError_LoginOtpIncorrect():
return loginOtpIncorrect(_that);case VtopError_LoginOtpExpired():
return loginOtpExpired(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VtopError_NetworkError value)?  networkError,TResult? Function( VtopError_TimeoutError value)?  timeoutError,TResult? Function( VtopError_SslError value)?  sslError,TResult? Function( VtopError_DnsError value)?  dnsError,TResult? Function( VtopError_ConnectionRefused value)?  connectionRefused,TResult? Function( VtopError_VtopServerError value)?  vtopServerError,TResult? Function( VtopError_AuthenticationFailed value)?  authenticationFailed,TResult? Function( VtopError_RegistrationParsingError value)?  registrationParsingError,TResult? Function( VtopError_InvalidCredentials value)?  invalidCredentials,TResult? Function( VtopError_SessionExpired value)?  sessionExpired,TResult? Function( VtopError_ParseError value)?  parseError,TResult? Function( VtopError_ConfigurationError value)?  configurationError,TResult? Function( VtopError_CaptchaRequired value)?  captchaRequired,TResult? Function( VtopError_InvalidResponse value)?  invalidResponse,TResult? Function( VtopError_ResponseReadError value)?  responseReadError,TResult? Function( VtopError_DigitalAssignmentFileNotFound value)?  digitalAssignmentFileNotFound,TResult? Function( VtopError_DigitalAssignmentFileTypeNotSupported value)?  digitalAssignmentFileTypeNotSupported,TResult? Function( VtopError_DigitalAssignmentFileSizeExceeded value)?  digitalAssignmentFileSizeExceeded,TResult? Function( VtopError_DigitalAssignmentUploadOtpRequired value)?  digitalAssignmentUploadOtpRequired,TResult? Function( VtopError_DigitalAssignmentUploadIncorrectOtp value)?  digitalAssignmentUploadIncorrectOtp,TResult? Function( VtopError_LoginOtpRequired value)?  loginOtpRequired,TResult? Function( VtopError_LoginOtpIncorrect value)?  loginOtpIncorrect,TResult? Function( VtopError_LoginOtpExpired value)?  loginOtpExpired,}){
final _that = this;
switch (_that) {
case VtopError_NetworkError() when networkError != null:
return networkError(_that);case VtopError_TimeoutError() when timeoutError != null:
return timeoutError(_that);case VtopError_SslError() when sslError != null:
return sslError(_that);case VtopError_DnsError() when dnsError != null:
return dnsError(_that);case VtopError_ConnectionRefused() when connectionRefused != null:
return connectionRefused(_that);case VtopError_VtopServerError() when vtopServerError != null:
return vtopServerError(_that);case VtopError_AuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that);case VtopError_RegistrationParsingError() when registrationParsingError != null:
return registrationParsingError(_that);case VtopError_InvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case VtopError_SessionExpired() when sessionExpired != null:
return sessionExpired(_that);case VtopError_ParseError() when parseError != null:
return parseError(_that);case VtopError_ConfigurationError() when configurationError != null:
return configurationError(_that);case VtopError_CaptchaRequired() when captchaRequired != null:
return captchaRequired(_that);case VtopError_InvalidResponse() when invalidResponse != null:
return invalidResponse(_that);case VtopError_ResponseReadError() when responseReadError != null:
return responseReadError(_that);case VtopError_DigitalAssignmentFileNotFound() when digitalAssignmentFileNotFound != null:
return digitalAssignmentFileNotFound(_that);case VtopError_DigitalAssignmentFileTypeNotSupported() when digitalAssignmentFileTypeNotSupported != null:
return digitalAssignmentFileTypeNotSupported(_that);case VtopError_DigitalAssignmentFileSizeExceeded() when digitalAssignmentFileSizeExceeded != null:
return digitalAssignmentFileSizeExceeded(_that);case VtopError_DigitalAssignmentUploadOtpRequired() when digitalAssignmentUploadOtpRequired != null:
return digitalAssignmentUploadOtpRequired(_that);case VtopError_DigitalAssignmentUploadIncorrectOtp() when digitalAssignmentUploadIncorrectOtp != null:
return digitalAssignmentUploadIncorrectOtp(_that);case VtopError_LoginOtpRequired() when loginOtpRequired != null:
return loginOtpRequired(_that);case VtopError_LoginOtpIncorrect() when loginOtpIncorrect != null:
return loginOtpIncorrect(_that);case VtopError_LoginOtpExpired() when loginOtpExpired != null:
return loginOtpExpired(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  networkError,TResult Function()?  timeoutError,TResult Function()?  sslError,TResult Function()?  dnsError,TResult Function()?  connectionRefused,TResult Function()?  vtopServerError,TResult Function( String field0)?  authenticationFailed,TResult Function()?  registrationParsingError,TResult Function()?  invalidCredentials,TResult Function()?  sessionExpired,TResult Function( String field0)?  parseError,TResult Function( String field0)?  configurationError,TResult Function()?  captchaRequired,TResult Function()?  invalidResponse,TResult Function()?  responseReadError,TResult Function()?  digitalAssignmentFileNotFound,TResult Function()?  digitalAssignmentFileTypeNotSupported,TResult Function()?  digitalAssignmentFileSizeExceeded,TResult Function()?  digitalAssignmentUploadOtpRequired,TResult Function()?  digitalAssignmentUploadIncorrectOtp,TResult Function()?  loginOtpRequired,TResult Function()?  loginOtpIncorrect,TResult Function()?  loginOtpExpired,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VtopError_NetworkError() when networkError != null:
return networkError();case VtopError_TimeoutError() when timeoutError != null:
return timeoutError();case VtopError_SslError() when sslError != null:
return sslError();case VtopError_DnsError() when dnsError != null:
return dnsError();case VtopError_ConnectionRefused() when connectionRefused != null:
return connectionRefused();case VtopError_VtopServerError() when vtopServerError != null:
return vtopServerError();case VtopError_AuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that.field0);case VtopError_RegistrationParsingError() when registrationParsingError != null:
return registrationParsingError();case VtopError_InvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case VtopError_SessionExpired() when sessionExpired != null:
return sessionExpired();case VtopError_ParseError() when parseError != null:
return parseError(_that.field0);case VtopError_ConfigurationError() when configurationError != null:
return configurationError(_that.field0);case VtopError_CaptchaRequired() when captchaRequired != null:
return captchaRequired();case VtopError_InvalidResponse() when invalidResponse != null:
return invalidResponse();case VtopError_ResponseReadError() when responseReadError != null:
return responseReadError();case VtopError_DigitalAssignmentFileNotFound() when digitalAssignmentFileNotFound != null:
return digitalAssignmentFileNotFound();case VtopError_DigitalAssignmentFileTypeNotSupported() when digitalAssignmentFileTypeNotSupported != null:
return digitalAssignmentFileTypeNotSupported();case VtopError_DigitalAssignmentFileSizeExceeded() when digitalAssignmentFileSizeExceeded != null:
return digitalAssignmentFileSizeExceeded();case VtopError_DigitalAssignmentUploadOtpRequired() when digitalAssignmentUploadOtpRequired != null:
return digitalAssignmentUploadOtpRequired();case VtopError_DigitalAssignmentUploadIncorrectOtp() when digitalAssignmentUploadIncorrectOtp != null:
return digitalAssignmentUploadIncorrectOtp();case VtopError_LoginOtpRequired() when loginOtpRequired != null:
return loginOtpRequired();case VtopError_LoginOtpIncorrect() when loginOtpIncorrect != null:
return loginOtpIncorrect();case VtopError_LoginOtpExpired() when loginOtpExpired != null:
return loginOtpExpired();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  networkError,required TResult Function()  timeoutError,required TResult Function()  sslError,required TResult Function()  dnsError,required TResult Function()  connectionRefused,required TResult Function()  vtopServerError,required TResult Function( String field0)  authenticationFailed,required TResult Function()  registrationParsingError,required TResult Function()  invalidCredentials,required TResult Function()  sessionExpired,required TResult Function( String field0)  parseError,required TResult Function( String field0)  configurationError,required TResult Function()  captchaRequired,required TResult Function()  invalidResponse,required TResult Function()  responseReadError,required TResult Function()  digitalAssignmentFileNotFound,required TResult Function()  digitalAssignmentFileTypeNotSupported,required TResult Function()  digitalAssignmentFileSizeExceeded,required TResult Function()  digitalAssignmentUploadOtpRequired,required TResult Function()  digitalAssignmentUploadIncorrectOtp,required TResult Function()  loginOtpRequired,required TResult Function()  loginOtpIncorrect,required TResult Function()  loginOtpExpired,}) {final _that = this;
switch (_that) {
case VtopError_NetworkError():
return networkError();case VtopError_TimeoutError():
return timeoutError();case VtopError_SslError():
return sslError();case VtopError_DnsError():
return dnsError();case VtopError_ConnectionRefused():
return connectionRefused();case VtopError_VtopServerError():
return vtopServerError();case VtopError_AuthenticationFailed():
return authenticationFailed(_that.field0);case VtopError_RegistrationParsingError():
return registrationParsingError();case VtopError_InvalidCredentials():
return invalidCredentials();case VtopError_SessionExpired():
return sessionExpired();case VtopError_ParseError():
return parseError(_that.field0);case VtopError_ConfigurationError():
return configurationError(_that.field0);case VtopError_CaptchaRequired():
return captchaRequired();case VtopError_InvalidResponse():
return invalidResponse();case VtopError_ResponseReadError():
return responseReadError();case VtopError_DigitalAssignmentFileNotFound():
return digitalAssignmentFileNotFound();case VtopError_DigitalAssignmentFileTypeNotSupported():
return digitalAssignmentFileTypeNotSupported();case VtopError_DigitalAssignmentFileSizeExceeded():
return digitalAssignmentFileSizeExceeded();case VtopError_DigitalAssignmentUploadOtpRequired():
return digitalAssignmentUploadOtpRequired();case VtopError_DigitalAssignmentUploadIncorrectOtp():
return digitalAssignmentUploadIncorrectOtp();case VtopError_LoginOtpRequired():
return loginOtpRequired();case VtopError_LoginOtpIncorrect():
return loginOtpIncorrect();case VtopError_LoginOtpExpired():
return loginOtpExpired();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  networkError,TResult? Function()?  timeoutError,TResult? Function()?  sslError,TResult? Function()?  dnsError,TResult? Function()?  connectionRefused,TResult? Function()?  vtopServerError,TResult? Function( String field0)?  authenticationFailed,TResult? Function()?  registrationParsingError,TResult? Function()?  invalidCredentials,TResult? Function()?  sessionExpired,TResult? Function( String field0)?  parseError,TResult? Function( String field0)?  configurationError,TResult? Function()?  captchaRequired,TResult? Function()?  invalidResponse,TResult? Function()?  responseReadError,TResult? Function()?  digitalAssignmentFileNotFound,TResult? Function()?  digitalAssignmentFileTypeNotSupported,TResult? Function()?  digitalAssignmentFileSizeExceeded,TResult? Function()?  digitalAssignmentUploadOtpRequired,TResult? Function()?  digitalAssignmentUploadIncorrectOtp,TResult? Function()?  loginOtpRequired,TResult? Function()?  loginOtpIncorrect,TResult? Function()?  loginOtpExpired,}) {final _that = this;
switch (_that) {
case VtopError_NetworkError() when networkError != null:
return networkError();case VtopError_TimeoutError() when timeoutError != null:
return timeoutError();case VtopError_SslError() when sslError != null:
return sslError();case VtopError_DnsError() when dnsError != null:
return dnsError();case VtopError_ConnectionRefused() when connectionRefused != null:
return connectionRefused();case VtopError_VtopServerError() when vtopServerError != null:
return vtopServerError();case VtopError_AuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that.field0);case VtopError_RegistrationParsingError() when registrationParsingError != null:
return registrationParsingError();case VtopError_InvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case VtopError_SessionExpired() when sessionExpired != null:
return sessionExpired();case VtopError_ParseError() when parseError != null:
return parseError(_that.field0);case VtopError_ConfigurationError() when configurationError != null:
return configurationError(_that.field0);case VtopError_CaptchaRequired() when captchaRequired != null:
return captchaRequired();case VtopError_InvalidResponse() when invalidResponse != null:
return invalidResponse();case VtopError_ResponseReadError() when responseReadError != null:
return responseReadError();case VtopError_DigitalAssignmentFileNotFound() when digitalAssignmentFileNotFound != null:
return digitalAssignmentFileNotFound();case VtopError_DigitalAssignmentFileTypeNotSupported() when digitalAssignmentFileTypeNotSupported != null:
return digitalAssignmentFileTypeNotSupported();case VtopError_DigitalAssignmentFileSizeExceeded() when digitalAssignmentFileSizeExceeded != null:
return digitalAssignmentFileSizeExceeded();case VtopError_DigitalAssignmentUploadOtpRequired() when digitalAssignmentUploadOtpRequired != null:
return digitalAssignmentUploadOtpRequired();case VtopError_DigitalAssignmentUploadIncorrectOtp() when digitalAssignmentUploadIncorrectOtp != null:
return digitalAssignmentUploadIncorrectOtp();case VtopError_LoginOtpRequired() when loginOtpRequired != null:
return loginOtpRequired();case VtopError_LoginOtpIncorrect() when loginOtpIncorrect != null:
return loginOtpIncorrect();case VtopError_LoginOtpExpired() when loginOtpExpired != null:
return loginOtpExpired();case _:
  return null;

}
}

}

/// @nodoc


class VtopError_NetworkError extends VtopError {
  const VtopError_NetworkError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_NetworkError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.networkError()';
}


}




/// @nodoc


class VtopError_TimeoutError extends VtopError {
  const VtopError_TimeoutError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_TimeoutError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.timeoutError()';
}


}




/// @nodoc


class VtopError_SslError extends VtopError {
  const VtopError_SslError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_SslError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.sslError()';
}


}




/// @nodoc


class VtopError_DnsError extends VtopError {
  const VtopError_DnsError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_DnsError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.dnsError()';
}


}




/// @nodoc


class VtopError_ConnectionRefused extends VtopError {
  const VtopError_ConnectionRefused(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_ConnectionRefused);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.connectionRefused()';
}


}




/// @nodoc


class VtopError_VtopServerError extends VtopError {
  const VtopError_VtopServerError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_VtopServerError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.vtopServerError()';
}


}




/// @nodoc


class VtopError_AuthenticationFailed extends VtopError {
  const VtopError_AuthenticationFailed(this.field0): super._();
  

 final  String field0;

/// Create a copy of VtopError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VtopError_AuthenticationFailedCopyWith<VtopError_AuthenticationFailed> get copyWith => _$VtopError_AuthenticationFailedCopyWithImpl<VtopError_AuthenticationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_AuthenticationFailed&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'VtopError.authenticationFailed(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $VtopError_AuthenticationFailedCopyWith<$Res> implements $VtopErrorCopyWith<$Res> {
  factory $VtopError_AuthenticationFailedCopyWith(VtopError_AuthenticationFailed value, $Res Function(VtopError_AuthenticationFailed) _then) = _$VtopError_AuthenticationFailedCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$VtopError_AuthenticationFailedCopyWithImpl<$Res>
    implements $VtopError_AuthenticationFailedCopyWith<$Res> {
  _$VtopError_AuthenticationFailedCopyWithImpl(this._self, this._then);

  final VtopError_AuthenticationFailed _self;
  final $Res Function(VtopError_AuthenticationFailed) _then;

/// Create a copy of VtopError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(VtopError_AuthenticationFailed(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class VtopError_RegistrationParsingError extends VtopError {
  const VtopError_RegistrationParsingError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_RegistrationParsingError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.registrationParsingError()';
}


}




/// @nodoc


class VtopError_InvalidCredentials extends VtopError {
  const VtopError_InvalidCredentials(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_InvalidCredentials);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.invalidCredentials()';
}


}




/// @nodoc


class VtopError_SessionExpired extends VtopError {
  const VtopError_SessionExpired(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_SessionExpired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.sessionExpired()';
}


}




/// @nodoc


class VtopError_ParseError extends VtopError {
  const VtopError_ParseError(this.field0): super._();
  

 final  String field0;

/// Create a copy of VtopError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VtopError_ParseErrorCopyWith<VtopError_ParseError> get copyWith => _$VtopError_ParseErrorCopyWithImpl<VtopError_ParseError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_ParseError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'VtopError.parseError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $VtopError_ParseErrorCopyWith<$Res> implements $VtopErrorCopyWith<$Res> {
  factory $VtopError_ParseErrorCopyWith(VtopError_ParseError value, $Res Function(VtopError_ParseError) _then) = _$VtopError_ParseErrorCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$VtopError_ParseErrorCopyWithImpl<$Res>
    implements $VtopError_ParseErrorCopyWith<$Res> {
  _$VtopError_ParseErrorCopyWithImpl(this._self, this._then);

  final VtopError_ParseError _self;
  final $Res Function(VtopError_ParseError) _then;

/// Create a copy of VtopError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(VtopError_ParseError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class VtopError_ConfigurationError extends VtopError {
  const VtopError_ConfigurationError(this.field0): super._();
  

 final  String field0;

/// Create a copy of VtopError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VtopError_ConfigurationErrorCopyWith<VtopError_ConfigurationError> get copyWith => _$VtopError_ConfigurationErrorCopyWithImpl<VtopError_ConfigurationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_ConfigurationError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'VtopError.configurationError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $VtopError_ConfigurationErrorCopyWith<$Res> implements $VtopErrorCopyWith<$Res> {
  factory $VtopError_ConfigurationErrorCopyWith(VtopError_ConfigurationError value, $Res Function(VtopError_ConfigurationError) _then) = _$VtopError_ConfigurationErrorCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$VtopError_ConfigurationErrorCopyWithImpl<$Res>
    implements $VtopError_ConfigurationErrorCopyWith<$Res> {
  _$VtopError_ConfigurationErrorCopyWithImpl(this._self, this._then);

  final VtopError_ConfigurationError _self;
  final $Res Function(VtopError_ConfigurationError) _then;

/// Create a copy of VtopError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(VtopError_ConfigurationError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class VtopError_CaptchaRequired extends VtopError {
  const VtopError_CaptchaRequired(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_CaptchaRequired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.captchaRequired()';
}


}




/// @nodoc


class VtopError_InvalidResponse extends VtopError {
  const VtopError_InvalidResponse(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_InvalidResponse);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.invalidResponse()';
}


}




/// @nodoc


class VtopError_ResponseReadError extends VtopError {
  const VtopError_ResponseReadError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_ResponseReadError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.responseReadError()';
}


}




/// @nodoc


class VtopError_DigitalAssignmentFileNotFound extends VtopError {
  const VtopError_DigitalAssignmentFileNotFound(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_DigitalAssignmentFileNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.digitalAssignmentFileNotFound()';
}


}




/// @nodoc


class VtopError_DigitalAssignmentFileTypeNotSupported extends VtopError {
  const VtopError_DigitalAssignmentFileTypeNotSupported(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_DigitalAssignmentFileTypeNotSupported);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.digitalAssignmentFileTypeNotSupported()';
}


}




/// @nodoc


class VtopError_DigitalAssignmentFileSizeExceeded extends VtopError {
  const VtopError_DigitalAssignmentFileSizeExceeded(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_DigitalAssignmentFileSizeExceeded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.digitalAssignmentFileSizeExceeded()';
}


}




/// @nodoc


class VtopError_DigitalAssignmentUploadOtpRequired extends VtopError {
  const VtopError_DigitalAssignmentUploadOtpRequired(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_DigitalAssignmentUploadOtpRequired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.digitalAssignmentUploadOtpRequired()';
}


}




/// @nodoc


class VtopError_DigitalAssignmentUploadIncorrectOtp extends VtopError {
  const VtopError_DigitalAssignmentUploadIncorrectOtp(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_DigitalAssignmentUploadIncorrectOtp);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.digitalAssignmentUploadIncorrectOtp()';
}


}




/// @nodoc


class VtopError_LoginOtpRequired extends VtopError {
  const VtopError_LoginOtpRequired(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_LoginOtpRequired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.loginOtpRequired()';
}


}




/// @nodoc


class VtopError_LoginOtpIncorrect extends VtopError {
  const VtopError_LoginOtpIncorrect(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_LoginOtpIncorrect);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.loginOtpIncorrect()';
}


}




/// @nodoc


class VtopError_LoginOtpExpired extends VtopError {
  const VtopError_LoginOtpExpired(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VtopError_LoginOtpExpired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VtopError.loginOtpExpired()';
}


}




// dart format on
