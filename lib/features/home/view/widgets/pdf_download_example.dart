// Example of how to use the PDF download view models

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/pdf_download_viewmodel.dart';

class PdfDownloadExample extends ConsumerWidget {
  const PdfDownloadExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the view model states
    final generalPdfState = ref.watch(
      generalOutingPdfDownloadViewModelProvider,
    );
    final weekendPdfState = ref.watch(
      weekendOutingPdfDownloadViewModelProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('PDF Download Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // General Outing PDF Download
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'General Outing Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(
                              generalOutingPdfDownloadViewModelProvider
                                  .notifier,
                            )
                            .downloadGeneralOutingPdf(
                              leaveId:
                                  'LEAVE001', // Replace with actual leave ID
                              customFileName: 'my_general_outing_report',
                            );
                      },
                      child: const Text('Download General Outing PDF'),
                    ),
                    const SizedBox(height: 8),
                    // Show download state
                    generalPdfState?.when(
                          data: (filePath) => Column(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Downloaded to: $filePath',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          loading: () => const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Loader(),
                              SizedBox(width: 8),
                              Text('Downloading...'),
                            ],
                          ),
                          error: (error, stackTrace) => Column(
                            children: [
                              const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Error: $error',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ) ??
                        const SizedBox.shrink(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Weekend Outing PDF Download
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Weekend Outing Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(
                              weekendOutingPdfDownloadViewModelProvider
                                  .notifier,
                            )
                            .downloadWeekendOutingPdf(
                              leaveId:
                                  'WEEKEND001', // Replace with actual booking ID
                              customFileName: 'my_weekend_outing_report',
                            );
                      },
                      child: const Text('Download Weekend Outing PDF'),
                    ),
                    const SizedBox(height: 8),
                    // Show download state
                    weekendPdfState?.when(
                          data: (filePath) => Column(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Downloaded to: $filePath',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          loading: () => const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Loader(),
                              SizedBox(width: 8),
                              Text('Downloading...'),
                            ],
                          ),
                          error: (error, stackTrace) => Column(
                            children: [
                              const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Error: $error',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ) ??
                        const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
