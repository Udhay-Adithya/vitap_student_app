import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
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
import 'package:vit_ap_student_app/features/home/model/mess_menu_hostel.dart';
import 'package:vit_ap_student_app/features/home/repository/mess_menu_repository.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/mess_menu_viewmodel.dart';

class SettingsPage extends ConsumerStatefulWidget {
  final bool isDeveloperModeEnabled;

  const SettingsPage({super.key, this.isDeveloperModeEnabled = false});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isMenuSyncing = false;
  bool _isMenuCacheClearing = false;

  Future<void> _changeMessHostel() async {
    final MessMenuHostel currentHostel = messMenuHostelFromCode(
      ref.read(userPreferencesProvider).messMenuHostelType,
    );

    final MessMenuHostel? selected = await showDialog<MessMenuHostel>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Mess hostel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: MessMenuHostel.values
                .map((MessMenuHostel hostel) {
                  final bool isSelected = hostel == currentHostel;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSelected ? Icons.check_rounded : Icons.circle_outlined,
                    ),
                    title: Text(hostel.label),
                    onTap: () => Navigator.of(dialogContext).pop(hostel),
                  );
                })
                .toList(growable: false),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selected == null || selected == currentHostel) {
      return;
    }

    final userPreferences = ref.read(userPreferencesProvider);
    final userPreferencesNotifier = ref.read(userPreferencesProvider.notifier);
    await userPreferencesNotifier.updatePreferences(
      userPreferences.copyWith(messMenuHostelType: selected.apiType),
    );
    ref.read(messMenuCacheRevisionProvider.notifier).state =
        DateTime.now().millisecondsSinceEpoch;

    if (mounted) {
      showToast(context, 'Mess hostel set to ${selected.label}');
    }
  }

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
      ref
          .read(analyticsServiceProvider)
          .logEvent(AnalyticsEvents.notificationsReset);
    } catch (e) {
      if (mounted) showToast(context, 'Failed to reset notifications');
      debugPrint('Notification reset failed: $e');
    }
  }

  Future<void> _syncMessMenu() async {
    if (_isMenuSyncing) return;
    setState(() => _isMenuSyncing = true);

    try {
      ref.read(analyticsServiceProvider).logEvent(
        AnalyticsEvents.manualSyncInitiated,
        {AnalyticsParams.source: 'SettingsPage'},
      );

      final MessMenuRepository repository = ref.read(
        messMenuRepositoryProvider,
      );
      final MessMenuHostel hostel = messMenuHostelFromCode(
        ref.read(userPreferencesProvider).messMenuHostelType,
      );
      final result = await repository.syncMenu(hostel: hostel);
      if (!mounted) return;

      result.fold(
        (failure) {
          showToast(context, failure.message);
        },
        (_) {
          ref.read(messMenuCacheRevisionProvider.notifier).state =
              DateTime.now().millisecondsSinceEpoch;
          showToast(context, 'Mess menu synced for offline use');
        },
      );
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to sync mess menu');
      }
      debugPrint('Menu sync failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isMenuSyncing = false);
      }
    }
  }

  Future<void> _clearMessMenuCache() async {
    if (_isMenuCacheClearing) return;

    final bool shouldClear =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Clear menu cache?'),
              content: const Text(
                'This removes all saved mess menu data, so the Home card will show the empty offline state until you sync again.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Clear'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldClear) return;

    setState(() => _isMenuCacheClearing = true);
    try {
      final MessMenuRepository repository = ref.read(
        messMenuRepositoryProvider,
      );
      final result = await repository.clearMenuCache();
      if (!mounted) return;

      result.fold(
        (failure) {
          showToast(context, failure.message);
        },
        (_) {
          ref.read(messMenuCacheRevisionProvider.notifier).state =
              DateTime.now().millisecondsSinceEpoch;
          showToast(context, 'Mess menu cache cleared');
        },
      );
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to clear menu cache');
      }
      debugPrint('Menu cache clear failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isMenuCacheClearing = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logScreen('SettingsPage');
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
                          ref
                              .read(analyticsServiceProvider)
                              .logEvent(AnalyticsEvents.settingChanged, {
                                AnalyticsParams.setting:
                                    'timetable_notifications',
                                AnalyticsParams.value: value,
                              });
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
                        ref
                            .read(analyticsServiceProvider)
                            .logEvent(AnalyticsEvents.settingChanged, {
                              AnalyticsParams.setting:
                                  'timetable_notification_delay',
                              AnalyticsParams.value: value.round(),
                            });
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
                          ref
                              .read(analyticsServiceProvider)
                              .logEvent(AnalyticsEvents.settingChanged, {
                                AnalyticsParams.setting: 'exam_notifications',
                                AnalyticsParams.value: value,
                              });
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
                        ref.read(analyticsServiceProvider).logEvent(
                          AnalyticsEvents.settingChanged,
                          {
                            AnalyticsParams.setting: 'exam_notification_delay',
                            AnalyticsParams.value: value.round(),
                          },
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
                label: 'Mess Menu',
                children: [
                  MenuTile(
                    icon: Icons.apartment_rounded,
                    title: 'Mess Hostel',
                    subtitle: messMenuHostelFromCode(
                      userPreferences.messMenuHostelType,
                    ).label,
                    infoText:
                        'Select the hostel before syncing so the app loads the matching menu.',
                    onTap: _changeMessHostel,
                  ),
                  MenuTile(
                    icon: Iconsax.refresh,
                    title: 'Sync Mess Menu',
                    subtitle: 'Download the current month for offline use',
                    infoText:
                        'The home card reads from cached menu data for the selected hostel. Sync only updates it when you tap this button.',
                    trailing: _isMenuSyncing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    onTap: _syncMessMenu,
                  ),
                  if (widget.isDeveloperModeEnabled)
                    MenuTile(
                      icon: Iconsax.trash_copy,
                      title: 'Clear Mess Menu Cache',
                      subtitle: 'Remove the saved offline copy',
                      infoText:
                          'Useful for testing empty-state behavior or forcing the next sync to repopulate data.',
                      trailing: _isMenuCacheClearing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      onTap: _clearMessMenuCache,
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
                            ref.read(analyticsServiceProvider).logEvent(
                              AnalyticsEvents.settingChanged,
                              {
                                AnalyticsParams.setting: 'font_scale',
                                AnalyticsParams.value: value.toStringAsFixed(1),
                              },
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

              const SizedBox(height: 24),

              MenuSection(
                label: 'Privacy',
                children: [
                  MenuTile(
                    icon: Iconsax.security_safe_copy,
                    title: 'Usage Analytics',
                    infoText:
                        'Share anonymous usage data to help improve the app',
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: userPreferences.analyticsEnabled,
                        thumbIcon: const WidgetStateProperty<Icon?>.fromMap({
                          WidgetState.selected: Icon(Icons.check_rounded),
                          WidgetState.any: Icon(Icons.close_rounded),
                        }),
                        onChanged: (value) async {
                          // Deliberately not logged: recording the moment
                          // someone opts out would defeat the opt-out.
                          await userPreferencesNotifier.toggleAnalytics(value);
                        },
                      ),
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
