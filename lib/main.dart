import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upgrader/upgrader.dart';
import 'package:vit_ap_student_app/core/common/widget/bottom_navigation_bar.dart';
import 'package:vit_ap_student_app/core/observers/analytics_route_observer.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/schedule_home_widget_notifier.dart';
import 'package:vit_ap_student_app/core/providers/theme_mode_notifier.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/features/auth/view/widgets/login_otp_bottom_sheet.dart';
import 'package:vit_ap_student_app/features/onboarding/view/pages/onboarding_page.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:wiredash/wiredash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  final AnalyticsRouteObserver _routeObserver = AnalyticsRouteObserver();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  DateTime? _sessionStartTime;
  bool _sessionEnded = false;
  StreamSubscription<void>? _otpSubscription;
  bool _isOtpSheetShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStartTime = DateTime.now();
    _sessionEnded = false;

    _otpSubscription = serviceLocator<VtopClientService>()
        .onOtpRequired
        .listen((_) => _showGlobalOtpSheet());
  }

  @override
  void dispose() {
    _otpSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _endSessionIfNeeded();
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
    });
  }

  void _endSessionIfNeeded() {
    if (_sessionStartTime != null && !_sessionEnded) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!);
      AnalyticsService.logSessionEnd(sessionDuration.inSeconds);
      _sessionEnded = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _sessionStartTime = DateTime.now();
        _sessionEnded = false;
        break;
      case AppLifecycleState.paused:
        _endSessionIfNeeded();
        break;
      case AppLifecycleState.detached:
        _endSessionIfNeeded();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Init home widget
    ref.read(scheduleHomeWidgetProvider.notifier).initializeTimetable();
    final isLoggedIn =
        ref.read(currentUserProvider.notifier).isLoggedIn;
    final themeMode = ref.watch(themeModeProvider);
    final userPreferences = ref.watch(userPreferencesProvider);

    return Wiredash(
      projectId: 'vit-ap-student-app-uh1uuvl',
      secret: dotenv.env['WIREDASH_SECRET_KEY']!,
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
                textScaler: TextScaler.linear(
              userPreferences.fontScale ?? 1.0,
            )),
            child: child!,
          );
        },
        home: UpgradeAlert(
          showIgnore: false,
          child: isLoggedIn ? const BottomNavBar() : const OnboardingPage(),
        ),
      ),
    );
  }
}
