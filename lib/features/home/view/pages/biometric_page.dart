import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:vit_ap_student_app/core/common/widget/empty_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/error_content_view.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/home/model/biometric.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/biometric_viewmodel.dart';

class BiometricPage extends ConsumerStatefulWidget {
  const BiometricPage({super.key});

  @override
  ConsumerState<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends ConsumerState<BiometricPage> {
  TextEditingController dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'Please select a date',
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('BiometricPage');
    // Initialize the date controller with today's date
    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
    final biometric = ref.watch(biometricViewModelProvider);
    final biometricNotifier = ref.read(biometricViewModelProvider.notifier);
    ref.listen(biometricViewModelProvider, (_, next) {
      next?.when(
        data: (data) {},
        loading: () {},
        error: (error, st) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Biometric Log',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
            child: Text('Pick a date', style: TextStyle(fontSize: 18)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Container(
                width: MediaQuery.sizeOf(context).width / 2,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    controller: dateController,
                    readOnly: true, // Prevent user from manually typing
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.date_range_outlined,
                        size: 26,
                      ),
                      border: InputBorder.none,
                      hintText: 'Select date',
                      hintStyle: TextStyle(
                        height: 3,
                        letterSpacing: 2,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    style: TextStyle(
                      height: 3,
                      letterSpacing: 2,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                child: IconButton(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                child: TextButton(
                  onPressed: () {
                    if (dateController.text.isEmpty) {
                      showSnackBar(
                        context,
                        'Please select a date first',
                        SnackBarType.error,
                      );
                      return;
                    }
                    biometricNotifier.fetchBiometric(dateController.text);
                  },
                  child: Text(
                    'Go',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (biometric != null) ...[
            Expanded(
              child: biometric.when(
                loading: () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/loading_files.json',
                      frameRate: const FrameRate(60),
                      height: 100,
                    ),
                    Text(
                      'Fetching biometric log..',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                error: (error, stackTrace) =>
                    ErrorContentView(error: error.toString()),
                data: (data) {
                  final biometricLog = data;
                  if (data.isEmpty) {
                    return const EmptyContentView(
                      primaryText: 'No logs found',
                      secondaryText:
                          'No biometric logs were found for the\ngiven date',
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: biometricLog.length,
                    itemBuilder: (context, index) {
                      final Biometric logEntry = biometricLog[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          tileColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow,
                          onLongPress: () {},
                          leading: Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child:
                                logEntry.location.contains('MH') ||
                                    logEntry.location.contains('LH')
                                ? Icon(
                                    Iconsax.building_3,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiaryContainer,
                                  )
                                : Icon(
                                    Iconsax.book_1,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                          ),
                          title: Text(
                            logEntry.location,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            formattedDate,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Text(
                            DateFormat.jm().format(
                              DateFormat.Hm().parse(logEntry.time),
                            ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
