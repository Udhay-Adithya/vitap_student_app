import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/features/home/model/faculty.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/faculty_viewmodel.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop/types/faculty.dart';

/// Bottom sheet that shows basic info from [faculty] immediately and fetches
/// full details on demand.
class FacultyDetailsSheet extends ConsumerStatefulWidget {
  final FacultyListItem faculty;
  const FacultyDetailsSheet({super.key, required this.faculty});

  @override
  ConsumerState<FacultyDetailsSheet> createState() =>
      _FacultyDetailsSheetState();
}

class _FacultyDetailsSheetState extends ConsumerState<FacultyDetailsSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(facultyDetailsViewModelProvider.notifier)
          .fetchDetails(widget.faculty.empId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(facultyDetailsViewModelProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: MediaQuery.sizeOf(context).width),
            Text(
              widget.faculty.facultyName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            switch (state) {
              null || AsyncLoading() => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Loader()),
              ),
              AsyncError(:final error) => _ErrorDetails(
                error: error.toString(),
                onRetry: () => ref
                    .read(facultyDetailsViewModelProvider.notifier)
                    .fetchDetails(widget.faculty.empId),
              ),
              AsyncData(:final value) => FacultyDetailsBody(details: value),
            },
          ],
        ),
      ),
    );
  }
}

class _ErrorDetails extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorDetails({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Stateless body shown once full [FacultyDetails] are loaded.
class FacultyDetailsBody extends StatelessWidget {
  final FacultyDetails details;
  const FacultyDetailsBody({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Designation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        Text(
          details.designation,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Department',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        Text(
          details.department,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'School',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        Text(
          details.schoolCentre,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Email',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        GestureDetector(
          onTap: () async {
            if (!await launchUrl(Uri(scheme: 'mailto', path: details.email))) {
              throw Exception('Could not mail to ${details.email}');
            }
          },
          child: Text(
            details.email,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cabin Number',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        Text(
          details.cabinNumber.isEmpty ? 'N/A' : details.cabinNumber,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Open Hours:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        if (details.officeHours.isNotEmpty) ...[
          Table(
            border: TableBorder.all(color: colorScheme.onSurfaceVariant),
            children: [
              const TableRow(
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('Weekday')),
                  Padding(padding: EdgeInsets.all(8), child: Text('Hours')),
                ],
              ),
              ...details.officeHours.map(
                (h) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(h.day),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(h.timings),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else
          Text(
            'N/A',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }
}
