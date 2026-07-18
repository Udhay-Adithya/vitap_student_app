import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/constants/app_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';
import 'package:vit_ap_student_app/core/utils/file_saver.dart';
import 'package:vit_ap_student_app/core/utils/file_type_detector.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/features/digital_assignment/view/widgets/assignment_common_widgets.dart';
import 'package:vit_ap_student_app/features/digital_assignment/viewmodel/download_assignment_viewmodel.dart';
import 'package:vit_ap_student_app/features/digital_assignment/viewmodel/upload_assignment_viewmodel.dart';

class AssignmentTile extends ConsumerStatefulWidget {
  final AssignmentDetail detail;
  final String classId;
  final String courseCode;

  const AssignmentTile({
    super.key,
    required this.detail,
    required this.classId,
    required this.courseCode,
  });

  @override
  ConsumerState<AssignmentTile> createState() => _AssignmentTileState();
}

class _AssignmentTileState extends ConsumerState<AssignmentTile> {
  bool _isDownloading = false;

  SubmissionState get _status =>
      getSubmissionState(widget.detail.submissionStatus);

  Color _statusColor(BuildContext context) {
    return switch (_status) {
      SubmissionState.submitted => Colors.green,
      SubmissionState.pending => Colors.orange,
      SubmissionState.missed => Theme.of(context).colorScheme.error,
    };
  }

  IconData get _statusIcon {
    return switch (_status) {
      SubmissionState.submitted => Iconsax.tick_circle,
      SubmissionState.pending => Iconsax.clock,
      SubmissionState.missed => Iconsax.close_circle,
    };
  }

  String get _statusLabel {
    return switch (_status) {
      SubmissionState.submitted => widget.detail.submissionStatus,
      SubmissionState.pending => 'Pending',
      SubmissionState.missed => 'Missed Deadline',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = widget.detail;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _statusColor(context).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Status Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  detail.assignmentTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(_statusIcon, size: 22, color: _statusColor(context)),
            ],
          ),
          const SizedBox(height: 8),

          // Status Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                color: _statusColor(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Info Row: Due Date, Max Marks, Weightage
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              AssignmentInfoChip(
                icon: Iconsax.calendar_1,
                label: 'Due: ${detail.dueDate}',
              ),
              AssignmentInfoChip(
                icon: Iconsax.chart_square,
                label: 'Max: ${detail.maxAssignmentMark}',
              ),
              AssignmentInfoChip(
                icon: Iconsax.weight_1,
                label: 'Weightage: ${detail.assignmentWeightageMark}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Upload / Update button. Uploading is a write action to VTOP,
              // hidden for the demo account.
              if (_status == SubmissionState.pending &&
                  !DemoService.isDemoMode)
                AssignmentActionButton(
                  icon: Iconsax.document_upload,
                  label: 'Upload',
                  onPressed: () => _pickAndUpload(context, widget.detail.mcode),
                ),
              if (_status == SubmissionState.submitted &&
                  detail.canUpdate &&
                  !DemoService.isDemoMode)
                AssignmentActionButton(
                  icon: Iconsax.refresh_circle,
                  label: 'Update',
                  onPressed: () => _pickAndUpload(context, widget.detail.mcode),
                ),

              // QP Download
              if (detail.canQpDownload && detail.qpDownloadUrl.isNotEmpty)
                AssignmentActionButton(
                  icon: Iconsax.document_download,
                  label: 'Question Paper',
                  onPressed: () => _downloadFile(
                    context,
                    detail.qpDownloadUrl,
                    '${widget.courseCode}_QP_${detail.serialNumber}',
                  ),
                ),

              // DA Download (submitted document)
              if (detail.canDaDownload && detail.daDownloadUrl.isNotEmpty)
                AssignmentActionButton(
                  icon: Iconsax.document_download,
                  label: 'My Submission',
                  onPressed: () => _downloadFile(
                    context,
                    detail.daDownloadUrl,
                    '${widget.courseCode}_DA_${detail.serialNumber}',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context, String mode) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.kAllowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null || file.name.isEmpty) {
      if (context.mounted) {
        showSnackBar(context, 'Failed to read file', SnackBarType.error);
      }
      return;
    }

    // Validate file size (4 MB)
    if (file.size > AppConstants.kMaxFileSizeBytes) {
      if (context.mounted) {
        showSnackBar(
          context,
          'File too large (${(file.size / (1024 * 1024)).toStringAsFixed(1)} MB). '
          'Maximum allowed size is 4 MB.',
          SnackBarType.error,
        );
      }
      return;
    }

    // Validate file extension
    final ext = file.name.split('.').last.toLowerCase();
    if (!AppConstants.kAllowedExtensions.contains(ext)) {
      if (context.mounted) {
        showSnackBar(
          context,
          'Unsupported file type (.$ext). '
          'Allowed: ${AppConstants.kAllowedExtensions.map((e) => '.$e').join(', ')}',
          SnackBarType.error,
        );
      }
      return;
    }

    await AnalyticsService.logEvent('digital_assignment_upload', {
      'course_code': widget.courseCode,
      'mode': mode,
      'file_name': file.name,
      'file_size': file.size,
    });

    await ref
        .read(uploadAssignmentViewModelProvider.notifier)
        .uploadAssignment(
          classId: widget.classId,
          mode: mode,
          fileName: file.name,
          fileBytes: file.bytes!.toList(),
        );
  }

  Future<void> _downloadFile(
    BuildContext context,
    String downloadUrl,
    String fileLabel,
  ) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    int? progressId;
    try {
      await AnalyticsService.logEvent('digital_assignment_download', {
        'course_code': widget.courseCode,
        'file_label': fileLabel,
      });

      // Show indeterminate progress notification while downloading
      progressId = await NotificationService.showDownloadProgressIndeterminate(
        downloadType: DownloadType.digitalAssignment,
        fileName: '${widget.courseCode} - $fileLabel',
      );

      final bytes = await ref
          .read(downloadAssignmentViewModelProvider.notifier)
          .downloadFile(downloadPath: downloadUrl);

      if (bytes != null && context.mounted) {
        // Detect actual file type from magic bytes (VTOP may return
        // different formats regardless of the URL path).
        final extension = FileTypeDetector.detectExtension(bytes);
        final mimeType = FileTypeDetector.getMimeType(extension);
        final sanitizedLabel = fileLabel.replaceAll(
          RegExp(r'[<>:"/\\|?*]'),
          '_',
        );
        final fileName = '$sanitizedLabel.$extension';

        final savedPath = await FileSaver.saveFile(
          bytes: bytes,
          fileName: fileName,
          mimeType: mimeType,
        );

        // Cancel progress before showing complete
        await NotificationService.cancelDownloadProgress(progressId);
        progressId = null;

        if (savedPath != null && context.mounted) {
          await NotificationService.showDownloadCompleteNotification(
            downloadType: DownloadType.digitalAssignment,
            fileName: '${widget.courseCode} - $fileLabel',
            filePath: savedPath,
          );
          showSnackBar(
            context,
            'File saved successfully',
            SnackBarType.success,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Failed to save file: $e', SnackBarType.error);
      }
    } finally {
      if (progressId != null) {
        await NotificationService.cancelDownloadProgress(progressId);
      }
      if (mounted) setState(() => _isDownloading = false);
    }
  }
}
