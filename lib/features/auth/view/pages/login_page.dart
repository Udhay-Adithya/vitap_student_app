import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/auth_field.dart';
import 'package:vit_ap_student_app/core/common/widget/bottom_navigation_bar.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/utils/launch_web.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/core/utils/theme_switch_button.dart';
import 'package:vit_ap_student_app/features/auth/view/pages/semester_selection_page.dart';
import 'package:vit_ap_student_app/features/auth/view/widgets/login_footer.dart';
import 'package:vit_ap_student_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:vit_ap_student_app/features/auth/viewmodel/semester_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // One recogniser per link. These used to share a single recogniser pointed at
  // the site root, so on the screen that asks you to agree to them, neither
  // "Privacy Policy" nor "Terms of Service" opened the document it named.
  late final TapGestureRecognizer _privacyRecognizer;
  late final TapGestureRecognizer _termsRecognizer;

  static const String _privacyUrl = 'https://vitap.udhay-adithya.me/privacy';
  static const String _termsUrl = 'https://vitap.udhay-adithya.me/terms';

  /// One gutter for the whole form, so the fields and the button that submits
  /// them are the same width by construction rather than by two hand-tuned
  /// `MediaQuery` subtractions that happened to disagree by 20pt.
  static const double _gutter = 24;

  @override
  void initState() {
    super.initState();
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => directToWeb(_privacyUrl);
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => directToWeb(_termsUrl);

    ref.read(analyticsServiceProvider).logScreen('LoginPage');
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _privacyRecognizer.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  Future<void> _loginDemo() async {
    ref.read(analyticsServiceProvider).logEvent(AnalyticsEvents.loginAttempt, {
      AnalyticsParams.method: 'demo',
    });
    await ref.read(authViewModelProvider.notifier).loginDemoUser();
    if (!mounted) return;

    ref
        .read(authViewModelProvider)
        ?.when(
          data: (_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const BottomNavBar(),
              ),
              (_) => false,
            );
          },
          error: (error, _) {
            showSnackBar(context, error.toString(), SnackBarType.error);
          },
          loading: () {},
        );
  }

  Future<void> _fetchSemestersAndNavigate() async {
    // Demo account: bypass VTOP entirely (no network, no OTP, no semester
    // selection) and seed the app from the bundled sample dataset.
    if (ref
        .read(demoServiceProvider)
        .isDemoCredentials(usernameController.text, passwordController.text)) {
      await _loginDemo();
      return;
    }

    // Validate before reaching for the network: an empty form with no signal
    // used to report a connectivity problem instead of the empty field.
    if (!_formKey.currentState!.validate()) {
      ref
          .read(analyticsServiceProvider)
          .logError(
            'validation_error',
            'Login form validation failed',
            location: 'login_page',
          );
      return;
    }

    // The typed login id is never logged — it identifies the student.
    ref
        .read(analyticsServiceProvider)
        .logEvent(AnalyticsEvents.semesterFetchAttempt);

    await ref
        .read(semesterViewModelProvider.notifier)
        .fetchSemestersForLogin(
          registrationNumber: usernameController.text.trim().toUpperCase(),
          password: passwordController.text.trim(),
        );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    ref.read(analyticsServiceProvider).logEvent(AnalyticsEvents.loginAttempt, {
      AnalyticsParams.method: 'vtop_credentials',
    });
    _fetchSemestersAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final bool isLoading =
        ref.watch(
          semesterViewModelProvider.select((val) => val?.isLoading == true),
        ) ||
        ref.watch(
          authViewModelProvider.select((val) => val?.isLoading == true),
        );

    ref.listen(semesterViewModelProvider, (previous, next) {
      // Only navigate if this is the initial fetch (previous was null or
      // loading). This prevents re-navigation when SemesterSelectionPage
      // fetches semesters.
      if (previous?.hasValue == true) return;

      next?.when(
        data: (semesters) {
          ref.read(analyticsServiceProvider).logEvent(
            AnalyticsEvents.semesterFetchSuccess,
            {AnalyticsParams.count: semesters.length},
          );
          // VTOP accepted the credentials, so this is the moment they are known
          // good — closing the autofill context is what prompts the OS to offer
          // to save them.
          TextInput.finishAutofillContext();
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => SemesterSelectionPage(
                registrationNumber: usernameController.text.toUpperCase(),
                password: passwordController.text,
              ),
            ),
          );
        },
        error: (error, st) {
          ref
              .read(analyticsServiceProvider)
              .logError('semester_fetch_failed', error, location: 'login_page');
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: const <Widget>[ThemeSwitchButton()],
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          // Scrollable and at least viewport-tall: the page used to be a bare
          // Column pushed apart by two Flexible spacers, so once the keyboard
          // shrank the body the fixed content overflowed.
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: _gutter),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFFFFC68D),
                                  image: const DecorationImage(
                                    scale: 1.2,
                                    image: AssetImage(
                                      'assets/images/logo/app_icon.png',
                                    ),
                                  ),
                                ),
                                // child: Image.asset(
                                //   "assets/images/logo/app_icon.png",
                                //   height: 150,
                                // ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Welcome',
                              style: tt.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in with your VTOP credentials to continue',
                              style: tt.bodyLarge?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 36),
                            AuthField(
                              title: 'Username',
                              hintText: 'VTOP Username',
                              controller: usernameController,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.characters,
                            ),
                            const SizedBox(height: 14),
                            AuthField(
                              title: 'Password',
                              hintText: 'VTOP Password',
                              controller: passwordController,
                              isObscureText: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                if (!isLoading) _submit();
                              },
                            ),
                            const SizedBox(height: 28),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                shape: const StadiumBorder(),
                                textStyle: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                // Stays visibly the button while busy instead
                                // of dropping to a disabled grey.
                                disabledBackgroundColor: cs.primary.withValues(
                                  alpha: 0.7,
                                ),
                                disabledForegroundColor: cs.onPrimary,
                              ),
                              onPressed: isLoading ? null : _submit,
                              child: isLoading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: cs.onPrimary,
                                      ),
                                    )
                                  : const Text('Continue'),
                            ),
                            const Spacer(),
                            const SizedBox(height: 24),
                            LoginFooter(
                              privacyRecognizer: _privacyRecognizer,
                              termsRecognizer: _termsRecognizer,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
