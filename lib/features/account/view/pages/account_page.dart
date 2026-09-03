import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/common/widget/app_feedback.dart';
import 'package:vit_ap_student_app/core/common/widget/styled_sheet.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/schedule_home_widget_notifier.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/app_upgrader.dart';
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
import 'package:vit_ap_student_app/features/account/view/widgets/app_upgrade_card.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/footer.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/menu_section.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/menu_tile.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/profile_card.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/support_developer_sheet.dart';
import 'package:vit_ap_student_app/features/account/viewmodel/account_viewmodel.dart';
import 'package:vit_ap_student_app/features/auth/view/pages/login_page.dart';

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
    ref.read(analyticsServiceProvider).logScreen('AccountPage');
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
        ref
            .read(analyticsServiceProvider)
            .logEvent(AnalyticsEvents.developerModeEnabled);
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
      ref
          .read(analyticsServiceProvider)
          .logEvent(AnalyticsEvents.navigationTapped, {
            AnalyticsParams.source: 'AccountPage',
            AnalyticsParams.target: 'ProfilePage',
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
      ref
          .read(analyticsServiceProvider)
          .logEvent(AnalyticsEvents.navigationTapped, {
            AnalyticsParams.source: 'AccountPage',
            AnalyticsParams.target: 'SettingsPage',
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
            'Successfully synced with VTOP.',
            SnackBarType.success,
          );
        },
        loading: () {
          showSnackBar(
            context,
            'Syncing your account data in the background...',
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
            // Renders nothing when the app is current. The launch-time
            // UpgradeAlert can be dismissed with Later; this cannot, so someone
            // who dismissed it still has somewhere that says so.
            AppUpgradeCard(upgrader: appUpgrader),
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
                      ref
                          .read(analyticsServiceProvider)
                          .logEvent(AnalyticsEvents.navigationTapped, {
                            AnalyticsParams.source: 'AccountPage',
                            AnalyticsParams.target: 'ManageCredentialsPage',
                          });
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute<bool>(
                          builder: (builder) => const ManageCredentialsPage(),
                        ),
                      );
                      if (result == true) {
                        ref.read(analyticsServiceProvider).logEvent(
                          AnalyticsEvents.manualSyncInitiated,
                          {AnalyticsParams.source: 'credentials_updated'},
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
                      ref.read(analyticsServiceProvider).logEvent(
                        AnalyticsEvents.manualSyncInitiated,
                        {AnalyticsParams.source: 'AccountPage'},
                      );
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
                      AppFeedback.compose(context);
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
                        'When enabled, your CGPA and credits are hidden on this page.',
                    trailing: Transform.scale(
                      scale: 0.9,
                      child: Switch.adaptive(
                        value: userPreferences.isPrivacyEnabled,
                        thumbIcon: const WidgetStateProperty<Icon?>.fromMap({
                          WidgetState.selected: Icon(Icons.check_rounded),
                          WidgetState.any: Icon(Icons.close_rounded),
                        }),
                        onChanged: (value) async {
                          await userPreferencesNotifier.togglePrivacyMode(
                            value,
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
                  // One entry point rather than two: starring the repo is one of
                  // the options inside the sheet, so a separate tile for it was
                  // a second path to the same place. This tile also used to have
                  // an empty onTap — it rippled and did nothing.
                  MenuTile(
                    icon: Iconsax.award_copy,
                    title: 'Support the developer',
                    background: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    foreground: Theme.of(
                      context,
                    ).colorScheme.onSecondaryContainer,
                    onTap: () => showSupportDeveloperSheet(context),
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

                      // The home screen widget keeps its own copy of the
                      // timetable, outside ObjectBox. Left alone it carries on
                      // showing this student's classes after they sign out.
                      final homeWidget = ref.read(
                        scheduleHomeWidgetProvider.notifier,
                      );
                      await homeWidget.clearTimetable();
                      await homeWidget.updateWidget();

                      await ref.read(currentUserProvider.notifier).logout();
                      if (!context.mounted) return;
                      await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const LoginPage(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                      ref
                          .read(analyticsServiceProvider)
                          .logEvent(AnalyticsEvents.logout);
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
