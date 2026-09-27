import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/bottom_navigation_bar.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/core/utils/theme_switch_button.dart';
import 'package:vit_ap_student_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:vit_ap_student_app/features/auth/viewmodel/semester_viewmodel.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/types/semester.dart';

class SemesterSelectionPage extends ConsumerStatefulWidget {
  final String registrationNumber;
  final String password;

  const SemesterSelectionPage({
    super.key,
    required this.registrationNumber,
    required this.password,
  });

  @override
  ConsumerState<SemesterSelectionPage> createState() =>
      _SemesterSelectionPageState();
}

class _SemesterSelectionPageState extends ConsumerState<SemesterSelectionPage> {
  SemesterInfo? selectedSemester;
  String? inlineError;
  String? currentSemesterId;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    // Get current semester ID
    final currentSemester = await ref
        .read(semesterViewModelProvider.notifier)
        .getSelectedSemester();

    if (mounted) {
      setState(() {
        currentSemesterId = currentSemester?.id;
      });
    }

    // Only fetch if we don't already have semester data
    final currentState = ref.read(semesterViewModelProvider);
    if (currentState == null ||
        currentState.hasError ||
        !currentState.hasValue) {
      await ref
          .read(semesterViewModelProvider.notifier)
          .fetchSemesters(
            registrationNumber: widget.registrationNumber,
            password: widget.password,
            needsUpdate: true,
          );
    }
  }

  Future<void> _loginUser() async {
    setState(() => inlineError = null);

    if (selectedSemester == null) {
      setState(() {
        inlineError = 'Please select a semester to continue.';
      });
      return;
    }

    // Check if semester has changed
    final semesterChanged = currentSemesterId != selectedSemester!.id;

    // Save selected semester to cache
    await ref
        .read(semesterViewModelProvider.notifier)
        .setSelectedSemester(selectedSemester!.id);

    if (!semesterChanged) {
      // If semester hasn't changed, just navigate back or close the page
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    // Only call loginUser if semester has changed
    await ref
        .read(authViewModelProvider.notifier)
        .loginUser(
          semSubId: selectedSemester!.id,
          registrationNumber: widget.registrationNumber,
          password: widget.password,
        );
  }

  @override
  Widget build(BuildContext context) {
    final semesterState = ref.watch(semesterViewModelProvider);
    final isAuthLoading = ref.watch(
      authViewModelProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(semesterViewModelProvider, (_, next) {
      next?.when(
        data: (_) {},
        error: (error, _) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
        loading: () {},
      );
    });

    ref.listen(authViewModelProvider, (_, next) {
      next?.when(
        data: (_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (context) => const BottomNavBar()),
            (_) => false,
          );
        },
        error: (error, _) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(actions: const [ThemeSwitchButton()]),
      body: semesterState == null || semesterState.isLoading
          ? const Center(child: Loader())
          : semesterState.when(
              data: (semesters) {
                if (semesters.isEmpty) {
                  return const Center(
                    child: Text(
                      'No semesters available. Please try again later.',
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select your semester',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This helps us fetch your academic data correctly. You can also change this anytime in the settings.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: RadioGroup<SemesterInfo>(
                          groupValue: selectedSemester,
                          onChanged: (value) {
                            setState(() {
                              selectedSemester = value;
                              inlineError = null;
                            });
                          },
                          child: ListView.builder(
                            itemCount: semesters.length,
                            itemBuilder: (context, index) {
                              final semester = semesters[index];
                              final isSelected = selectedSemester == semester;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: ListTile(
                                  tileColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerLow,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      9,
                                    ),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(
                                              context,
                                            ).colorScheme.surfaceContainer,
                                    ),
                                  ),
                                  leading: Radio<SemesterInfo>(
                                    value: semester,
                                    activeColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  title: Text(
                                    semester.name,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedSemester = semester;
                                      inlineError = null;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (inlineError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          inlineError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 60),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isAuthLoading ? null : _loginUser,
                          child: isAuthLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Loader(),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load semesters',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initializePage,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              loading: () => const Center(child: Loader()),
            ),
    );
  }
}
