import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';

part 'analytics_service.g.dart';

/// The analytics surface the rest of the app talks to.
///
/// Two rules shape this interface:
///
/// 1. **Logging never throws and never blocks.** Every `log*` method returns
///    `void`, not `Future`, so a call site physically cannot `await` telemetry
///    in the middle of a user-facing flow. Implementations swallow their own
///    failures — a broken analytics backend must not break login.
/// 2. **No personally identifying data leaves the device.** Google's Analytics
///    terms forbid uploading PII, so implementations sanitise every parameter
///    (see [AnalyticsService.logEvent]) and the only user-scoped values ever
///    sent are the coarse [StudentIdentity] buckets.
///
/// Resolve it with `ref.read(analyticsServiceProvider)`. Code without a `ref`
/// takes the service as a parameter, or reads it through
/// `ProviderScope.containerOf(context)` where it only has a `BuildContext`.
abstract interface class AnalyticsService {
  /// Applies the persisted opt-out choice and prepares the backend. Safe to
  /// call before the user has made a choice — [enabled] defaults to the value
  /// stored in preferences.
  Future<void> initialize({required bool enabled});

  /// Turns collection on or off in response to the settings toggle. Disabling
  /// also drops any data buffered on the device.
  Future<void> setCollectionEnabled({required bool enabled});

  /// Records a `screen_view`. [screenClass] defaults to [screenName].
  void logScreen(String screenName, {String? screenClass});

  /// Records a custom event.
  ///
  /// [name] must come from [AnalyticsEvents]. Parameters are sanitised before
  /// dispatch: nulls are dropped, `bool` is coerced to a string (Firebase only
  /// accepts `String`/`num` and asserts otherwise), values are truncated to
  /// Firebase's 100-character limit, and the map is capped at 25 entries. Do
  /// not pass free text, file names, ids, or anything a person typed.
  void logEvent(String name, [Map<String, Object?>? parameters]);

  /// Records Firebase's standard `login` event.
  void logLogin(String method);

  /// Records a handled error as [AnalyticsEvents.appError].
  ///
  /// [error] is stringified and scrubbed of URLs, email addresses and long
  /// digit runs before being sent, because exception text routinely carries
  /// registration numbers, session ids and request URLs.
  void logError(String errorType, Object error, {String? location});

  /// Sets the coarse cohort properties derived from [registrationNumber].
  ///
  /// Only the year and branch prefix are sent; the unique digits are discarded
  /// on device. No Firebase `user_id` is set — a per-student identifier has no
  /// analytical value here and would be PII.
  void identifyStudent(String registrationNumber);

  /// Clears the analytics identity and on-device data. Call on logout so the
  /// next account on a shared device does not inherit the previous cohort.
  Future<void> reset();
}

/// The coarse, non-identifying cohort derived from a registration number.
///
/// A registration number looks like `23BCE7625`: two digits of joining year,
/// a three-letter branch code, then digits unique to the student. Only the
/// first five characters are ever retained, which is what makes this safe to
/// send without hashing — thousands of students share any given prefix.
@immutable
class StudentIdentity {
  const StudentIdentity({required this.joiningYear, required this.branch});

  /// Used when the registration number does not match the expected shape, so
  /// the cohort dimensions stay populated rather than going missing.
  static const StudentIdentity unknown = StudentIdentity(
    joiningYear: 'Custom',
    branch: 'Custom',
  );

  /// Four-digit joining year, e.g. `2023`.
  final String joiningYear;

  /// Three-letter branch code, e.g. `BCE`.
  final String branch;

  static final RegExp _pattern = RegExp(r'^(\d{2})([A-Za-z]{3})\d+$');

  /// Parses `23BCE7625` into year `2023` and branch `BCE`, falling back to
  /// [unknown] for any other shape.
  factory StudentIdentity.fromRegistrationNumber(String registrationNumber) {
    final match = _pattern.firstMatch(registrationNumber.trim());
    if (match == null) return unknown;
    return StudentIdentity(
      joiningYear: '20${match.group(1)}',
      branch: match.group(2)!.toUpperCase(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StudentIdentity &&
      other.joiningYear == joiningYear &&
      other.branch == branch;

  @override
  int get hashCode => Object.hash(joiningYear, branch);

  @override
  String toString() =>
      'StudentIdentity(joiningYear: $joiningYear, branch: $branch)';
}

/// Firebase-backed implementation.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  /// Firebase truncates parameter values at 100 characters and silently drops
  /// events with more than 25 parameters, so trim before dispatch rather than
  /// discovering half-written values in the console.
  static const int _maxParamValueLength = 100;
  static const int _maxParams = 25;

  /// Exception text regularly embeds request URLs, the student's email and
  /// registration/session numbers. Strip all three before anything is sent.
  static final RegExp _urlPattern = RegExp(r'https?://\S+');
  static final RegExp _emailPattern = RegExp(r'\b[\w.+-]+@[\w-]+\.[\w.-]+\b');
  static final RegExp _longDigitRun = RegExp(r'\d{4,}');

  bool _enabled = false;

  @override
  Future<void> initialize({required bool enabled}) async {
    // Debug builds never report, so local development doesn't pollute the
    // production property with synthetic sessions.
    await setCollectionEnabled(enabled: enabled && !kDebugMode);
  }

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    _enabled = enabled;
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      if (!enabled) {
        // Drop anything already buffered so opting out takes effect for data
        // collected before the toggle was flipped.
        await _analytics.resetAnalyticsData();
      }
    } catch (e) {
      _debug('failed to set collection enabled=$enabled: $e');
    }
  }

