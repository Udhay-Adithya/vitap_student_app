import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/show_toast.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/menu_section.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/menu_tile.dart';
import 'package:vit_ap_student_app/features/digital_assignment/repository/assignment_reminder_store.dart';
import 'package:vit_ap_student_app/features/digital_assignment/utils/assignment_reminders.dart';
import 'package:vit_ap_student_app/features/digital_assignment/viewmodel/assignment_reminder_settings_notifier.dart';

/// Settings for reminders before a digital assignment is due: on or off, and
/// which of the lead times to fire.
class AssignmentReminderSection extends ConsumerWidget {
  const AssignmentReminderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AssignmentReminderSettings> async = ref.watch(
      assignmentReminderSettingsProvider,
    );
    final AssignmentReminderSettings settings =
        async.value ?? AssignmentReminderSettings.defaults;
    final bool loaded = async.hasValue;
    final notifier = ref.read(assignmentReminderSettingsProvider.notifier);
    final ColorScheme cs = Theme.of(context).colorScheme;

    void log(String setting, Object value) =>
        ref.read(analyticsServiceProvider).logEvent(
          AnalyticsEvents.settingChanged,
          {AnalyticsParams.setting: setting, AnalyticsParams.value: value},
        );

    return MenuSection(
      children: [
        MenuTile(
          icon: Iconsax.task_square_copy,
          title: 'Assignment Reminders',
          // Answered here because it's where someone wonders why nothing
          // arrived: reminders come from the list, which is only fetched on
          // request.
          infoText:
              'Set from the assignments you last loaded. Open Digital '
              'Assignments to pick up new ones.',
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: settings.enabled,
              thumbIcon: const WidgetStateProperty<Icon?>.fromMap({
                WidgetState.selected: Icon(Icons.check_rounded),
                WidgetState.any: Icon(Icons.close_rounded),
              }),
              onChanged: loaded
                  ? (value) async {
                      await notifier.save(settings.copyWith(enabled: value));
                      log('assignment_reminders', value);
                    }
                  : null,
            ),
          ),
        ),
        if (settings.enabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remind me before the deadline',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final ReminderLead lead in ReminderLead.values)
                      FilterChip(
                        label: Text(lead.label),
                        selected: settings.leads.contains(lead),
                        shape: const StadiumBorder(),
                        onSelected: loaded
                            ? (selected) async {
                                final Set<ReminderLead> leads = {
                                  ...settings.leads,
                                };
                                selected ? leads.add(lead) : leads.remove(lead);
                                if (leads.isEmpty) {
                                  showToast(
                                    context,
                                    'Keep at least one, or turn reminders off',
                                  );
                                  return;
                                }
                                await notifier.save(
                                  settings.copyWith(leads: leads),
                                );
                                log(
                                  'assignment_reminder_leads',
                                  leads.map((l) => l.name).join(','),
                                );
                              }
                            : null,
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
