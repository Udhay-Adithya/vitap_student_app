import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/common/widget/styled_sheet.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/developer_options_notifier.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/show_toast.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/menu_section.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/menu_tile.dart';

class DeveloperModeTiles extends ConsumerWidget {
  const DeveloperModeTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final developerOptionsAsync = ref.watch(developerOptionsProvider);

    return developerOptionsAsync.when(
      loading: () => const Center(
        child: Padding(padding: EdgeInsets.all(32.0), child: Loader()),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading developer options: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
      data: (state) => _DeveloperOptionsContent(state: state),
    );
  }
}

class _DeveloperOptionsContent extends ConsumerWidget {
  final DeveloperOptionsState state;

  const _DeveloperOptionsContent({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color errorColor = Theme.of(context).colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MenuSection(
          label: 'Debug Information',
          children: [
            _infoTile('App Version', state.appVersion),
            _infoTile('Build Number', state.buildNumber),
            _infoTile('Device Info', state.deviceInfo),
            _infoTile('Flutter Version', state.flutterVersion),
            _infoTile('ObjectBox Version', state.objectBoxVersion),
          ],
        ),

        const SizedBox(height: 24),

        MenuSection(
          label: 'Network & API',
          children: [
            _infoTile('VTOP Session', state.vtopSessionStatus),
            MenuTile(
              icon: Iconsax.refresh,
              title: 'Refresh Session Info',
              onTap: () async {
                await ref
                    .read(developerOptionsProvider.notifier)
                    .refreshVtopSession();
                if (context.mounted) {
                  showToast(context, 'Session info refreshed');
                }
              },
            ),
            MenuTile(
              icon: Iconsax.global_refresh_copy,
              title: 'Force Session Reset',
              onTap: () async {
                try {
                  await ref
                      .read(developerOptionsProvider.notifier)
                      .forceSessionReset();
                  if (context.mounted) {
                    showToast(
                      context,
                      'Session cleared, will refresh on next request',
                    );
                  }
                  await AnalyticsService.logEvent('force_session_refresh');
                } catch (e) {
                  if (context.mounted) {
                    showToast(context, 'Failed to refresh session');
                  }
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        MenuSection(
          label: 'Storage & Database',
          children: [
            _infoTile('ObjectBox Size', state.objectBoxSize),
            _infoTile('Secure Storage Keys', state.secureStorageKeys),

            MenuTile(
              icon: Iconsax.strongbox_copy,
              title: 'View Raw User Object',
              onTap: () => _showRawUserObject(context, ref),
            ),
            MenuTile(
              icon: Iconsax.setting_3_copy,
              title: 'View Raw User Preferences',
              onTap: () => _showRawUserPreferences(context, ref),
            ),
            MenuTile(
              icon: Iconsax.trash_copy,
              title: 'Clear App Data',
              foreground: errorColor,
              onTap: () => _showClearDataDialog(context, ref),
            ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  MenuTile _infoTile(String label, String value) {
    return MenuTile(title: label, subtitle: value);
  }

  void _showRawUserObject(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);

    if (user == null) {
      showToast(context, 'No user data available');
      return;
    }

    final userJson = const JsonEncoder.withIndent('  ').convert(user.toJson());

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Text('Raw User Object'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: userJson));
                showToast(dialogContext, 'Copied to clipboard');
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            userJson,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRawUserPreferences(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(userPreferencesProvider);

    final prefsMap = {
      'id': prefs.id,
      'pfpPath': prefs.pfpPath,
      'isTimetableNotificationsEnabled': prefs.isTimetableNotificationsEnabled,
      'isExamScheduleNotificationEnabled':
          prefs.isExamScheduleNotificationEnabled,
      'timetableNotificationDelay': prefs.timetableNotificationDelay,
      'examScheduleNotificationDelay': prefs.examScheduleNotificationDelay,
      'isPrivacyEnabled': prefs.isPrivacyEnabled,
      'isDarkModeEnabled': prefs.isDarkModeEnabled,
      'lastSync': prefs.lastSync?.toIso8601String(),
      'attendanceLastSync': prefs.attendanceLastSync?.toIso8601String(),
      'marksLastSync': prefs.marksLastSync?.toIso8601String(),
      'examScheduleLastSync': prefs.examScheduleLastSync?.toIso8601String(),
      'isFirstLaunch': prefs.isFirstLaunch,
    };

    final prefsJson = const JsonEncoder.withIndent('  ').convert(prefsMap);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Text('Raw Preferences'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: prefsJson));
                showToast(dialogContext, 'Copied to clipboard');
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            prefsJson,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearDataDialog(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await StyledSheet.show(
      context,
      icon: Icons.delete_forever_rounded,
      title: 'Clear app data?',
      message:
          'This will delete all local data including cached information. '
          'You will need to sync again after this action.',
      confirmLabel: 'Clear all data',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(developerOptionsProvider.notifier).clearAllLocalData();
      if (context.mounted) {
        showToast(context, 'All local data cleared');
      }
      await AnalyticsService.logEvent('clear_all_local_data');
    } catch (e) {
      if (context.mounted) {
        showToast(context, 'Failed to clear data: $e');
      }
    }
  }
}
