import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/constants/app_constants.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/services/demo_service.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';
import 'package:vit_ap_student_app/core/utils/file_saver.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/digital_assignment/model/digital_assignment_model.dart';
import 'package:vit_ap_student_app/features/digital_assignment/view/widgets/assignment_status_style.dart';
import 'package:vit_ap_student_app/features/digital_assignment/viewmodel/download_assignment_viewmodel.dart';
import 'package:vit_ap_student_app/features/digital_assignment/viewmodel/upload_assignment_viewmodel.dart';

/// One assignment.
///
/// Built around the deadline: the due line is the first coloured thing you see,
/// because "when is this due" is the question. The tile used to carry a status
/// icon, a status pill, three info chips and up to four equally-weighted
/// buttons — nine elements of the same visual weight — inside a border tinted by
/// status, which turned a list into a row of competing boxes.
class AssignmentTile extends ConsumerStatefulWidget {
  const AssignmentTile({
    super.key,
    required this.detail,
    required this.classId,
    required this.courseCode,
  });

  final AssignmentDetail detail;
  final String classId;
  final String courseCode;

  @override
  ConsumerState<AssignmentTile> createState() => _AssignmentTileState();
}

class _AssignmentTileState extends ConsumerState<AssignmentTile> {
  bool _isUploading = false;

  /// Which download is in flight, so the busy button can say so and the other
  /// can explain why it is unavailable rather than silently ignoring taps.
  String? _downloadingLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final AssignmentDetail detail = widget.detail;
    final AssignmentStatusStyle status = assignmentStatusStyle(context, detail);
    final SubmissionState state = getSubmissionState(detail.submissionStatus);

