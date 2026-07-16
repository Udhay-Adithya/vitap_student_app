import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/theme_mode_notifier.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';
import 'package:vit_ap_student_app/core/theme/app_theme_enum.dart';
import 'package:vit_ap_student_app/core/utils/show_toast.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/circular_theme_indicator.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/developer_mode_tiles.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/menu_section.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/menu_tile.dart';

class SettingsPage extends ConsumerStatefulWidget {
  final bool isDeveloperModeEnabled;

  const SettingsPage({super.key, this.isDeveloperModeEnabled = false});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Future<void> _resetNotifications() async {
    try {
      final user = ref.read(currentUserProvider);
      final prefs = ref.read(userPreferencesProvider);

      if (user == null) {
        if (mounted) showToast(context, 'No user data available');
        return;
      }

      // Cancel all and reschedule
      await NotificationService.cancelAllNotifications();

      if (prefs.isTimetableNotificationsEnabled) {
        await NotificationService.scheduleTimetableNotifications(
          user: user,
          prefs: prefs,
        );
      }

      if (prefs.isExamScheduleNotificationEnabled) {
        await NotificationService.scheduleExamNotifications(
          user: user,
          prefs: prefs,
        );
      }

      if (mounted) showToast(context, 'Notifications rescheduled');
      await AnalyticsService.logEvent('notifications_reset');
    } catch (e) {
      if (mounted) showToast(context, 'Failed to reset notifications');
      debugPrint('Notification reset failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('SettingsPage');
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = ref.watch(userPreferencesProvider);
    final userPreferencesNotifier = ref.read(userPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        actions: [
          if (widget.isDeveloperModeEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                Iconsax.security_user_copy,
                color: Theme.of(context).colorScheme.tertiary,
                size: 22,
                semanticLabel: 'Developer Mode',
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuSection(
                label: 'Notifications',
                children: [
                  MenuTile(
                    icon: Iconsax.notification_copy,
                    title: 'Class Notifications',
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: userPreferences.isTimetableNotificationsEnabled,
                        thumbIcon: const WidgetStateProperty<Icon?>.fromMap({
                          WidgetState.selected: Icon(Icons.check_rounded),
                          WidgetState.any: Icon(Icons.close_rounded),
                        }),
                        onChanged: (value) async {
                          final updatedPreferences = userPreferences.copyWith(
                            isTimetableNotificationsEnabled: value,
                          );
                          await userPreferencesNotifier.updatePreferences(
                            updatedPreferences,
                          );
                          await AnalyticsService.logEvent(
                            'is_timetable_notification_enabled',
                            {'value': value.toString()},
                          );
                        },
                      ),
                    ),
                  ),
                  if (userPreferences.isTimetableNotificationsEnabled)
                    _buildDelaySlider(
                      title:
                          'Class Notification delay (${userPreferences.timetableNotificationDelay} min)',
                      value: userPreferences.timetableNotificationDelay
                          .toDouble(),
                      max: 60,
                      divisions: 12,
                      labels: const ['0', '15', '30', '45', '60'],
                      onChanged: (value) async {
                        final updatedPreferences = userPreferences.copyWith(
                          timetableNotificationDelay: value.round(),
                        );
                        await userPreferencesNotifier.updatePreferences(
                          updatedPreferences,
                        );
                        await AnalyticsService.logEvent(
                          'timetable_notification_delay',
                          {'delay': value.round()},
                        );
                      },
                    ),
                ],
              ),

              const SizedBox(height: 24),

              MenuSection(
                children: [
                  MenuTile(
                    icon: Iconsax.notification_copy,
                    title: 'Exam Notifications',
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value:
                            userPreferences.isExamScheduleNotificationEnabled,
                        thumbIcon: const WidgetStateProperty<Icon?>.fromMap({
                          WidgetState.selected: Icon(Icons.check_rounded),
                          WidgetState.any: Icon(Icons.close_rounded),
                        }),
                        onChanged: (value) async {
                          final updatedPreferences = userPreferences.copyWith(
                            isExamScheduleNotificationEnabled: value,
                          );
                          await userPreferencesNotifier.updatePreferences(
                            updatedPreferences,
                          );
                          await AnalyticsService.logEvent(
                            'is_exam_schedule_notification_enabled',
                            {'value': value.toString()},
                          );
                        },
                      ),
                    ),
                  ),
                  if (userPreferences.isExamScheduleNotificationEnabled)
                    _buildDelaySlider(
                      title:
                          'Exam Notification delay (${userPreferences.examScheduleNotificationDelay} min)',
                      value: userPreferences.examScheduleNotificationDelay
                          .toDouble(),
                      max: 180,
                      divisions: 18,
                      labels: const ['0', '45', '90', '135', '180'],
                      onChanged: (value) async {
                        final updatedPreferences = userPreferences.copyWith(
                          examScheduleNotificationDelay: value.round(),
                        );
                        await userPreferencesNotifier.updatePreferences(
                          updatedPreferences,
                        );
                        await AnalyticsService.logEvent(
                          'exam_schedule_notification_delay',
                          {'delay': value.round()},
                        );
                      },
                    ),
                ],
              ),

              const SizedBox(height: 24),

              MenuSection(
                children: [
                  MenuTile(
                    icon: Iconsax.refresh,
                    title: 'Reset Notifications',
                    onTap: _resetNotifications,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              MenuSection(
                label: 'Appearance',
                children: [
                  MenuTile(
                    icon: Iconsax.moon_copy,
                    title: 'Dark Mode',
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch.adaptive(
                        value: userPreferences.isDarkModeEnabled,
                        thumbIcon: const WidgetStateProperty<Icon?>.fromMap({
                          WidgetState.selected: Icon(Icons.dark_mode_rounded),
                          WidgetState.any: Icon(Icons.light_mode_rounded),
                        }),
                        onChanged: (value) {
                          ref.read(themeModeProvider.notifier).toggleTheme();
                        },
                      ),
                    ),
                  ),
                  MenuTile(
                    icon: Iconsax.battery_full_copy,
                    title: 'AMOLED Mode',
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch.adaptive(
                        value: userPreferences.isAmoledEnabled,
                        thumbIcon: const WidgetStateProperty<Icon?>.fromMap({
                          WidgetState.selected: Icon(Icons.check_rounded),
                          WidgetState.any: Icon(Icons.close_rounded),
                        }),
                        onChanged: (value) {
                          ref.read(themeModeProvider.notifier).toggleAmoled();
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              MenuSection(
                label: 'App Theme',
                children: [
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      itemCount: AppTheme.values.length,
                      itemBuilder: (context, index) {
                        final theme = AppTheme.values[index];
                        final isSelected =
                            (userPreferences.appTheme ?? 'blue') == theme.name;

                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: CircularThemeIndicator(
                            theme: theme,
                            isDarkMode: userPreferences.isDarkModeEnabled,
                            isSelected: isSelected,
                            onTap: () async {
                              await ref
                                  .read(themeModeProvider.notifier)
                                  .setAppTheme(theme);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              MenuSection(
                label:
                    'Font Scale (${(userPreferences.fontScale ?? 1.0).toStringAsFixed(1)}x)',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Column(
                      children: [
                        Slider(
                          value: userPreferences.fontScale ?? 1.0,
                          min: 0.8,
                          max: 1.3,
                          divisions: 5,
                          label:
                              '${(userPreferences.fontScale ?? 1.0).toStringAsFixed(1)}x',
                          onChanged: (value) async {
                            final updatedPreferences = userPreferences.copyWith(
                              fontScale: value,
                            );
                            await userPreferencesNotifier.updatePreferences(
                              updatedPreferences,
                            );
                            await AnalyticsService.logEvent(
                              'font_scale_changed',
                              {'scale': value.toStringAsFixed(1)},
                            );
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('0.8x', style: TextStyle(fontSize: 12)),
                              Text('1.0x', style: TextStyle(fontSize: 12)),
                              Text('1.3x', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (widget.isDeveloperModeEnabled) ...[
                const SizedBox(height: 24),
                const DeveloperModeTiles(),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDelaySlider({
    required String title,
    required double value,
    required double max,
    required int divisions,
    required List<String> labels,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Slider(
            value: value,
            max: max,
            divisions: divisions,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [for (final label in labels) Text(label)],
            ),
          ),
        ],
      ),
    );
  }
}
