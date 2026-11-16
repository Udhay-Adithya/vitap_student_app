import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/core/common/widget/app_input_decoration.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';

/// A tappable date field.
///
/// Built on [InputDecorator] rather than an `AbsorbPointer` wrapped around a
/// disabled `TextFormField` — the old version was a text field pretending to be
/// a button, with `labelText` and `hintText` set to the same string so the hint
/// could never appear.
///
/// It also no longer forces `ColorScheme.light` onto the calendar dialog, which
/// made the picker open bright white in the middle of a dark-themed app.
class CommonDatePicker extends StatelessWidget {
  const CommonDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.validator,
  });

  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime)? selectableDayPredicate;

  /// Receives the currently selected date, so the owning form stays the single
  /// source of truth for what has been chosen.
  final String? Function(DateTime?)? validator;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: (_) => validator?.call(selectedDate),
      builder: (FormFieldState<DateTime> state) {
        return InkWell(
          borderRadius: BorderRadius.circular(appInputRadius),
          onTap: () => _pick(context, state),
          child: InputDecorator(
            isEmpty: selectedDate == null,
            decoration:
                appInputDecoration(
                  context,
                  labelText: label,
                  suffixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                  ),
                ).copyWith(
                  errorText: state.errorText,
                  // The icon is decoration — the whole field is the tap target — so
                  // it doesn't need the 48px minimum a real icon button gets. That
                  // floor was costing this column a third of its text width when it
                  // sits beside another field.
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
            child: Text(
              selectedDate == null
                  ? ''
                  : DateFormat('EEE, d MMM yyyy').format(selectedDate!),
              style: tt.bodyLarge?.copyWith(color: cs.onSurface),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pick(
    BuildContext context,
    FormFieldState<DateTime> state,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime start = _dayOf(firstDate ?? now);
    final DateTime end = _dayOf(lastDate ?? now.add(const Duration(days: 720)));

    final DateTime? initialDate = _firstSelectable(start, end);
    if (initialDate == null) {
      // Every day in range is excluded, so opening the picker would show a
      // calendar with nothing to tap. Say so instead of doing nothing.
      showSnackBar(
        context,
        'No dates are available to choose right now',
        SnackBarType.warning,
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: start,
      lastDate: end,
      selectableDayPredicate: selectableDayPredicate,
    );

    if (picked != null) {
      onDateSelected(picked);
      state.didChange(picked);
    }
  }

  /// The date the calendar should open on: the current selection when it is
  /// still valid, otherwise the first day in range that is.
  ///
  /// Replaces three chained 30-and-60 iteration search loops that could still
  /// fall through and silently refuse to open.
  DateTime? _firstSelectable(DateTime start, DateTime end) {
    bool allowed(DateTime date) => selectableDayPredicate?.call(date) ?? true;

    final DateTime? current = selectedDate;
    if (current != null &&
        !_dayOf(current).isBefore(start) &&
        !_dayOf(current).isAfter(end) &&
        allowed(current)) {
      return current;
    }

    for (
      DateTime day = start;
      !day.isAfter(end);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      if (allowed(day)) return day;
    }
    return null;
  }

  static DateTime _dayOf(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
