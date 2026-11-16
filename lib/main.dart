import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/app_feedback.dart';
import 'package:vit_ap_student_app/core/common/widget/bottom_navigation_bar.dart';
import 'package:vit_ap_student_app/core/observers/analytics_route_observer.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/schedule_home_widget_notifier.dart';
import 'package:vit_ap_student_app/core/providers/theme_mode_notifier.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/app_upgrader.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/core/utils/app_licenses.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/app_upgrade_alert.dart';
import 'package:vit_ap_student_app/features/auth/view/widgets/auth_failure_bottom_sheet.dart';
import 'package:vit_ap_student_app/features/auth/view/widgets/login_otp_bottom_sheet.dart';
import 'package:vit_ap_student_app/features/onboarding/view/pages/onboarding_page.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:wiredash/wiredash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerAppLicenses();
  await initDependencies();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final AnalyticsRouteObserver _routeObserver = AnalyticsRouteObserver(
    serviceLocator<AnalyticsService>(),
  );
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<void>? _otpSubscription;
  StreamSubscription<String>? _authFailureSubscription;
  bool _isOtpSheetShowing = false;
  bool _isAuthFailureSheetShowing = false;

  @override
  void initState() {
    super.initState();
    _otpSubscription = serviceLocator<VtopClientService>().onOtpRequired.listen(
      (_) => _showGlobalOtpSheet(),
    );
    _authFailureSubscription = serviceLocator<VtopClientService>().onAuthFailure
        .listen((message) => _showGlobalAuthFailureSheet(message));
  }

  @override
  void dispose() {
    _otpSubscription?.cancel();
    _authFailureSubscription?.cancel();
    super.dispose();
  }

  void _showGlobalOtpSheet() {
    if (_isOtpSheetShowing) return;
    final navigatorState = _navigatorKey.currentState;
    if (navigatorState == null) return;
    final overlay = navigatorState.overlay;
    if (overlay == null) return;

    _isOtpSheetShowing = true;
    showLoginOtpBottomSheet(context: overlay.context).whenComplete(() {
      _isOtpSheetShowing = false;
      // Safety net: if the sheet closed without resolving OTP
      // (e.g. unexpected dismissal), cancel the pending completer
      // so the blocked operation doesn't hang forever.
      final vtopService = serviceLocator<VtopClientService>();
      if (vtopService.isOtpPending) {
        vtopService.cancelOtp();
      }
    });
  }

  void _showGlobalAuthFailureSheet(String message) {
    if (_isAuthFailureSheetShowing) return;
    final navigatorState = _navigatorKey.currentState;
    if (navigatorState == null) return;
    final overlay = navigatorState.overlay;
    if (overlay == null) return;

    final isLoggedIn = ref.read(currentUserProvider.notifier).isLoggedIn;
    _isAuthFailureSheetShowing = true;
    showAuthFailureBottomSheet(
      context: overlay.context,
      errorMessage: message,
      isLoggedIn: isLoggedIn,
    ).whenComplete(() {
      _isAuthFailureSheetShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Init home widget
    ref.read(scheduleHomeWidgetProvider.notifier).initializeTimetable();
    final isLoggedIn = ref.read(currentUserProvider.notifier).isLoggedIn;
    final themeMode = ref.watch(themeModeProvider);
    final userPreferences = ref.watch(userPreferencesProvider);

    return Wiredash(
      projectId: 'vit-ap-student-app-uh1uuvl',
      secret: dotenv.env['WIREDASH_SECRET_KEY']!,
      theme: appWiredashTheme(themeMode.colorScheme),
      options: const WiredashOptionsData(
        localizationDelegate: AppWiredashLocalizationsDelegate(),
      ),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        themeAnimationCurve: Curves.easeInOut,
        debugShowCheckedModeBanner: false,
        theme: themeMode,
        title: 'VITAP Student',
        navigatorObservers: [_routeObserver],
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(userPreferences.fontScale ?? 1.0),
            ),
            child: child!,
          );
        },
        home: AppUpgradeAlert(
          upgrader: appUpgrader,
          child: isLoggedIn ? const BottomNavBar() : const OnboardingPage(),
        ),
      ),
    );
  }
}
