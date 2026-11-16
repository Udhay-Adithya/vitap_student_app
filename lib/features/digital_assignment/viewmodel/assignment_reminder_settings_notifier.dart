import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/assignment_reminder_store.dart';

final assignmentReminderSettingsProvider =
    AsyncNotifierProvider<
      AssignmentReminderSettingsNotifier,
      AssignmentReminderSettings
    >(AssignmentReminderSettingsNotifier.new);

class AssignmentReminderSettingsNotifier
    extends AsyncNotifier<AssignmentReminderSettings> {
  static const AssignmentReminderStore _store = AssignmentReminderStore();

  @override
  Future<AssignmentReminderSettings> build() => _store.readSettings();

  /// Saves [settings] and rebuilds the reminders to match, so a change in
  /// settings takes effect without another trip to VTOP.
  Future<void> save(AssignmentReminderSettings settings) async {
    state = AsyncData(settings);
    await _store.writeSettings(settings);
    await _store.reschedule();
  }
}
