part of 'init_dependencies.dart';

/// Prepares everything the first frame needs and returns the container the
/// app runs on.
///
/// Startup work reads its dependencies from that same container, so the
/// analytics opt-out and the session guard act on the instances the widgets
/// will see.
Future<ProviderContainer> initDependencies() async {
  final objectbox = await ObjectBox.create();
  final container = ProviderContainer(
    overrides: [storeProvider.overrideWithValue(objectbox.store)],
  );

  // Hydrate the demo-mode flag so it can be read synchronously everywhere.
  await DemoService.init();

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

  // Honour the persisted analytics opt-out before anything is able to log.
  // The store is already open, so preferences are read straight from it
  // rather than through the user preferences notifier.
  final analytics = container.read(analyticsServiceProvider);
  final storedPreferences = objectbox.store
      .box<UserPreferences>()
      .query()
      .build()
      .findFirst();
  await analytics.initialize(
    enabled: storedPreferences?.analyticsEnabled ?? true,
  );

  // Initialize Timezone
  tzlt.initializeTimeZones();
  final kolkata = tz.getLocation('Asia/Kolkata');
  tz.setLocalLocation(kolkata);

  // A stored user with no credentials behind it cannot reach VTOP, so drop it
  // before the first frame decides which page to open on.
  await discardSessionWithoutCredentials(
    store: objectbox.store,
    secureStorage: container.read(secureStorageServiceProvider),
  );

  // Warm up the fonts before the first frame paints.
  await _preloadFonts();

  return container;
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
