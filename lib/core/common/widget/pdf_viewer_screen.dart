import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';
import 'package:vit_ap_student_app/core/utils/file_saver.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final Uint8List pdfBytes;
  final String title;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.pdfBytes,
    required this.title,
    required this.fileName,
  });

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isDownloading = false;

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _downloadPdf() async {
    final notifications = ref.read(notificationServiceProvider);
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      // Use FileSaver to save PDF (opens file picker on Android)
      final savedPath = await FileSaver.savePdf(
        bytes: widget.pdfBytes,
        fileName: widget.fileName,
      );

      if (savedPath != null) {
        await notifications.showDownloadCompleteNotification(
          downloadType: DownloadType.pdf,
          fileName: widget.fileName,
        );

        if (mounted) {
          showSnackBar(context, 'PDF saved successfully', SnackBarType.success);
        }
      } else {
        // User cancelled the save dialog
        if (mounted) {
          showSnackBar(context, 'Save cancelled', SnackBarType.warning);
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          'Download failed: ${e.toString()}',
          SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _isDownloading ? null : _downloadPdf,
            icon: _isDownloading
                ? const Loader()
                : const Icon(Iconsax.document_download),
            tooltip: 'Download PDF',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SfPdfViewer.memory(
        widget.pdfBytes,
        controller: _pdfViewerController,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          showSnackBar(
            context,
            'Failed to load PDF: ${details.error}',
            SnackBarType.error,
          );
        },
      ),
    );
  }
}
