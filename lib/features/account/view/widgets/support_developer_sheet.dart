import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/launch_web.dart';

/// Ways to back the app, in one place.
///
/// Free options come first on purpose. Starring the repo and leaving a review
/// cost nothing and are what most people will actually do; leading with money
/// makes the rest of the sheet read as a preamble to an ask.
///
/// ## Why this stays outside in-app purchase
///
/// Both stores carve out person-to-person money transfers, and this sheet is
/// built to sit squarely inside those carve-outs:
///
/// - Apple guideline 3.2.1 permits a monetary gift outside IAP when it is
///   completely optional and 100% of the funds reach the recipient — but *not*
///   when it is "connected to or associated at any point in time with receiving
///   digital content or services".
/// - Google Play treats the same thing as a peer-to-peer payment when 100% goes
///   to the creator and nothing digital is granted in return, naming stickers,
///   badges and special emojis as disqualifying.
///
/// So the rule for anyone editing this file: **a contributor must receive
/// absolutely nothing.** No unlocked features, no ad removal, no supporter
/// badge, no priority anything. The moment a benefit is attached, both
/// exceptions evaporate and this has to become in-app purchase.
///
/// Language matters too. Nothing here may read as a purchase — no "buy",
/// "unlock", "premium", "plan", and nothing implying payment is needed to use
/// the app.
void showSupportDeveloperSheet(BuildContext context) {
  ProviderScope.containerOf(
    context,
    listen: false,
  ).read(analyticsServiceProvider).logEvent(AnalyticsEvents.supportSheetOpened);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (BuildContext context) => const _SupportDeveloperSheet(),
  );
}

class _SupportDeveloperSheet extends ConsumerWidget {
  const _SupportDeveloperSheet();

  static const String _repoUrl =
      'https://github.com/Udhay-Adithya/vitap_student_app';

  /// The developer's UPI address. Empty until set, and the option is hidden
  /// while it is empty so a broken button can never ship.
  static const String _upiId = 'udhayxd@okaxis';
  static const String _upiPayeeName = 'Udhay Adithya';

  /// Android resolves `upi://pay` to whichever UPI app the student already
  /// uses. No amount is prefilled — the giver chooses, which is part of what
  /// makes it optional.
  static String get _upiUri =>
      'upi://pay?pa=$_upiId&pn=${Uri.encodeComponent(_upiPayeeName)}&cu=INR';

  static bool get _canContribute => _upiId.isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            M3EContainer.pill(
              height: 75,
              width: 75,
              color: cs.secondaryContainer,
              child: Icon(
                Iconsax.heart,
                color: Colors.redAccent.shade200,
                size: 32,
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Support the app',
              style: tt.headlineSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This app is built and maintained by a student, in his own '
              'time, and is free with no ads. If it has been useful, here are '
              'a few ways to help.',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            _SupportOption(
              icon: Iconsax.star_1,
              title: 'Star it on GitHub',
              subtitle: 'Free, takes a second, and helps others find it',
              onTap: () {
                ref.read(analyticsServiceProvider).logEvent(
                  AnalyticsEvents.supportActionTapped,
                  <String, Object?>{AnalyticsParams.method: 'github_star'},
                );
                directToWeb(_repoUrl);
              },
            ),
            const SizedBox(height: 8),
            _SupportOption(
              icon: Iconsax.code_1,
              title: 'Contribute',
              subtitle: 'Report a bug, suggest a feature, or send a fix',
              onTap: () {
                ref.read(analyticsServiceProvider).logEvent(
                  AnalyticsEvents.supportActionTapped,
                  <String, Object?>{AnalyticsParams.method: 'contribute'},
                );
                directToWeb('$_repoUrl/issues');
              },
            ),
            if (_canContribute) ...<Widget>[
              const SizedBox(height: 8),
              _SupportOption(
                icon: Iconsax.coffee,
                title: 'Send a coffee',
                subtitle: 'Any amount, through your usual UPI app',
                onTap: () {
                  ref.read(analyticsServiceProvider).logEvent(
                    AnalyticsEvents.supportActionTapped,
                    <String, Object?>{
                      AnalyticsParams.method: Platform.isAndroid
                          ? 'upi'
                          : 'external_link',
                    },
                  );
                  directToWeb(_upiUri);
                },
              ),
            ],
            const SizedBox(height: 20),
            // Not boilerplate: this sentence is the thing that keeps the sheet
            // inside both stores' person-to-person exceptions, and it is also
            // simply true.
            Text(
              'Nothing here is required, and contributors receive nothing in '
              'return — no extra features, no ad removal, no badge. The app is '
              'exactly the same either way.',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportOption extends StatelessWidget {
  const _SupportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22, color: cs.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: tt.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.north_east_rounded,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
