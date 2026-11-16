import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/common/widget/app_input_decoration.dart';
import 'package:vit_ap_student_app/core/utils/format_to_12_hour.dart';

/// A tappable time field, storing `HH:mm`.
///
/// Deliberately accepts whatever you pick and leaves the judging to [validator].
/// It used to take a `timeValidator` that both decided validity *and* raised a
/// snackbar, then silently discarded the pick — so an out-of-hours time gave you
/// a toast that vanished and a field that looked untouched. Now the rule is a
/// pure function in `outing_rules.dart` and the complaint stays attached to the
/// field until you fix it.
class CommonTimePicker extends StatelessWidget {
  const CommonTimePicker({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onTimeSelected,
    this.initialTime,
    this.validator,
  });

  final String label;

  /// `HH:mm`, or null when nothing is chosen yet.
  final String? selectedTime;

  final ValueChanged<String> onTimeSelected;
  final TimeOfDay? initialTime;

  /// Receives the currently selected `HH:mm`, so the owning form stays the
  /// single source of truth.
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return FormField<String>(
      initialValue: selectedTime,
      validator: (_) => validator?.call(selectedTime),
      builder: (FormFieldState<String> state) {
        return InkWell(
          borderRadius: BorderRadius.circular(appInputRadius),
          onTap: () => _pick(context, state),
          child: InputDecorator(
            isEmpty: selectedTime == null,
            decoration:
                appInputDecoration(
                  context,
                  labelText: label,
                  suffixIcon: const Icon(Icons.schedule_rounded, size: 20),
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
              selectedTime == null ? '' : formatTo12Hour(selectedTime),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: tt.bodyLarge?.copyWith(color: cs.onSurface),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pick(BuildContext context, FormFieldState<String> state) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? _asTimeOfDay(selectedTime) ?? TimeOfDay.now(),
    );
    if (picked == null) return;

    final String value =
        '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
    onTimeSelected(value);
    state.didChange(value);
  }

  static TimeOfDay? _asTimeOfDay(String? value) {
    if (value == null) return null;
    final List<String> parts = value.split(':');
    if (parts.length != 2) return null;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
