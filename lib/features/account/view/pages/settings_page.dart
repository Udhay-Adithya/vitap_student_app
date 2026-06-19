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

      if (mounted) showToast(context, '✅ Notifications rescheduled');
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Notifications'),

              // Class Notifications Toggle
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(9),
                ),
                tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
                title: Text(
                  'Class Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Get notified before your classes start',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: userPreferences.isTimetableNotificationsEnabled,
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

              // Class Notification Delay Slider
              if (userPreferences.isTimetableNotificationsEnabled) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8,
                  ),
                  child: Text(
                    'Class Notification delay (${userPreferences.timetableNotificationDelay} min)',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Slider(
                      value: userPreferences.timetableNotificationDelay
                          .toDouble(),
                      min: 0,
                      max: 60,
                      divisions: 12,
                      label: userPreferences.timetableNotificationDelay
                          .toString(),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0'),
                          Text('15'),
                          Text('30'),
                          Text('45'),
                          Text('60'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Exam Notifications Toggle
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(9),
                ),
                tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
                title: Text(
                  'Exam Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Get notified before your exams',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: userPreferences.isExamScheduleNotificationEnabled,
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

              // Exam Notification Delay Slider
              if (userPreferences.isExamScheduleNotificationEnabled) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8,
                  ),
                  child: Text(
                    'Exam Notification delay (${userPreferences.examScheduleNotificationDelay} min)',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Slider(
                      value: userPreferences.examScheduleNotificationDelay
                          .toDouble(),
                      min: 0,
                      max: 180,
                      divisions: 18,
                      label: userPreferences.examScheduleNotificationDelay
                          .toString(),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0'),
                          Text('45'),
                          Text('90'),
                          Text('135'),
                          Text('180'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Reset Notifications
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(9),
                ),
                tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
                leading: Icon(
                  Iconsax.refresh,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Reset Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Reschedule all notifications',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: _resetNotifications,
              ),

              _buildSectionHeader('Appearance'),

              // Dark Mode Toggle
              ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(9),
                ),
                leading: Icon(
                  userPreferences.isDarkModeEnabled
                      ? Iconsax.moon_copy
                      : Iconsax.sun_1_copy,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  userPreferences.isDarkModeEnabled
                      ? 'Using dark theme'
                      : 'Using light theme',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch.adaptive(
                    value: userPreferences.isDarkModeEnabled,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),
              ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(9),
                ),
                leading: Icon(
                  Iconsax.battery_full_copy,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'AMOLED Mode',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Pure black theme (saves battery)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch.adaptive(
                    value: userPreferences.isAmoledEnabled,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).toggleAmoled();
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // App Theme Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 8,
                ),
                child: Text(
                  'App Theme',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Horizontal Theme Selector
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

              const SizedBox(height: 24),

              // Font Scale Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 8,
                ),
                child: Text(
                  'Font Scale (${(userPreferences.fontScale ?? 1.0).toStringAsFixed(1)}x)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

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
                        await AnalyticsService.logEvent('font_scale_changed', {
                          'scale': value.toStringAsFixed(1),
                        });
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

              if (widget.isDeveloperModeEnabled) ...[
                _buildSectionHeader('Developer Options'),
                const DeveloperModeTiles(),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, top: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
