import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';

/// Heading for a group of choices.
///
/// Quiet on purpose. Every label on these forms used to be
/// `fontSize: 16, color: primary, fontWeight: w600`, repeated by hand six times,
/// which put six competing headings above inputs drawn as bare underlines.
class OutingFieldLabel extends StatelessWidget {
  const OutingFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// A single-select chip group that participates in [Form] validation.
class OutingChoiceChips extends StatelessWidget {
  const OutingChoiceChips({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.emptyError,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String emptyError;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return FormField<String>(
      initialValue: value,
      validator: (_) => value == null || value!.isEmpty ? emptyError : null,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            OutingFieldLabel(label),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final String option in options)
                  ChoiceChip(
                    label: Text(option),
                    selected: value == option,
                    // Shape carries the selection alongside colour: the chosen
                    // chip goes fully rounded, the rest stay squarer.
                    shape: value == option
                        ? const StadiumBorder()
                        : RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                    onSelected: (bool selected) {
                      final String? next = selected ? option : null;
                      onChanged(next);
                      state.didChange(next);
                    },
                  ),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 8),
                child: Text(
                  state.errorText!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.error),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The form's primary action.
///
/// Applying writes an official record to VTOP, and it used to be a `TextButton`
/// in `Colors.blue` — the same visual weight as the "view history" link beside
/// it, and off-palette in both themes.
class OutingApplyButton extends StatelessWidget {
  const OutingApplyButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    // Submitting is a write to VTOP, so the demo account cannot do it. The
    // button stays visible and says why — it used to vanish entirely, leaving a
    // filled-in form with no way to submit and no explanation.
    final bool isDemo = DemoService.isDemoMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: const StadiumBorder(),
            textStyle: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            disabledBackgroundColor: isDemo
                ? null
                : cs.primary.withValues(alpha: 0.7),
            disabledForegroundColor: isDemo ? null : cs.onPrimary,
          ),
          onPressed: isDemo || isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: cs.onPrimary,
                  ),
                )
              : const Text('Apply'),
        ),
        if (isDemo)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Applying is disabled for the demo account.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

/// The way through to previously applied outings.
///
/// A labelled button under Apply rather than a bare icon in the app bar — an
/// icon alone is not something people recognise on a screen they visit rarely.
/// Outlined so it reads clearly as the secondary of the two.
class OutingHistoryButton extends StatelessWidget {
  const OutingHistoryButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: Theme.of(context).textTheme.titleMedium,
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.history_rounded, size: 20),
      label: const Text('View outing history'),
    );
  }
}

/// Stands in for the weekend form while VTOP is not serving it.
///
/// The form genuinely does not exist outside Tuesday–Friday — VTOP returns the
/// page without the student fields — so there is nothing to fill in and no
/// request that could be built. Better to say so than to offer inputs that
/// cannot lead anywhere.
class OutingWindowClosedNotice extends StatelessWidget {
  const OutingWindowClosedNotice({
    super.key,
    required this.message,
    required this.opensOn,
  });

  final String message;
  final String opensOn;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.event_busy_rounded, size: 56, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              'Applications are closed',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Opens $opensOn',
                style: tt.labelMedium?.copyWith(
                  color: cs.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
