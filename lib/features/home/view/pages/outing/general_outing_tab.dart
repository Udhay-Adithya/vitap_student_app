import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/common/widgets/common_date_picker.dart';
import 'package:vit_ap_student_app/core/common/widgets/common_time_picker.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/home/view/pages/outing/general_outing_history_page.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/outing_submission_viewmodel.dart';

class GeneralOutingTab extends ConsumerStatefulWidget {
  const GeneralOutingTab({super.key});

  @override
  ConsumerState<GeneralOutingTab> createState() => _GeneralOutingTabState();
}

class _GeneralOutingTabState extends ConsumerState<GeneralOutingTab> {
  String? _fromTime;
  String? _toTime;
  String? _placeOfVisit;
  String? _purposeOfVisit;
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  final _formKey = GlobalKey<FormState>();

  bool _validateTime(TimeOfDay time) {
    final int hour = time.hour;
    final int minute = time.minute;

    if ((hour > 6 || (hour == 6 && minute >= 0)) &&
        (hour < 22 || (hour == 22 && minute == 0))) {
      return true;
    } else {
      showSnackBar(
        context,
        'Please select a time between 06:00 AM and 10:00 PM',
        SnackBarType.warning,
      );
      return false;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(generalOutingSubmissionProvider.notifier)
        .submitGeneralOuting(
          outPlace: _placeOfVisit!,
          purposeOfVisit: _purposeOfVisit!,
          outingDate: DateFormat('dd-MMM-yyyy').format(_selectedFromDate!),
          outTime: _fromTime!,
          inDate: DateFormat('dd-MMM-yyyy').format(_selectedToDate!),
          inTime: _toTime!,
        );
  }

  void _clearForm() {
    setState(() {
      _fromTime = null;
      _toTime = null;
      _placeOfVisit = null;
      _purposeOfVisit = null;
      _selectedFromDate = null;
      _selectedToDate = null;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      generalOutingSubmissionProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(
      generalOutingSubmissionProvider,
      (_, next) {
        next?.when(
          data: (message) {
            showSnackBar(
              context,
              message,
              SnackBarType.success,
            );
            _clearForm();
          },
          loading: () {},
          error: (error, st) {
            showSnackBar(
              context,
              error.toString(),
              SnackBarType.error,
            );
          },
        );
      },
    );

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Place of visit',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
                hintText: 'Place Of Visit',
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) => setState(() => _placeOfVisit = value),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter the place of visit'
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              'Purpose of visit',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
                hintText: 'Purpose Of Visit',
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) => setState(() => _purposeOfVisit = value),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter the purpose of visit'
                  : null,
            ),
            const SizedBox(height: 12),
            CommonDatePicker(
              label: 'From date',
              selectedDate: _selectedFromDate,
              onDateSelected: (date) {
                setState(() => _selectedFromDate = date);
              },
              validator: (value) =>
                  _selectedFromDate == null ? 'Please select a date' : null,
            ),
            const SizedBox(height: 12),
            CommonTimePicker(
              label: 'From time',
              selectedTime: _fromTime,
              onTimeSelected: (time) {
                setState(() => _fromTime = time);
              },
              timeValidator: _validateTime,
              validator: (value) =>
                  _fromTime == null ? 'Please select a from time' : null,
            ),
            const SizedBox(height: 12),
            CommonDatePicker(
              label: 'To date',
              selectedDate: _selectedToDate,
              onDateSelected: (date) {
                setState(() => _selectedToDate = date);
              },
              validator: (value) =>
                  _selectedToDate == null ? 'Please select a date' : null,
            ),
            const SizedBox(height: 12),
            CommonTimePicker(
              label: 'To time',
              selectedTime: _toTime,
              onTimeSelected: (time) {
                setState(() => _toTime = time);
              },
              timeValidator: _validateTime,
              validator: (value) =>
                  _toTime == null ? 'Please select a to time' : null,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              const GeneralOutingHistoryPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'View outing history',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                // Submitting an outing is a write action to VTOP, disabled for
                // the demo account. History remains viewable via the button on
                // the left.
                if (!DemoService.isDemoMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: isLoading
                        ? const Loader()
                        : TextButton.icon(
                            icon: const Icon(
                              Icons.arrow_forward_sharp,
                              color: Colors.blue,
                            ),
                            iconAlignment: IconAlignment.end,
                            onPressed: _submitForm,
                            label: const Text(
                              'Apply',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
