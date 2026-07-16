import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A floating confirmation card that slides up from the bottom edge — this
/// app's replacement for center dialogs. Fully rounded and inset from the
/// screen edges, with a shaped hero icon and stacked full-width actions.
/// Destructive confirmations swap to error colors.
///
/// Resolves to `true` only when the confirm action is tapped; dismissing by
/// scrim tap, drag, or back gesture resolves to `false`.
class StyledSheet extends StatelessWidget {
  const StyledSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;
  final bool destructive;

  static Future<bool> show(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StyledSheet(
          icon: icon,
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          destructive: destructive,
        );
      },
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final Color heroBackground = destructive
        ? cs.errorContainer
        : cs.secondaryContainer;
    final Color heroForeground = destructive
        ? cs.onErrorContainer
        : cs.onSecondaryContainer;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      // Dialog spec: container width is capped at 560dp on larger screens.
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Material(
          color: cs.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: heroBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: heroForeground),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.unbounded(
                    textStyle: tt.titleLarge,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(
                    height: 1.4,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      textStyle: tt.titleMedium,
                      backgroundColor: destructive ? cs.error : null,
                      foregroundColor: destructive ? cs.onError : null,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmLabel),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(textStyle: tt.titleMedium),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
