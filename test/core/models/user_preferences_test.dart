import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/models/user_preferences.dart';

/// The analytics opt-in is stored as a nullable bool specifically so that
/// ObjectBox's backfill of `false` into rows written before the property
/// existed cannot silently opt out the whole existing user base on upgrade.
void main() {
  test('analytics defaults to enabled when never chosen', () {
    expect(UserPreferences().isAnalyticsEnabled, isNull);
    expect(UserPreferences().analyticsEnabled, isTrue);
  });

  test('an explicit opt-out is honoured', () {
    final prefs = UserPreferences().copyWith(isAnalyticsEnabled: false);
    expect(prefs.analyticsEnabled, isFalse);
  });

  test('an explicit opt-in is honoured', () {
    final prefs = UserPreferences().copyWith(isAnalyticsEnabled: true);
    expect(prefs.analyticsEnabled, isTrue);
  });

  test('copyWith preserves the choice when the field is omitted', () {
    final optedOut = UserPreferences().copyWith(isAnalyticsEnabled: false);
    expect(optedOut.copyWith(fontScale: 1.2).analyticsEnabled, isFalse);
  });

  group('withoutAccountData', () {
    UserPreferences signedIn() => UserPreferences(
      id: 3,
      appTheme: 'sakura',
      isDarkModeEnabled: true,
      isTimetableNotificationsEnabled: false,
      timetableNotificationDelay: 25,
      isAnalyticsEnabled: false,
      isFirstLaunch: false,
      pfpPath: 'vtop://profile-photo',
      lastSync: DateTime(2026, 8, 1),
      attendanceLastSync: DateTime(2026, 8, 2),
      marksLastSync: DateTime(2026, 8, 3),
      examScheduleLastSync: DateTime(2026, 8, 4),
    );

    /// The stamps belong to the account that fetched the data. Left behind,
    /// the next student to sign in sees "Last Synced: 3 days ago" on pages
    /// holding nothing at all.
    test('drops every last-synced stamp', () {
      final prefs = signedIn().withoutAccountData();

      expect(prefs.lastSync, isNull);
      expect(prefs.attendanceLastSync, isNull);
      expect(prefs.marksLastSync, isNull);
      expect(prefs.examScheduleLastSync, isNull);
    });

    test('keeps the settings that belong to the device', () {
      final prefs = signedIn().withoutAccountData();

      expect(prefs.appTheme, 'sakura');
      expect(prefs.isDarkModeEnabled, isTrue);
      expect(prefs.isTimetableNotificationsEnabled, isFalse);
      expect(prefs.timetableNotificationDelay, 25);
      expect(prefs.isFirstLaunch, isFalse);
      expect(prefs.pfpPath, 'vtop://profile-photo');
    });

    /// Resetting this to null would read as "never chosen", which resolves to
    /// enabled — silently opting a student who opted out back in.
    test('carries an analytics opt-out across', () {
      expect(signedIn().withoutAccountData().isAnalyticsEnabled, isFalse);
      expect(signedIn().withoutAccountData().analyticsEnabled, isFalse);
    });

    test('stays on the same stored row', () {
      expect(signedIn().withoutAccountData().id, 3);
    });
  });
}
