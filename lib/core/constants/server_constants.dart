class ServerConstants {
  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 20); // seconds
  static const int maxRetryAttempts = 3;

  // VTOP Configuration
  static const String vtopBaseUrl = 'https://vtop.vitap.ac.in';
  static const String vtopDomain = 'vtop.vitap.ac.in';

  // VTOP Routes
  static const String vtopOpenPage = '/vtop/open/page';
  static const String vtopContentPage = '/vtop/content';
  static const String vtopLoginPage = '/vtop/login';
  static const String vtopPreLoginPage = '/vtop/prelogin';

  static const String hostelWifiBaseUrl =
      'https://hfw.vitap.ac.in:8090/httpclient.html';
  static const String universityWifiBaseUrl = 'http://172.18.10.10:1000';

  /// The grade history goes after `#data=`, never in the query string: see
  /// [cgpaCalculatorUrlFor].
  static const String cgpaCalculatorReportUrl =
      'https://cgpa-calculator-vitap.vercel.app/report';

  static const String githubBaseUrl =
      'https://raw.githubusercontent.com/Udhay-Adithya/vitap_student_app/main';

  // For You API Configuration
  static const String forYouApiBaseUrl =
      'https://vitap-foryou-admin.vitap-foryou-admin.workers.dev/api';
}
