import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/common/widget/developer_sheet.dart';
import 'package:vit_ap_student_app/core/common/widget/styled_sheet.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
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
import 'package:vit_ap_student_app/features/account/view/widgets/menu_section.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/menu_tile.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/profile_card.dart';
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MenuSection(
                label: 'Account',
                children: [
                  MenuTile(
                    icon: Iconsax.user_copy,
                    title: 'Profile',
                    onTap: () => _navigateToProfile(user),
                  ),
                  MenuTile(
                    icon: Iconsax.lock_1_copy,
                    title: 'Manage Credentials',
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
                          builder: (builder) => const ManageCredentialsPage(),
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
                  MenuTile(
                    icon: Iconsax.repeat,
                    title: 'Sync',
                    infoText:
                        'When synced, latest data will be fetched from VTOP.',
                    onTap: () async {
                      await AnalyticsService.logEvent('manual_sync_initiated', {
                        'from': 'AccountPage',
                        'timestamp': DateTime.now().toIso8601String(),
                      });
                      await ref.read(accountViewModelProvider.notifier).sync();
                    },
                  ),
                  MenuTile(
                    icon: Iconsax.setting_2_copy,
                    title: 'Settings',
                    onTap: _navigateToSettings,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MenuSection(
                label: 'App',
                children: [
                  MenuTile(
                    icon: Iconsax.support_copy,
                    title: 'Help & Feedback',
                    onTap: () {
                      Wiredash.of(context).show();
                    },
                  ),
                  MenuTile(
                    icon: Iconsax.archive_copy,
                    title: "FAQ's",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (builder) => const FAQPage(),
                        ),
                      );
                    },
                  ),
                  MenuTile(
                    icon: Iconsax.share_copy,
                    title: 'Share',
                    onTap: () async {
                      await ShareUtils.instance.shareApp(context);
                    },
                  ),
                  MenuTile(
                    icon: Iconsax.document_copy,
                    title: 'Privacy policy',
                    onTap: () async {
                      await directToWeb(
                        'https://vitap.udhay-adithya.me/privacy',
                      );
                    },
                  ),
                  MenuTile(
                    icon: Iconsax.security_copy,
                    title: 'Privacy Mode',
                    infoText:
                        'When enabled, your grades will be hidden in the home page.',
                    trailing: Transform.scale(
                      scale: 0.9,
                      child: Switch.adaptive(
                        value: userPreferences.isPrivacyEnabled,
                        thumbIcon: const WidgetStateProperty<Icon?>.fromMap({
                          WidgetState.selected: Icon(Icons.check_rounded),
                          WidgetState.any: Icon(Icons.close_rounded),
                        }),
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MenuSection(
                label: 'Actions',
                children: [
                  MenuTile(
                    icon: Iconsax.award_copy,
                    title: 'Support the developer',
                    background: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    foreground: Theme.of(
                      context,
                    ).colorScheme.onSecondaryContainer,
                    onTap: () {},
                  ),
                  MenuTile(
                    icon: Iconsax.star_copy,
                    title: 'Star us on Github',
                    onTap: () async {
                      await directToWeb(
                        'https://github.com/VITAP-Student-Project/vitap_student_app',
                      );
                    },
                  ),

                  MenuTile(
                    icon: Iconsax.document_text_copy,
                    title: 'Changelog',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (builder) => const ChangelogPage(),
                        ),
                      );
                    },
                  ),
                  MenuTile(
                    icon: Iconsax.info_circle_copy,
                    title: 'About',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (builder) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                  MenuTile(
                    icon: Iconsax.logout,
                    title: 'Logout',
                    foreground: Theme.of(context).colorScheme.error,
                    onTap: () async {
                      final bool confirmed = await StyledSheet.show(
                        context,
                        icon: Icons.logout_rounded,
                        title: 'Log out?',
                        message:
                            'You will need to sign in again with your '
                            'credentials to access your account.',
                        confirmLabel: 'Log out',
                        destructive: true,
                      );
                      if (!confirmed || !context.mounted) return;

                      await ref.read(currentUserProvider.notifier).logout();
                      if (!context.mounted) return;
                      await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const LoginPage(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                      await AnalyticsService.logEvent('logout');
                    },
                  ),
                ],
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
