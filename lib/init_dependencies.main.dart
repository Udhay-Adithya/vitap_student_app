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

  // Initialize Analytics
  await AnalyticsService.initialize();

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

  serviceLocator.registerSingleton<ConnectionChecker>(
    ConnectionCheckerImpl(InternetConnection()),
  );
}