  @override
  void logScreen(String screenName, {String? screenClass}) {
    if (!_enabled) return _debug('screen_view - $screenName (collection off)');
    _guard(
      'screen_view($screenName)',
      () => _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      ),
    );
  }

  @override
  void logEvent(String name, [Map<String, Object?>? parameters]) {
    final params = _sanitizeParams(parameters);
    if (!_enabled) return _debug('$name $params (collection off)');
    _guard(
      name,
      () => _analytics.logEvent(
        name: name,
        parameters: params.isEmpty ? null : params,
      ),
    );
  }

  @override
  void logLogin(String method) {
    if (!_enabled) return _debug('login - $method (collection off)');
    _guard('login', () => _analytics.logLogin(loginMethod: method));
  }

  @override
  void logError(String errorType, Object error, {String? location}) {
    logEvent(AnalyticsEvents.appError, {
      AnalyticsParams.errorType: errorType,
      AnalyticsParams.reason: _scrub(error.toString()),
      AnalyticsParams.location: location ?? 'unknown',
    });
  }

  @override
  void identifyStudent(String registrationNumber) {
    final identity = StudentIdentity.fromRegistrationNumber(registrationNumber);
    if (!_enabled) return _debug('identify - $identity (collection off)');
    _guard('identifyStudent', () async {
      await _analytics.setUserProperty(
        name: AnalyticsUserProperties.joiningYear,
        value: identity.joiningYear,
      );
      await _analytics.setUserProperty(
        name: AnalyticsUserProperties.branch,
        value: identity.branch,
      );
    });
  }

  @override
  Future<void> reset() async {
    try {
      // Null clears the property; do it explicitly so a subsequent account on
      // this device does not inherit the previous student's cohort.
      await _analytics.setUserProperty(
        name: AnalyticsUserProperties.joiningYear,
        value: null,
      );
      await _analytics.setUserProperty(
        name: AnalyticsUserProperties.branch,
        value: null,
      );
      await _analytics.setUserId(id: null);
      await _analytics.resetAnalyticsData();
    } catch (e) {
      _debug('failed to reset: $e');
    }
  }

  /// Runs a fire-and-forget analytics call, absorbing every failure.
  ///
  /// `logEvent` throws `ArgumentError` on a reserved event name and asserts on
  /// a non-`String`/`num` parameter, and the underlying platform channel can
  /// fail whenever Firebase is unavailable. None of that is worth surfacing to
  /// a student mid-login.
  void _guard(String label, Future<void> Function() call) {
    try {
      call().catchError((Object e) => _debug('$label failed: $e'));
    } catch (e) {
      _debug('$label failed: $e');
    }
  }

  /// Coerces a caller-supplied map into what Firebase actually accepts.
  Map<String, Object> _sanitizeParams(Map<String, Object?>? parameters) {
    if (parameters == null || parameters.isEmpty) return const {};
    final sanitized = <String, Object>{};
    for (final entry in parameters.entries) {
      if (sanitized.length >= _maxParams) {
        _debug('dropped params beyond $_maxParams: ${entry.key}');
        break;
      }
      final value = entry.value;
      if (value == null) continue;
      sanitized[entry.key] = switch (value) {
        // Firebase only accepts String and num; a bool trips an assert in
        // debug and is silently dropped by the native SDK in release.
        final bool b => b.toString(),
        final num n => n,
        _ => _truncate(value.toString()),
      };
    }
    return sanitized;
  }

  String _truncate(String value) => value.length <= _maxParamValueLength
      ? value
      : value.substring(0, _maxParamValueLength);

  /// Removes the identifying fragments that exception text tends to carry.
  String _scrub(String text) => _truncate(
    text
        .replaceAll(_urlPattern, '<url>')
        .replaceAll(_emailPattern, '<email>')
        .replaceAll(_longDigitRun, '<num>')
        .trim(),
  );

  void _debug(String message) {
    if (kDebugMode) debugPrint('Analytics: $message');
  }
}

/// Implementation that records nothing.
///
/// Used in tests and anywhere a real backend would be inappropriate; register
/// it in place of [FirebaseAnalyticsService] to assert on behaviour without
/// touching a platform channel.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> initialize({required bool enabled}) async {}

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {}

  @override
  void logScreen(String screenName, {String? screenClass}) {}

  @override
  void logEvent(String name, [Map<String, Object?>? parameters]) {}

  @override
  void logLogin(String method) {}

  @override
  void logError(String errorType, Object error, {String? location}) {}

  @override
  void identifyStudent(String registrationNumber) {}

  @override
  Future<void> reset() async {}
}

/// The analytics backend.
///
/// Built lazily, after Firebase is initialised: `initDependencies` reads it to
/// apply the stored opt-out before anything can log. Tests override it.
@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) => FirebaseAnalyticsService();
