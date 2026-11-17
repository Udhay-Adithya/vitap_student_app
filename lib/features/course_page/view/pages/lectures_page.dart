import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/empty_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/error_content_view.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/common/widget/pdf_viewer_screen.dart';
import 'package:vit_ap_student_app/core/services/notification_service.dart';
import 'package:vit_ap_student_app/core/utils/file_saver.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';
import 'package:vit_ap_student_app/features/course_page/model/course_page_detail.dart';
import 'package:vit_ap_student_app/features/course_page/view/widgets/download_actions_row.dart';
import 'package:vit_ap_student_app/features/course_page/view/widgets/lecture_card.dart';
import 'package:vit_ap_student_app/features/course_page/viewmodel/course_detail_viewmodel.dart';
import 'package:vit_ap_student_app/features/course_page/viewmodel/material_download_viewmodel.dart';

/// Busy-state keys for the course-level actions, which have no reference
/// material of their own. The NUL prefix keeps them from colliding with a
/// real material download path.
///
/// View and download get separate keys because they are separate buttons —
/// one key shared between them would spin both.
const _syllabusViewKey = '\u0000syllabus-view';
const _syllabusDownloadKey = '\u0000syllabus-download';
const _allMaterialsKey = '\u0000all-materials';

class LecturesPage extends ConsumerStatefulWidget {
  final String courseCode;
  final String courseTitle;
  final String faculty;
  final String erpId;
  final String classId;

  const LecturesPage({
    super.key,
    required this.courseCode,
    required this.courseTitle,
    required this.faculty,
    required this.erpId,
    required this.classId,
  });

  @override
  ConsumerState<LecturesPage> createState() => _LecturesPageState();
}

class _LecturesPageState extends ConsumerState<LecturesPage> {
  /// Identifies the single action in flight, so exactly one control spins and
  /// the rest stay disabled until it finishes.
  ///
  /// Materials are keyed by download path, not label: VTOP reuses labels like
  /// "Module 1" across lectures, and keying on those spun every row that shared
  /// a name. Course-level actions use the sentinel keys above.
  String? _busyKey;

