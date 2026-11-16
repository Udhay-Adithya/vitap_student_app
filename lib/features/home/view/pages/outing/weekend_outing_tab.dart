import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/core/common/widget/app_input_decoration.dart';
import 'package:vit_ap_student_app/core/common/widgets/common_date_picker.dart';
import 'package:vit_ap_student_app/core/constants/app_constants.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/review_prompt_service.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/home/utils/outing_rules.dart';
import 'package:vit_ap_student_app/features/home/view/pages/outing/weekend_outing_history_page.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/outing/outing_confirm_sheet.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/outing/outing_form_widgets.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/outing_submission_viewmodel.dart';

class WeekendOutingTab extends ConsumerStatefulWidget {
  const WeekendOutingTab({super.key});

  @override
  ConsumerState<WeekendOutingTab> createState() => _WeekendOutingTabState();
}

class _WeekendOutingTabState extends ConsumerState<WeekendOutingTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String? _selectedPlace = AppConstants.outingPlaces.first;
  String? _selectedTimeSlot = AppConstants.outingTimeSlots.first;
  DateTime? _outingDate;

  @override
  void dispose() {
    _purposeController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool get _bypassRestriction =>
      ref.read(userPreferencesProvider).bypassWeekendOutingRestriction;

  void _openHistory() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (context) => const WeekendOutingHistoryPage(),
    ),
  );

  Future<void> _submitWeekendOuting() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_bypassRestriction && !isWeekendOutingOpen(_outingDate!)) {
      showSnackBar(
        context,
        'Applications for this date have closed',
        SnackBarType.error,
      );
      return;
    }

    final bool confirmed = await showOutingConfirmSheet(
      context,
      title: 'Apply for weekend outing',
      details: <(String, String)>[
        ('Place', _selectedPlace ?? '—'),
        ('Date', DateFormat('EEE, d MMM yyyy').format(_outingDate!)),
        ('Time slot', _selectedTimeSlot ?? '—'),
        ('Purpose', _purposeController.text.trim()),
        ('Contact', _contactController.text.trim()),
      ],
    );
    if (!confirmed || !mounted) return;

    await ref
        .read(weekendOutingSubmissionProvider.notifier)
        .submitWeekendOuting(
          outPlace: _selectedPlace!,
          purposeOfVisit: _purposeController.text.trim(),
          outingDate: DateFormat('dd-MMM-yyyy').format(_outingDate!),
          outTime: _selectedTimeSlot!,
          contactNumber: _contactController.text.trim(),
        );
  }

  void _clearForm() {
    _purposeController.clear();
    _contactController.clear();
    setState(() {
      _selectedPlace = AppConstants.outingPlaces.first;
      _selectedTimeSlot = AppConstants.outingTimeSlots.first;
      _outingDate = null;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = ref.watch(
      weekendOutingSubmissionProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(weekendOutingSubmissionProvider, (_, next) {
      next?.when(
        data: (message) {
          showSnackBar(context, message, SnackBarType.success);
          _clearForm();
          // A task that finished, with nothing left on screen to read — unlike a
          // refresh, where a sheet would cover the very thing you asked for.
          unawaited(
            ref
                .read(reviewPromptServiceProvider)
                .recordHappyMoment('weekend_outing_applied'),
          );
        },
        loading: () {},
        error: (error, st) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });

    final DateTime now = DateTime.now();

    // VTOP does not serve this form outside Tuesday–Friday, so there is nothing
    // to fill in. The developer bypass still shows it, with a warning, because
    // the point of that switch is to exercise the form.
    final bool formOpen = isWeekendOutingFormOpen(now: now);
    if (!formOpen && !_bypassRestriction) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            OutingWindowClosedNotice(
              message: weekendOutingFormWindowMessage,
              opensOn: DateFormat(
                'EEEE, d MMM',
              ).format(nextWeekendOutingFormOpening(now: now)),
            ),
            OutingHistoryButton(onPressed: _openHistory),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      // Top inset so the first field's floating label isn't clipped by the
      // viewport edge before the form is even scrolled.
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (!formOpen) ...<Widget>[
              const _BypassWarning(message: weekendOutingFormWindowMessage),
              const SizedBox(height: 16),
            ],
            OutingChoiceChips(
              label: 'Place of visit',
              options: AppConstants.outingPlaces,
              value: _selectedPlace,
              onChanged: (String? place) =>
                  setState(() => _selectedPlace = place),
              emptyError: 'Select a place',
            ),
            const SizedBox(height: 20),
            OutingChoiceChips(
              label: 'Time slot',
              options: AppConstants.outingTimeSlots,
              value: _selectedTimeSlot,
              onChanged: (String? slot) =>
                  setState(() => _selectedTimeSlot = slot),
              emptyError: 'Select a time slot',
            ),
            const SizedBox(height: 20),
            CommonDatePicker(
              label: 'Outing date',
              selectedDate: _outingDate,
              firstDate: now,
              lastDate: now.add(const Duration(days: 7)),
              // Sundays and Mondays only, and only while applications are still
              // open. The rule lives in outing_rules.dart so the picker and the
              // submit check can't disagree about it.
              selectableDayPredicate: (DateTime date) =>
                  isSelectableWeekendOutingDate(
                    date,
                    bypass: _bypassRestriction,
                  ),
              onDateSelected: (DateTime date) =>
                  setState(() => _outingDate = date),
              validator: (DateTime? value) =>
                  value == null ? 'Select a date' : null,
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
              textInputAction: TextInputAction.next,
              validator: (String? value) =>
                  (value ?? '').trim().isEmpty ? 'Enter the purpose' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactController,
              decoration: appInputDecoration(
                context,
                labelText: 'Contact number',
                hintText: '10-digit mobile number',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              // Length alone used to be the whole rule, so ten letters passed.
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (String? value) {
                final String digits = (value ?? '').trim();
                if (digits.isEmpty) return 'Enter a contact number';
                if (digits.length != 10) return 'Must be 10 digits';
                return null;
              },
            ),
            const SizedBox(height: 28),
            OutingApplyButton(
              isLoading: isLoading,
              onPressed: _submitWeekendOuting,
            ),
            const SizedBox(height: 10),
            OutingHistoryButton(onPressed: _openHistory),
          ],
        ),
      ),
    );
  }
}

/// Only ever seen with the developer bypass on: the form is showing during a
/// window in which VTOP will refuse it.
class _BypassWarning extends StatelessWidget {
  const _BypassWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: cs.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$message VTOP will reject this submission.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
