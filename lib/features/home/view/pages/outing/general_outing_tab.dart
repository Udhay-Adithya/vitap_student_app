import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/core/common/widget/app_input_decoration.dart';
import 'package:vit_ap_student_app/core/common/widgets/common_date_picker.dart';
import 'package:vit_ap_student_app/core/common/widgets/common_time_picker.dart';
import 'package:vit_ap_student_app/core/services/review_prompt_service.dart';
import 'package:vit_ap_student_app/core/utils/format_to_12_hour.dart';
import 'package:vit_ap_student_app/core/utils/parse_class_time.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/home/utils/outing_rules.dart';
import 'package:vit_ap_student_app/features/home/view/pages/outing/general_outing_history_page.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/outing/outing_confirm_sheet.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/outing/outing_form_widgets.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/outing_submission_viewmodel.dart';

class GeneralOutingTab extends ConsumerStatefulWidget {
  const GeneralOutingTab({super.key});

  @override
  ConsumerState<GeneralOutingTab> createState() => _GeneralOutingTabState();
}

class _GeneralOutingTabState extends ConsumerState<GeneralOutingTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  String? _fromTime;
  String? _toTime;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void dispose() {
    _placeController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  String? _timeValidator(String? value) {
    if (value == null) return 'Select a time';
    final DateTime? parsed = parseClassTime(value);
    if (parsed == null) return 'Select a time';
    if (!isOutingTimeAllowed(
      TimeOfDay(hour: parsed.hour, minute: parsed.minute),
    )) {
      return 'Must be between ${_clock(outingWindowStart)} '
          'and ${_clock(outingWindowEnd)}';
    }
    return null;
  }

  /// Builds the window bounds from the rule itself, so the message can't drift
  /// out of step with what the rule actually allows.
  String _clock(TimeOfDay time) => formatTo12Hour(
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}',
  );

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Nothing related the two halves of the trip before, so a return earlier
    // than the departure submitted happily and failed at VTOP.
    final String? spanError = validateOutingSpan(
      fromDate: _fromDate,
      fromTime: _fromTime,
      toDate: _toDate,
      toTime: _toTime,
    );
    if (spanError != null) {
      showSnackBar(context, spanError, SnackBarType.warning);
      return;
    }

    final bool confirmed = await showOutingConfirmSheet(
      context,
      title: 'Apply for general outing',
      details: <(String, String)>[
        ('Place', _placeController.text.trim()),
        ('Purpose', _purposeController.text.trim()),
        ('Leaving', _describe(_fromDate, _fromTime)),
        ('Returning', _describe(_toDate, _toTime)),
      ],
    );
    if (!confirmed || !mounted) return;

    await ref
        .read(generalOutingSubmissionProvider.notifier)
        .submitGeneralOuting(
          outPlace: _placeController.text.trim(),
          purposeOfVisit: _purposeController.text.trim(),
          outingDate: DateFormat('dd-MMM-yyyy').format(_fromDate!),
          outTime: _fromTime!,
          inDate: DateFormat('dd-MMM-yyyy').format(_toDate!),
          inTime: _toTime!,
        );
  }

  String _describe(DateTime? date, String? time) {
    if (date == null || time == null) return '—';
    return '${DateFormat('EEE, d MMM').format(date)} · ${formatTo12Hour(time)}';
  }

  void _clearForm() {
    _placeController.clear();
    _purposeController.clear();
    setState(() {
      _fromTime = null;
      _toTime = null;
      _fromDate = null;
      _toDate = null;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = ref.watch(
      generalOutingSubmissionProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(generalOutingSubmissionProvider, (_, next) {
      next?.when(
        data: (message) {
          showSnackBar(context, message, SnackBarType.success);
          _clearForm();
          // A task that finished, with nothing left on screen to read — unlike a
          // refresh, where a sheet would cover the very thing you asked for.
          unawaited(
            ref
                .read(reviewPromptServiceProvider)
                .recordHappyMoment('general_outing_applied'),
          );
        },
        loading: () {},
        error: (error, st) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });

    final DateTime now = DateTime.now();
    final DateTime lastDate = now.add(
      const Duration(days: generalOutingMaxDaysAhead),
    );

    return SingleChildScrollView(
      // Top inset so the first field's floating label isn't clipped by the
      // viewport edge before the form is even scrolled.
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _placeController,
              decoration: appInputDecoration(
                context,
                labelText: 'Place of visit',
                hintText: 'Where are you going?',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (String? value) => (value ?? '').trim().isEmpty
                  ? 'Enter the place of visit'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _purposeController,
              decoration: appInputDecoration(
                context,
                labelText: 'Purpose of visit',
                hintText: 'Why are you going?',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              validator: (String? value) => (value ?? '').trim().isEmpty
                  ? 'Enter the purpose of visit'
                  : null,
            ),
            const SizedBox(height: 20),

            // Date and time are one decision each, so they sit on one row —
            // four stacked full-width pickers hid that these are two moments,
            // not four settings.
            const OutingFieldLabel('Leaving'),
            _DateTimeRow(
              date: CommonDatePicker(
                label: 'Date',
                selectedDate: _fromDate,
                firstDate: now,
                lastDate: lastDate,
                onDateSelected: (DateTime date) =>
                    setState(() => _fromDate = date),
                validator: (DateTime? value) =>
                    value == null ? 'Select a date' : null,
              ),
              time: CommonTimePicker(
                label: 'Time',
                selectedTime: _fromTime,
                onTimeSelected: (String time) =>
                    setState(() => _fromTime = time),
                validator: _timeValidator,
              ),
            ),
            const SizedBox(height: 16),
            const OutingFieldLabel('Returning'),
            _DateTimeRow(
              date: CommonDatePicker(
                label: 'Date',
                selectedDate: _toDate,
                firstDate: _fromDate ?? now,
                lastDate: lastDate,
                onDateSelected: (DateTime date) =>
                    setState(() => _toDate = date),
                validator: (DateTime? value) =>
                    value == null ? 'Select a date' : null,
              ),
              time: CommonTimePicker(
                label: 'Time',
                selectedTime: _toTime,
                onTimeSelected: (String time) => setState(() => _toTime = time),
                validator: _timeValidator,
              ),
            ),
            const SizedBox(height: 28),
            OutingApplyButton(isLoading: isLoading, onPressed: _submitForm),
            const SizedBox(height: 10),
            OutingHistoryButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const GeneralOutingHistoryPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A date beside its time.
///
/// The split was 3:2, which left the time column too narrow for a two-digit
/// hour: "2:00 PM" fitted and "10:00 PM" wrapped onto a second line, making
/// that field taller than the date beside it. The date string is longer, so it
/// still gets the larger share — just not by as much.
class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({required this.date, required this.time});

  final Widget date;
  final Widget time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(flex: 4, child: date),
        const SizedBox(width: 10),
        Expanded(flex: 3, child: time),
      ],
    );
  }
}