  /// The fetch has to start here rather than on the page that pushes this one.
  /// `courseDetailViewmodelProvider` is auto-disposed, and this is the only
  /// page that watches it: a fetch kicked off by the caller ran on an instance
  /// nothing was listening to, so Riverpod disposed it mid-request and the
  /// response landed on a dead Ref ("Cannot use the Ref of
  /// courseDetailViewmodelProvider after it has been disposed") while this page
  /// waited on a fresh instance that was never going to be filled.
  ///
  /// This is still a fetch on an explicit tap, not on a passive page open —
  /// opening this page *is* the tap that asks for this course's lectures.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCourseDetail();
    });
  }

  void _fetchCourseDetail() {
    ref
        .read(courseDetailViewmodelProvider.notifier)
        .fetchCourseDetail(erpId: widget.erpId, classId: widget.classId);
  }

  /// The syllabus uses the same download mechanism as any other material.
  /// We call downloadMaterial with the parsed syllabusDownloadPath because the
  /// Rust download_course_syllabus reconstructs the path from courseType, which
  /// may be the full name (e.g. "Embedded Theory") instead of the abbreviation
  /// ("ETH"), causing a 0KB download.
  Future<Uint8List?> _fetchMaterial(String downloadPath) => ref
      .read(materialDownloadViewmodelProvider.notifier)
      .downloadMaterial(downloadPath: downloadPath);

  Future<Uint8List?> _fetchAllMaterials(String downloadPath) => ref
      .read(materialDownloadViewmodelProvider.notifier)
      .downloadAllMaterials(downloadPath: downloadPath);

  // ---------------------------------------------------------------------------
  // View — fetch and open, saving nothing
  // ---------------------------------------------------------------------------

  Future<void> _viewMaterial(String downloadPath, String label) {
    return _view(
      busyKey: downloadPath,
      viewerTitle: label,
      fetch: () => _fetchMaterial(downloadPath),
      prepare: (bytes) => FileSaver.prepare(
        bytes: bytes,
        baseName: '${widget.courseCode}_$label',
      ),
    );
  }

  Future<void> _viewSyllabus(String downloadPath) {
    return _view(
      busyKey: _syllabusViewKey,
      viewerTitle: 'Syllabus',
      fetch: () => _fetchMaterial(downloadPath),
      // The syllabus download always returns a .docx.
      prepare: (bytes) => FileSaver.prepareAs(
        bytes: bytes,
        baseName: '${widget.courseCode}_syllabus',
        extension: 'docx',
      ),
    );
  }

  /// Fetches a file and shows it without persisting anything.
  ///
  /// PDFs open in the in-app viewer, which carries its own download button.
  /// Anything else is handed to the system's default app for that format.
  Future<void> _view({
    required String busyKey,
    required String viewerTitle,
    required Future<Uint8List?> Function() fetch,
    required PreparedFile Function(Uint8List bytes) prepare,
  }) async {
    if (_busyKey != null) return;
    setState(() => _busyKey = busyKey);

    try {
      final bytes = await fetch();
      if (bytes == null || !mounted) return;

      final file = prepare(bytes);

      if (file.mimeType == 'application/pdf') {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => PdfViewerScreen(
              pdfBytes: bytes,
              title: viewerTitle,
              fileName: file.fileName,
            ),
          ),
        );
        return;
      }

      final opened = await FileSaver.openTemporarily(file);
      if (!opened && mounted) {
        showSnackBar(
          context,
          'No app on your device can open this file. Try Download instead.',
          SnackBarType.warning,
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          'Error opening file: ${e.toString()}',
          SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  // ---------------------------------------------------------------------------
  // Download — fetch and save through the system save dialog
  // ---------------------------------------------------------------------------

  Future<void> _downloadMaterial(String downloadPath, String label) {
    return _download(
      busyKey: downloadPath,
      downloadType: DownloadType.courseMaterial,
      notificationName: '${widget.courseCode} - $label',
      fetch: () => _fetchMaterial(downloadPath),
      prepare: (bytes) => FileSaver.prepare(
        bytes: bytes,
        baseName: '${widget.courseCode}_$label',
      ),
    );
  }

  Future<void> _downloadSyllabus(String downloadPath) {
    return _download(
      busyKey: _syllabusDownloadKey,
      downloadType: DownloadType.courseSyllabus,
      notificationName: '${widget.courseCode} - Syllabus',
      fetch: () => _fetchMaterial(downloadPath),
      prepare: (bytes) => FileSaver.prepareAs(
        bytes: bytes,
        baseName: '${widget.courseCode}_syllabus',
        extension: 'docx',
      ),
    );
  }

  Future<void> _downloadAllMaterials(String downloadPath) {
    return _download(
      busyKey: _allMaterialsKey,
      downloadType: DownloadType.allCourseMaterials,
      notificationName: '${widget.courseCode} - All Materials',
      fetch: () => _fetchAllMaterials(downloadPath),
      // "Download All" always returns a ZIP archive.
      prepare: (bytes) => FileSaver.prepareAs(
        bytes: bytes,
        baseName: '${widget.courseCode}_all_materials',
        extension: 'zip',
      ),
    );
  }

  /// Fetches a file behind a progress notification, then puts it through the
  /// system save dialog so the user picks where it lands.
  Future<void> _download({
    required String busyKey,
    required DownloadType downloadType,
    required String notificationName,
    required Future<Uint8List?> Function() fetch,
    required PreparedFile Function(Uint8List bytes) prepare,
  }) async {
    final notifications = ref.read(notificationServiceProvider);
    if (_busyKey != null) return;
    setState(() => _busyKey = busyKey);

    int? progressId;
    try {
      progressId = await notifications.showDownloadProgressIndeterminate(
        downloadType: downloadType,
        fileName: notificationName,
      );

      final bytes = await fetch();

      await notifications.cancelDownloadProgress(progressId);
      progressId = null;

      if (bytes == null || !mounted) return;

      final savedPath = await FileSaver.save(prepare(bytes));
      if (!mounted) return;

      if (savedPath == null) {
        showSnackBar(context, 'Save cancelled', SnackBarType.warning);
      } else {
        await notifications.showDownloadCompleteNotification(
          downloadType: downloadType,
          fileName: notificationName,
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          'Error downloading file: ${e.toString()}',
          SnackBarType.error,
        );
      }
    } finally {
      if (progressId != null) {
        await notifications.cancelDownloadProgress(progressId);
      }
      if (mounted) setState(() => _busyKey = null);
    }
  }

  String _extractFacultyName(String faculty) {
    // Faculty format: "70735 - Shaik Subhani - SCOPE"
    final parts = faculty.split(' - ');
    if (parts.length >= 2) {
      return parts[1];
    }
    return faculty;
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(courseDetailViewmodelProvider);

    ref.listen(courseDetailViewmodelProvider, (_, next) {
      next?.whenOrNull(
        error: (error, st) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });

    ref.listen(materialDownloadViewmodelProvider, (_, next) {
      next?.whenOrNull(
        error: (error, st) {
          showSnackBar(context, error.toString(), SnackBarType.error);
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.courseTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(detailState),
    );
  }

  Widget _buildBody(AsyncValue<CoursePageDetailModel>? detailState) {
    if (detailState == null) {
      return const Loader();
    }

    return detailState.when(
      data: (courseDetail) => _buildContent(courseDetail),
      loading: () => const Loader(),
      error: (error, st) => ErrorContentView(error: error.toString()),
    );
  }

  Widget _buildContent(CoursePageDetailModel courseDetail) {
    final lectures = courseDetail.lectures;
    final facultyName = _extractFacultyName(courseDetail.courseInfo.faculty);

    return RefreshIndicator(
      onRefresh: () async => _fetchCourseDetail(),
      child: CustomScrollView(
        slivers: [
          // Course Info Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facultyName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {},
                        child: Text(
                          courseDetail.courseInfo.courseCode,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {},
                        child: Text(
                          courseDetail.courseInfo.courseType,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {},
                        child: Text(
                          courseDetail.courseInfo.slot,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DownloadActionsRow(
                    onViewSyllabus: courseDetail.syllabusDownloadPath != null
                        ? () =>
                              _viewSyllabus(courseDetail.syllabusDownloadPath!)
                        : null,
                    onDownloadSyllabus:
                        courseDetail.syllabusDownloadPath != null
                        ? () => _downloadSyllabus(
                            courseDetail.syllabusDownloadPath!,
                          )
                        : null,
                    onDownloadAll: courseDetail.downloadAllPath != null
                        ? () => _downloadAllMaterials(
                            courseDetail.downloadAllPath!,
                          )
                        : null,
                    viewSyllabusBusy: _busyKey == _syllabusViewKey,
                    downloadSyllabusBusy: _busyKey == _syllabusDownloadKey,
                    downloadAllBusy: _busyKey == _allMaterialsKey,
                    enabled: _busyKey == null,
                  ),
                ],
              ),
            ),
          ),
          if (lectures.isEmpty)
            const SliverFillRemaining(
              child: EmptyContentView(
                primaryText: 'No lectures found',
                secondaryText: 'No lecture schedule available yet',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final lecture = lectures[index];
                  return LectureCard(
                    lecture: lecture,
                    busyMaterialPath: _busyKey,
                    onMaterialView: (material) =>
                        _viewMaterial(material.downloadPath, material.label),
                    onMaterialDownload: (material) => _downloadMaterial(
                      material.downloadPath,
                      material.label,
                    ),
                  );
                }, childCount: lectures.length),
              ),
            ),
        ],
      ),
    );
  }
}
