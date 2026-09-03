// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:objectbox/objectbox.dart';

@Entity()
class UserPreferences {
  @Id()
  int? id;

  String pfpPath;
  bool isTimetableNotificationsEnabled;
  bool isExamScheduleNotificationEnabled;
  int timetableNotificationDelay;
  int examScheduleNotificationDelay;
  bool isPrivacyEnabled;
  bool isDarkModeEnabled;
  bool isAmoledEnabled;
  bool bypassWeekendOutingRestriction;

  /// Whether anonymous usage analytics may be collected.
  ///
  /// Nullable on purpose: ObjectBox backfills a newly added non-null `bool`
  /// with `false` for rows written before the property existed, which would
  /// have silently opted out every existing user on upgrade. `null` means
  /// "never chosen" — read it through [analyticsEnabled], not directly.
  bool? isAnalyticsEnabled;

  /// Resolved opt-in state, defaulting to enabled until the user chooses.
  bool get analyticsEnabled => isAnalyticsEnabled ?? true;

  String? appTheme; // Store theme as string: 'blue', 'sakura', etc.
  double? fontScale;
  String messMenuHostelType;

  @Property(type: PropertyType.date)
  DateTime? lastSync;

  @Property(type: PropertyType.date)
  DateTime? attendanceLastSync;

  @Property(type: PropertyType.date)
  DateTime? marksLastSync;

  @Property(type: PropertyType.date)
  DateTime? examScheduleLastSync;
  bool isFirstLaunch;

  UserPreferences({
    this.id,
    this.pfpPath = 'assets/images/pfp/default.png',
    this.isTimetableNotificationsEnabled = true,
    this.isExamScheduleNotificationEnabled = true,
    this.timetableNotificationDelay = 10,
    this.examScheduleNotificationDelay = 60,
    this.isPrivacyEnabled = true,
    this.isDarkModeEnabled = false,
    this.isAmoledEnabled = false,
    this.bypassWeekendOutingRestriction = false,
    this.isAnalyticsEnabled,
    this.appTheme = 'blue',
    this.fontScale = 1.0,
    this.messMenuHostelType = 'mh',
    this.lastSync,
    this.attendanceLastSync,
    this.marksLastSync,
    this.examScheduleLastSync,
    this.isFirstLaunch = true,
  });

  /// The same settings with everything belonging to the signed-in student
  /// cleared.
  ///
  /// Theme, notification settings, the analytics choice and whether onboarding
  /// has been seen belong to the device and outlive an account. The last-synced
  /// stamps do not: left behind, the next student to sign in on this phone sees
  /// "Last Synced: 3 days ago" on pages holding no data at all.
  ///
  /// [pfpPath] is deliberately kept. It is either an avatar the person picked,
  /// or the sentinel meaning "the photo VTOP has of me" — which resolves
  /// against whoever is signed in, so it is already correct for the next
  /// account.
  UserPreferences withoutAccountData() => UserPreferences(
    id: id,
    pfpPath: pfpPath,
    isTimetableNotificationsEnabled: isTimetableNotificationsEnabled,
    isExamScheduleNotificationEnabled: isExamScheduleNotificationEnabled,
    timetableNotificationDelay: timetableNotificationDelay,
    examScheduleNotificationDelay: examScheduleNotificationDelay,
    isPrivacyEnabled: isPrivacyEnabled,
    isDarkModeEnabled: isDarkModeEnabled,
    isAmoledEnabled: isAmoledEnabled,
    bypassWeekendOutingRestriction: bypassWeekendOutingRestriction,
    // Carried across rather than reset: null would read as "never chosen"
    // and silently opt a student who opted out back in.
    isAnalyticsEnabled: isAnalyticsEnabled,
    appTheme: appTheme,
    fontScale: fontScale,
    isFirstLaunch: isFirstLaunch,
  );

  UserPreferences copyWith({
    int? id,
    String? pfpPath,
    bool? isTimetableNotificationsEnabled,
    bool? isExamScheduleNotificationEnabled,
    int? timetableNotificationDelay,
    int? examScheduleNotificationDelay,
    bool? isPrivacyEnabled,
    bool? isDarkModeEnabled,
    bool? isAmoledEnabled,
    bool? bypassWeekendOutingRestriction,
    bool? isAnalyticsEnabled,
    String? appTheme,
    double? fontScale,
    String? messMenuHostelType,
    DateTime? lastSync,
    DateTime? attendanceLastSync,
    DateTime? marksLastSync,
    DateTime? examScheduleLastSync,
    bool? isFirstLaunch,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      pfpPath: pfpPath ?? this.pfpPath,
      isTimetableNotificationsEnabled:
          isTimetableNotificationsEnabled ??
          this.isTimetableNotificationsEnabled,
      isExamScheduleNotificationEnabled:
          isExamScheduleNotificationEnabled ??
          this.isExamScheduleNotificationEnabled,
      timetableNotificationDelay:
          timetableNotificationDelay ?? this.timetableNotificationDelay,
      examScheduleNotificationDelay:
          examScheduleNotificationDelay ?? this.examScheduleNotificationDelay,
      isPrivacyEnabled: isPrivacyEnabled ?? this.isPrivacyEnabled,
      isDarkModeEnabled: isDarkModeEnabled ?? this.isDarkModeEnabled,
      isAmoledEnabled: isAmoledEnabled ?? this.isAmoledEnabled,
      bypassWeekendOutingRestriction:
          bypassWeekendOutingRestriction ?? this.bypassWeekendOutingRestriction,
      isAnalyticsEnabled: isAnalyticsEnabled ?? this.isAnalyticsEnabled,
      appTheme: appTheme ?? this.appTheme,
      fontScale: fontScale ?? this.fontScale,
      messMenuHostelType: messMenuHostelType ?? this.messMenuHostelType,
      lastSync: lastSync ?? this.lastSync,
      attendanceLastSync: attendanceLastSync ?? this.attendanceLastSync,
      marksLastSync: marksLastSync ?? this.marksLastSync,
      examScheduleLastSync: examScheduleLastSync ?? this.examScheduleLastSync,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}
