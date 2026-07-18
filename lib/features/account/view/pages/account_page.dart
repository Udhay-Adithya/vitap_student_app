import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/utils/launch_web.dart';
import 'package:vit_ap_student_app/core/utils/share_utils.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/core/utils/show_toast.dart';
import 'package:vit_ap_student_app/features/account/view/pages/about_page.dart';
import 'package:vit_ap_student_app/features/account/view/pages/changelog_page.dart';
import 'package:vit_ap_student_app/features/account/view/pages/faq_page.dart';
import 'package:vit_ap_student_app/features/account/view/pages/manage_credentials_page.dart';
import 'package:vit_ap_student_app/features/account/view/pages/profile_page.dart';
import 'package:vit_ap_student_app/features/account/view/pages/settings_page.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/footer.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/profile_card.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/settings_category.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/settings_tile.dart';
import 'package:vit_ap_student_app/features/account/viewmodel/account_viewmodel.dart';
import 'package:vit_ap_student_app/features/auth/view/pages/login_page.dart';
import 'package:wiredash/wiredash.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  bool _isNavigating = false;
  int _developerTapCount = 0;
  bool _isDeveloperModeEnabled = false;
  static const int _requiredTaps = 7;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('AccountPage');
  }

  void _handleVersionTap() {
    setState(() {
      _developerTapCount++;
      if (_developerTapCount > 7 && _isDeveloperModeEnabled == true) {
        showToast(context, 'You are already an Developer!');
      }
      if (_developerTapCount >= _requiredTaps && !_isDeveloperModeEnabled) {
        _isDeveloperModeEnabled = true;
        showToast(context, '🔧 Developer mode enabled!');
        AnalyticsService.logEvent('developer_mode_enabled');
      } else if (!_isDeveloperModeEnabled) {
        final remaining = _requiredTaps - _developerTapCount;

        if (remaining <= 3 && remaining > 0) {
          showToast(context, '$remaining taps to enable developer mode');
        }
      }
    });
  }

  Future<void> _navigateToProfile(User? user) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      await AnalyticsService.logEvent('profile_navigation', {
        'from': 'AccountPage',
        'timestamp': DateTime.now().toIso8601String(),
      });

      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (builder) => ProfilePage(user)),
      );
    } finally {
      if (mounted) {
        _isNavigating = false;
      }
    }
  }

  Future<void> _navigateToSettings() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      await AnalyticsService.logEvent('settings_navigation', {
        'from': 'AccountPage',
        'timestamp': DateTime.now().toIso8601String(),
      });

      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (builder) =>
              SettingsPage(isDeveloperModeEnabled: _isDeveloperModeEnabled),
        ),
      );
    } finally {
      if (mounted) {
        _isNavigating = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userPreferences = ref.watch(userPreferencesProvider);
    final userPreferencesNotifier = ref.read(userPreferencesProvider.notifier);

    ref.listen(accountViewModelProvider, (_, next) {
      next?.when(
        data: (data) {
          showSnackBar(
            context,
            'Successfully synced with VTOP',
            SnackBarType.success,
          );
        },
        loading: () {
          showSnackBar(
            context,
            'Syncing with VTOP in the background...',
            SnackBarType.warning,
          );
        },
        error: (error, st) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Account',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileCard(user: user),
            const SizedBox(height: 24),
            const SettingsCategory('Account'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    width: 0.75,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SettingTile(
                      isFirst: true,
                      isLast: false,
                      title: 'Profile',
                      leadingIcon: const Icon(Iconsax.user_copy),
                      trailingIcon: Icon(
                        Icons.arrow_forward_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () => _navigateToProfile(user),
                    ),
                    // Managing VTOP credentials is meaningless for the demo
                    // account, so the entry point is hidden in demo mode.
                    if (!DemoService.isDemoMode)
                      SettingTile(
                        isFirst: false,
                        isLast: false,
                        title: 'Manage Credentials',
                        leadingIcon: const Icon(Iconsax.lock_1_copy),
                        trailingIcon: Icon(
                          Icons.arrow_forward_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: () async {
                          await AnalyticsService.logEvent(
                            'manage_credentials_navigation',
                            {
                              'from': 'AccountPage',
                              'timestamp': DateTime.now().toIso8601String(),
                            },
                          );
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute<bool>(
                              builder: (builder) =>
                                  const ManageCredentialsPage(),
                            ),
                          );
                          if (result == true) {
                            await AnalyticsService.logEvent(
                              'credentials_updated_sync_triggered',
                            );
                            await ref
                                .read(accountViewModelProvider.notifier)
                                .sync();
                          }
                        },
                      ),
                    SettingTile(
                      isFirst: false,
                      isLast: false,
                      title: 'Sync',
                      infoText:
                          'When synced, latest data will be fetched from VTOP.',
                      leadingIcon: const Icon(Iconsax.repeat),
                      trailingIcon: Icon(
                        Icons.arrow_forward_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () async {
                        await AnalyticsService.logEvent('manual_sync_initiated', {
                          'from': 'AccountPage',
                          'timestamp': DateTime.now().toIso8601String(),
                        });
                        await ref.read(accountViewModelProvider.notifier).sync();
                      },
                    ),
                    SettingTile(
                      isFirst: false,
                      isLast: false,
                      title: 'Settings',
                      leadingIcon: const Icon(Iconsax.setting_2_copy),
                      trailingIcon: Icon(
                        Icons.arrow_forward_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: _navigateToSettings,
                    ),
                  ],
                ),
              ),
            ),
            const SettingsCategory('App'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    width: 0.75,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SettingTile(
                      isFirst: true,
                      isLast: false,
                      title: 'Help & Feedback',
                      leadingIcon: const Icon(Iconsax.support_copy),
                      trailingIcon: Icon(
                        Icons.arrow_forward_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () {
                        Wiredash.of(context).show();
                      },
                    ),
                    SettingTile(
                      isFirst: false,
                      isLast: false,
                      title: "FAQ's",
                      leadingIcon: const Icon(Iconsax.archive_copy),
                      trailingIcon: Icon(
                        Icons.arrow_forward_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (builder) => const FAQPage(),
                          ),
                        );
                      },
                    ),
                    SettingTile(
                      isFirst: false,
                      isLast: false,
                      title: 'Share',
                      leadingIcon: const Icon(Iconsax.share_copy),
                      trailingIcon: Icon(
                        Icons.arrow_forward_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () async {
                        await ShareUtils.instance.shareApp(context);
                      },
                    ),
                    SettingTile(
                      isFirst: false,
                      isLast: false,
                      title: 'Privacy policy',
                      leadingIcon: const Icon(Iconsax.document_copy),
                      trailingIcon: Icon(
                        Icons.arrow_forward_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () async {
                        await directToWeb(
                          'https://vitap.udhay-adithya.me/privacy',
                        );
                      },
                    ),
                    SettingTile(
                      isFirst: false,
                      isLast: true,
                      title: 'Privacy Mode',
                      infoText:
                          'When enabled, your grades will be hidden in the home page.',
                      leadingIcon: const Icon(Iconsax.security_copy),
                      trailingWidget: Transform.scale(
                        scale: 0.9,
                        child: Switch.adaptive(
                          value: userPreferences.isPrivacyEnabled,
                          onChanged: (value) async {
                            final updatedPreferences = userPreferences.copyWith(
                              isPrivacyEnabled: value,
                            );
                            await userPreferencesNotifier.updatePreferences(
                              updatedPreferences,
                            );
                          },
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SettingsCategory('Actions'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    width: 0.75,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SettingTile(
                      isFirst: true,
                      isLast: false,
                      title: 'Star us on Github',
                      leadingIcon: const Icon(Iconsax.star),
                      leadingIconColor: Colors.amber,
                      leadingIconBackgroundColor: Colors.yellow.shade100
                          .withValues(alpha: 0.5),
                      onTap: () async {
                        await directToWeb(
                          'https://github.com/VITAP-Student-Project/vitap_student_app',
                        );
                      },
                    ),
                    SettingTile(
                      isFirst: false,
                      isLast: false,
                      title: 'Logout',
                      leadingIcon: const Icon(Iconsax.logout),
                      leadingIconColor: Colors.red,
                      leadingIconBackgroundColor: Colors.red.shade100,
                      titleColor: Colors.redAccent,
                      onTap: () async {
                        await ref.read(currentUserProvider.notifier).logout();
                        await Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const LoginPage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                        await AnalyticsService.logEvent('logout');
                      },
                    ),
                    SettingTile(
                      isFirst: false,
                      isLast: false,
                      title: 'Changelog',
                      leadingIcon: const Icon(Iconsax.document_text_copy),
                      leadingIconColor: Colors.teal,
                      leadingIconBackgroundColor: Colors.teal.shade100,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (builder) => const ChangelogPage(),
                          ),
                        );
                      },
                    ),
                    SettingTile(
                      isFirst: false,
                      isLast: true,
                      title: 'About',
                      leadingIcon: const Icon(Iconsax.info_circle_copy),
                      leadingIconColor: Colors.blue,
                      leadingIconBackgroundColor: Colors.blue.shade100,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (builder) => const AboutPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            Footer(onVersionTap: _handleVersionTap),
          ],
        ),
      ),
    );
  }
}
