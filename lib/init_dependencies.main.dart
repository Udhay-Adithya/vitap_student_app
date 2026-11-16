part of 'init_dependencies.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await initObjectBox();
  await initServices();
  await RustLib.init();

  // Dotenv
  await dotenv.load(fileName: '.env');

  await HomeWidget.setAppGroupId('group.com.udhay.vitapstudentapp');

  await NotificationService.initialize();

  // Block Landscape View
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  // explicitly restore the status bar after initialization
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
  );

  // Init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register analytics and honour the persisted opt-out before anything is
  // able to log. The store is already open, so preferences can be read
  // directly rather than waiting for the Riverpod container.
  final analytics = FirebaseAnalyticsService();
  serviceLocator.registerSingleton<AnalyticsService>(analytics);
  final storedPreferences = serviceLocator<Store>()
      .box<UserPreferences>()
      .query()
      .build()
      .findFirst();
  await analytics.initialize(
    enabled: storedPreferences?.analyticsEnabled ?? true,
  );

  // Register the InterceptedClient
  serviceLocator.registerSingleton<http.Client>(Client());

  // Register SSL client that trusts the VTOP server certificate
  serviceLocator.registerSingleton<IOClient>(
    IOClient(
      HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) =>
                host == ServerConstants.vtopDomain,
    ),
  );

  // Initialize Timezone
  tzlt.initializeTimeZones();
  final kolkata = tz.getLocation('Asia/Kolkata');
  tz.setLocalLocation(kolkata);

  // A stored user with no credentials behind it cannot reach VTOP, so drop it
  // before the first frame decides which page to open on.
  await discardSessionWithoutCredentials();

  // Warm up the fonts before the first frame paints.
  await _preloadFonts();
}

/// Warms up the fonts that are still fetched at runtime via `google_fonts`, so
/// the first frame paints with the real typefaces instead of the default
/// fallback and then swapping in.
///
/// Only the display (Unbounded) and monospace (Google Sans Code)
/// fonts are still downloaded on demand. Each weight
/// is a distinct file, so every weight the app renders is
/// requested explicitly: invoking a `GoogleFonts.*` method queues its download
/// (or a read from the on-device cache on later launches), and
/// [GoogleFonts.pendingFonts] waits for those queued loads to finish.
///
/// Failures (e.g. no network on a fresh install) are swallowed: the fonts fall
/// back gracefully and load lazily on demand, and a slow network can't hold
/// startup hostage thanks to the timeout.
Future<void> _preloadFonts() async {
  try {
    // Display font used in section headers / styled sheets / profile card.
    GoogleFonts.unbounded(fontWeight: FontWeight.w600);
    GoogleFonts.unbounded(fontWeight: FontWeight.w700);

    // Monospace font used in the developer sheet.
    GoogleFonts.googleSansCode(fontWeight: FontWeight.w600);

    await GoogleFonts.pendingFonts().timeout(
      const Duration(seconds: 5),
      onTimeout: () => const [],
    );
  } catch (_) {
    // Non-fatal: fonts will load lazily on demand.
  }
}

Future<void> initObjectBox() async {
  final objectbox = await ObjectBox.create();
  serviceLocator.registerSingleton<Store>(objectbox.store);
}

Future<void> initServices() async {
  serviceLocator.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(),
  );

  serviceLocator.registerSingleton<SecureStorageService>(
    SecureStorageService(serviceLocator<FlutterSecureStorage>()),
  );

  serviceLocator.registerSingleton<VtopClientService>(VtopClientService());

  // Hydrate the demo-mode flag so it can be read synchronously everywhere.
  await DemoService.init();
}
