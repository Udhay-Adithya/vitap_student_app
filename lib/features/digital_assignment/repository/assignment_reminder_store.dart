import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vit_ap_student_app/core/services/notification_service.dart';
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/features/digital_assignment/utils/assignment_reminders.dart';

/// Which reminders the student wants before a deadline.
class AssignmentReminderSettings {
  const AssignmentReminderSettings({
    required this.enabled,
    required this.leads,
  });

  static const AssignmentReminderSettings defaults = AssignmentReminderSettings(
    enabled: true,
    leads: {
      ReminderLead.sevenDays,
      ReminderLead.threeDays,
      ReminderLead.oneDay,
      ReminderLead.oneHour,
    },
  );

  final bool enabled;
  final Set<ReminderLead> leads;

  AssignmentReminderSettings copyWith({
    bool? enabled,
    Set<ReminderLead>? leads,
  }) => AssignmentReminderSettings(
    enabled: enabled ?? this.enabled,
    leads: leads ?? this.leads,
  );
}

/// Reminder settings and the assignments they are scheduled from.
///
/// Assignments are only fetched when the student opens them, but every
/// preference change and profile refresh cancels *all* notifications and
/// rebuilds them. So the last list fetched is kept here, and [reschedule] can
/// rebuild the reminders without going back to VTOP — which could demand an
/// OTP nobody asked for.
///
/// Kept in [SharedPreferences] rather than on the `UserPreferences` ObjectBox
/// entity, which would make this a schema migration.
class AssignmentReminderStore {
  const AssignmentReminderStore();

  static const String _enabledKey = 'assignment_reminders_enabled';
  static const String _leadsKey = 'assignment_reminder_leads';
  static const String _assignmentsKey = 'assignment_reminder_assignments';

  Future<AssignmentReminderSettings> readSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? names = prefs.getStringList(_leadsKey);
    return AssignmentReminderSettings(
      enabled: prefs.getBool(_enabledKey) ?? true,
      leads: names == null
          ? AssignmentReminderSettings.defaults.leads
          // Unknown names are dropped, so a lead removed in a later release
          // doesn't break reading the rest.
          : ReminderLead.values.where((l) => names.contains(l.name)).toSet(),
    );
  }

  Future<void> writeSettings(AssignmentReminderSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, settings.enabled);
    await prefs.setStringList(
      _leadsKey,
      settings.leads.map((l) => l.name).toList(),
    );
  }

  Future<void> saveAssignments(List<DigitalAssignment> assignments) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _assignmentsKey,
      digitalAssignmentsToJson(assignments),
    );
  }

  /// Drops one assignment once it has been uploaded, so its reminders stop
  /// without waiting for the next fetch.
  Future<void> markSubmitted({
    required String classId,
    required String mcode,
  }) async {
    final List<DigitalAssignment> remaining = [
      for (final DigitalAssignment a in await _readAssignments())
        DigitalAssignment(
          serialNumber: a.serialNumber,
          classId: a.classId,
          courseCode: a.courseCode,
          courseTitle: a.courseTitle,
          courseType: a.courseType,
          faculty: a.faculty,
          details: a.classId == classId
              ? a.details.where((d) => d.mcode != mcode).toList()
              : a.details,
        ),
    ];
    await saveAssignments(remaining);
    await reschedule();
  }

  /// The cached assignments belong to the student who fetched them.
  Future<void> clearAssignments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_assignmentsKey);
    await NotificationService.cancelAssignmentReminders();
  }

  /// Replaces every scheduled assignment reminder with what the current
  /// settings and cached assignments call for.
  ///
  /// Runs one at a time: two overlapping runs (a few chips tapped in quick
  /// succession) could each cancel before the other scheduled, leaving behind
  /// reminders for a lead that was just turned off.
  Future<void> reschedule() =>
      _queue = _queue.catchError((Object _) {}).then((_) => _reschedule());

  static Future<void> _queue = Future<void>.value();

  Future<void> _reschedule() async {
    final AssignmentReminderSettings settings = await readSettings();
    final List<PlannedReminder> planned = settings.enabled
        ? planAssignmentReminders(
            await _readAssignments(),
            settings.leads,
            now: tz.TZDateTime.now(tz.local),
          )
        : const [];
    await NotificationService.scheduleAssignmentReminders(planned);
  }

  Future<List<DigitalAssignment>> _readAssignments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_assignmentsKey);
    if (raw == null) return const [];
    try {
      return digitalAssignmentsFromJson(raw);
    } catch (_) {
      // A cache written by an older model shape: forget it rather than fail
      // every reschedule until the next fetch overwrites it.
      return const [];
    }
  }
}