    final bool canUpload =
        !DemoService.isDemoMode &&
        (state == SubmissionState.pending ||
            (state == SubmissionState.submitted && detail.canUpdate));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            detail.assignmentTitle,
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Icon(status.icon, size: 16, color: status.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status.label,
                  style: tt.labelLarge?.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Max ${detail.maxAssignmentMark}  ·  '
            'Weightage ${detail.assignmentWeightageMark}',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          if (canUpload || _hasDownloads) ...<Widget>[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                if (canUpload)
                  _PrimaryAction(
                    icon: state == SubmissionState.submitted
                        ? Iconsax.refresh_circle
                        : Iconsax.document_upload,
                    label: state == SubmissionState.submitted
                        ? 'Update'
                        : 'Upload',
                    busy: _isUploading,
                    onPressed: () => _pickAndUpload(detail.mcode),
                  ),
                if (detail.canQpDownload && detail.qpDownloadUrl.isNotEmpty)
                  _DownloadAction(
                    label: 'Question paper',
                    busy: _downloadingLabel == 'QP',
                    blocked:
                        _downloadingLabel != null && _downloadingLabel != 'QP',
                    onPressed: () => _downloadFile(
                      'QP',
                      detail.qpDownloadUrl,
                      '${widget.courseCode}_QP_${detail.serialNumber}',
                    ),
                  ),
                if (detail.canDaDownload && detail.daDownloadUrl.isNotEmpty)
                  _DownloadAction(
                    label: 'My submission',
                    busy: _downloadingLabel == 'DA',
                    blocked:
                        _downloadingLabel != null && _downloadingLabel != 'DA',
                    onPressed: () => _downloadFile(
                      'DA',
                      detail.daDownloadUrl,
                      '${widget.courseCode}_DA_${detail.serialNumber}',
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasDownloads =>
      (widget.detail.canQpDownload && widget.detail.qpDownloadUrl.isNotEmpty) ||
      (widget.detail.canDaDownload && widget.detail.daDownloadUrl.isNotEmpty);

  Future<void> _pickAndUpload(String mode) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: AppConstants.kAllowedExtensions,
    );

    if (file == null) return;

    if (file.name.isEmpty) {
      if (mounted) {
        showSnackBar(context, 'Failed to read file', SnackBarType.error);
      }
      return;
    }

    if (file.size > AppConstants.kMaxFileSizeBytes) {
      if (mounted) {
        showSnackBar(
          context,
          'File too large (${(file.size / (1024 * 1024)).toStringAsFixed(1)} MB). '
          'Maximum allowed size is 4 MB.',
          SnackBarType.error,
        );
      }
      return;
    }

    final ext = file.name.split('.').last.toLowerCase();
    if (!AppConstants.kAllowedExtensions.contains(ext)) {
      if (mounted) {
        showSnackBar(
          context,
          'Unsupported file type (.$ext). '
          'Allowed: ${AppConstants.kAllowedExtensions.map((e) => '.$e').join(', ')}',
          SnackBarType.error,
        );
      }
      return;
    }

    // file_picker no longer loads the bytes during picking, so read them here
    // once the file has passed the size and extension checks.
    final Uint8List fileBytes;
    try {
      fileBytes = await file.readAsBytes();
    } catch (e) {
      debugPrint('Failed to read picked file: $e');
      if (mounted) {
        showSnackBar(context, 'Failed to read file', SnackBarType.error);
      }
      return;
    }

    ref
        .read(analyticsServiceProvider)
        .logEvent(AnalyticsEvents.digitalAssignmentUpload, {
          AnalyticsParams.courseCode: widget.courseCode,
          AnalyticsParams.mode: mode,
          AnalyticsParams.fileExtension: file.extension ?? 'unknown',
          AnalyticsParams.sizeBytes: file.size,
        });

    // A 4 MB upload on campus wifi is many seconds long, and the button used to
    // look untouched throughout — on the one action here that cannot simply be
    // retried without consequence.
    setState(() => _isUploading = true);
    try {
      await ref
          .read(uploadAssignmentViewModelProvider.notifier)
          .uploadAssignment(
            classId: widget.classId,
            mode: mode,
            fileName: file.name,
            fileBytes: fileBytes.toList(),
          );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _downloadFile(
    String key,
    String downloadUrl,
    String fileLabel,
  ) async {
    final notifications = ref.read(notificationServiceProvider);
    if (_downloadingLabel != null) return;
    setState(() => _downloadingLabel = key);

    int? progressId;
    try {
      ref.read(analyticsServiceProvider).logEvent(
        AnalyticsEvents.digitalAssignmentDownload,
        {AnalyticsParams.courseCode: widget.courseCode},
      );

      progressId = await notifications.showDownloadProgressIndeterminate(
        downloadType: DownloadType.digitalAssignment,
        fileName: '${widget.courseCode} - $fileLabel',
      );

      final bytes = await ref
          .read(downloadAssignmentViewModelProvider.notifier)
          .downloadFile(downloadPath: downloadUrl);

      if (bytes != null && mounted) {
        // Detect actual file type from magic bytes (VTOP may return
        // different formats regardless of the URL path).
        final savedPath = await FileSaver.save(
          FileSaver.prepare(bytes: bytes, baseName: fileLabel),
        );

        await notifications.cancelDownloadProgress(progressId);
        progressId = null;

        if (savedPath != null && mounted) {
          await notifications.showDownloadCompleteNotification(
            downloadType: DownloadType.digitalAssignment,
            fileName: '${widget.courseCode} - $fileLabel',
          );
          if (mounted) {
            showSnackBar(
              context,
              'File saved successfully',
              SnackBarType.success,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Failed to save file: $e', SnackBarType.error);
      }
    } finally {
      if (progressId != null) {
        await notifications.cancelDownloadProgress(progressId);
      }
      if (mounted) setState(() => _downloadingLabel = null);
    }
  }
}

/// Upload or Update — the only filled control on the tile.
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: busy ? null : onPressed,
      icon: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 18),
      label: Text(busy ? 'Uploading…' : label),
      style: FilledButton.styleFrom(shape: const StadiumBorder()),
    );
  }
}

/// A file to fetch. Secondary to upload, and honest about being blocked while
/// another download on the same tile is running.
class _DownloadAction extends StatelessWidget {
  const _DownloadAction({
    required this.label,
    required this.busy,
    required this.blocked,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final bool blocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: busy || blocked ? null : onPressed,
      icon: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Iconsax.document_download, size: 18),
      label: Text(busy ? 'Downloading…' : label),
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }
}
