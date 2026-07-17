import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/common/widgets/common_date_picker.dart';
import 'package:vit_ap_student_app/core/constants/app_constants.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/home/view/pages/outing/weekend_outing_history_page.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/outing_submission_viewmodel.dart';

class WeekendOutingTab extends ConsumerStatefulWidget {
  const WeekendOutingTab({super.key});

  @override
  ConsumerState<WeekendOutingTab> createState() => _WeekendOutingTabState();
}

class _WeekendOutingTabState extends ConsumerState<WeekendOutingTab> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPlace = AppConstants.outingPlaces.first;
  String? _selectedTimeSlot = AppConstants.outingTimeSlots.first;
  String? _purpose;
  String? _contactNumber;
  DateTime? _outingDate;

  /// Check if the deadline has passed for applying weekend outing
  /// Sunday outing: Can apply till Friday 11:59 PM
  /// Monday outing: Can apply till Saturday 11:59 PM
  bool _isDeadlinePassed(DateTime outingDate, bool bypassRestriction) {
    if (bypassRestriction) return false;

    final now = DateTime.now();
    final outingDay = outingDate.weekday;

    if (outingDay == DateTime.sunday) {
      // Sunday outing - deadline is Friday 11:59 PM
      // Find the Friday before the selected Sunday
      final daysUntilSunday = (DateTime.sunday - now.weekday) % 7;
      final targetSunday = now.add(Duration(days: daysUntilSunday));

      // Check if selected Sunday matches the upcoming Sunday
      if (outingDate.year == targetSunday.year &&
          outingDate.month == targetSunday.month &&
          outingDate.day == targetSunday.day) {
        // Deadline is Friday 11:59 PM (2 days before Sunday)
        final deadline = DateTime(
          targetSunday.year,
          targetSunday.month,
          targetSunday.day - 2,
          23,
          59,
          59,
        );
        return now.isAfter(deadline);
      }
    } else if (outingDay == DateTime.monday) {
      // Monday outing - deadline is Saturday 11:59 PM
      // Find the Monday
      final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
      final targetMonday =
          now.add(Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday));

      // Check if selected Monday matches the target Monday
      if (outingDate.year == targetMonday.year &&
          outingDate.month == targetMonday.month &&
          outingDate.day == targetMonday.day) {
        // Deadline is Saturday 11:59 PM (2 days before Monday)
        final deadline = DateTime(
          targetMonday.year,
          targetMonday.month,
          targetMonday.day - 2,
          23,
          59,
          59,
        );
        return now.isAfter(deadline);
      }
    }

    return false;
  }

  Future<void> _submitWeekendOuting() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check deadline restriction
    final prefs = ref.read(userPreferencesProvider);
    final bypassRestriction = prefs.bypassWeekendOutingRestriction;

    if (_isDeadlinePassed(_outingDate!, bypassRestriction)) {
      showSnackBar(
        context,
        'Application deadline has passed for this date',
        SnackBarType.error,
      );
      return;
    }

    await ref
        .read(weekendOutingSubmissionProvider.notifier)
        .submitWeekendOuting(
          outPlace: _selectedPlace!,
          purposeOfVisit: _purpose!,
          outingDate: DateFormat('dd-MMM-yyyy').format(_outingDate!),
          outTime: _selectedTimeSlot!,
          contactNumber: _contactNumber!,
        );
  }

  void _clearForm() {
    setState(() {
      _selectedPlace = AppConstants.outingPlaces.first;
      _selectedTimeSlot = AppConstants.outingTimeSlots.first;
      _outingDate = null;
      _purpose = null;
      _contactNumber = null;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      weekendOutingSubmissionProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(
      weekendOutingSubmissionProvider,
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
            // Place Chips
            Text(
              'Place of Visit',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FormField<String>(
              initialValue: _selectedPlace,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a place';
                }
                return null;
              },
              builder: (FormFieldState<String> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: AppConstants.outingPlaces.map((String place) {
                        final isSelected = _selectedPlace == place;
                        return ChoiceChip(
                          label: Text(place),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedPlace = selected ? place : null;
                            });
                            state.didChange(selected ? place : null);
                          },
                        );
                      }).toList(),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          state.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
      
            // Time Slot Chips
            Text(
              'Time Slot',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FormField<String>(
              initialValue: _selectedTimeSlot,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a time slot';
                }
                return null;
              },
              builder: (FormFieldState<String> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: AppConstants.outingTimeSlots.map((String slot) {
                        final isSelected = _selectedTimeSlot == slot;
                        return ChoiceChip(
                          label: Text(slot),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedTimeSlot = selected ? slot : null;
                            });
                            state.didChange(selected ? slot : null);
                          },
                        );
                      }).toList(),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          state.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
      
            // Date Picker
            CommonDatePicker(
              label: 'Outing Date',
              selectedDate: _outingDate,
              onDateSelected: (date) {
                setState(() => _outingDate = date);
              },
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 7)),
              selectableDayPredicate: (DateTime date) {
                // Only allow Sunday (7) or Monday (1)
                if (date.weekday != DateTime.sunday &&
                    date.weekday != DateTime.monday) {
                  return false;
                }
      
                // Check if deadline has passed (unless bypassed)
                final prefs = ref.read(userPreferencesProvider);
                final bypassRestriction = prefs.bypassWeekendOutingRestriction;
      
                if (!bypassRestriction && _isDeadlinePassed(date, false)) {
                  return false;
                }
      
                return true;
              },
              validator: (value) =>
                  _outingDate == null ? 'Please select a date' : null,
            ),
      
            const SizedBox(height: 16),
      
            // Purpose
            Text(
              'Purpose of Visit',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter purpose',
                hintStyle: TextStyle(fontSize: 14),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 0.0,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) => setState(() => _purpose = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter purpose';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
      
            // Contact Number
            Text(
              'Contact Number',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter contact number',
                hintStyle: TextStyle(fontSize: 14),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 0.0,
                ),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => setState(() => _contactNumber = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contact number';
                }
                if (value.length != 10) {
                  return 'Contact number must be 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
      
            // Bottom Row: View History + Apply
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
                          builder: (context) => const WeekendOutingHistoryPage(),
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
                            onPressed: _submitWeekendOuting,
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
