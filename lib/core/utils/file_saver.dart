import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vit_ap_student_app/core/utils/file_type_detector.dart';

/// Downloaded bytes together with the name and MIME type they should be
/// written out as.
///
/// Build one with [FileSaver.prepare] (format detected from the content) or
/// [FileSaver.prepareAs] (format known up front), then hand it to
/// [FileSaver.openTemporarily] to view or [FileSaver.save] to download.
class PreparedFile {
  const PreparedFile({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
}

/// Saves downloaded files through the system save dialog, and opens them for
/// viewing without persisting anything.
///
/// Both platforms use the same dialog: SAF `ACTION_CREATE_DOCUMENT` on Android
/// and `UIDocumentPickerViewController` in export mode on iOS. In both cases
/// the user picks the destination, so the file lands somewhere they can find it
/// again (Downloads, Files, iCloud Drive) rather than inside app storage.
class FileSaver {
  /// Prepares [bytes] for viewing or saving, detecting the format from magic
  /// bytes.
  ///
  /// VTOP serves every download under a `downloadPdf/` path regardless of the
  /// real format, so the extension can only come from the content itself.
  static PreparedFile prepare({
    required Uint8List bytes,
    required String baseName,
  }) {
    final extension = FileTypeDetector.detectExtension(bytes);
    return prepareAs(bytes: bytes, baseName: baseName, extension: extension);
  }

  /// Prepares [bytes] as a known format, for downloads whose type is fixed —
  /// the syllabus is always a .docx, "download all" is always a ZIP.
  static PreparedFile prepareAs({
    required Uint8List bytes,
    required String baseName,
    required String extension,
  }) {
    return PreparedFile(
      bytes: bytes,
      fileName: '${_sanitizeFileName(baseName)}.$extension',
      mimeType: FileTypeDetector.getMimeType(extension),
    );
  }

  /// Subfolder of the temporary directory that "View" writes into.
  ///
  /// The viewer app reads the file after this call returns, so it can't be
  /// deleted here. It is kept in its own folder so logout can remove a
  /// student's marks sheets and outing passes without touching other caches.
  static const viewedDirectoryName = 'viewed_files';

  /// Deletes everything [openTemporarily] has written under [temporaryDirectory].
  static Future<void> clearViewedFilesIn(Directory temporaryDirectory) async {
    final viewedDir = Directory(
      '${temporaryDirectory.path}/$viewedDirectoryName',
    );
    if (await viewedDir.exists()) await viewedDir.delete(recursive: true);
  }

  /// [clearViewedFilesIn] for the app's own temporary directory.
  static Future<void> clearViewedFiles() async =>
      clearViewedFilesIn(await getTemporaryDirectory());

  /// Writes [file] to the temporary directory and opens it with the system's
  /// default app — the "View" path. Nothing is persisted.
  ///
  /// Returns false when no installed app can handle the format, in which case
  /// the caller should point the user at "Download" instead.
  static Future<bool> openTemporarily(PreparedFile file) async {
    final viewedDir = Directory(
      '${(await getTemporaryDirectory()).path}/$viewedDirectoryName',
    );
    await viewedDir.create(recursive: true);
    final tempFile = File('${viewedDir.path}/${file.fileName}');
    await tempFile.writeAsBytes(file.bytes);

    final result = await OpenFile.open(tempFile.path, type: file.mimeType);
    return result.type == ResultType.done;
  }

  /// Saves [file] through the system save dialog — the "Download" path.
  ///
  /// Returns the destination reported by the platform, or null if the user
  /// cancelled. That value is a display hint only: on Android it is the *path
  /// component* of a SAF content URI (`/document/primary:Download/foo.pdf`) and
  /// on iOS it points outside the app sandbox, so neither can be reopened by
  /// the app afterwards. Treat it as "the user saved it", never as a file path.
  static Future<String?> save(PreparedFile file) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return _saveToDocuments(file);
    }

    // The dialog takes a file on disk, so stage the bytes in the temp
    // directory first and clear them out however the dialog ends.
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${file.fileName}');
    await tempFile.writeAsBytes(file.bytes);

    try {
      return await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          sourceFilePath: tempFile.path,
          fileName: file.fileName,
          mimeTypesFilter: [file.mimeType],
        ),
      );
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  /// Prepares bytes already known to be a PDF.
  ///
  /// [fileName] may arrive with or without the extension — callers pass a bare
  /// name (`general_outing_123`) while the PDF viewer passes whatever it was
  /// constructed with — so strip a trailing `.pdf` before re-adding it rather
  /// than saving `general_outing_123.pdf.pdf`.
  static PreparedFile preparePdf({
    required Uint8List bytes,
    required String fileName,
  }) {
    final baseName = fileName.toLowerCase().endsWith('.pdf')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;

    return prepareAs(bytes: bytes, baseName: baseName, extension: 'pdf');
  }

  /// Saves a PDF whose bytes are already known to be a PDF.
  static Future<String?> savePdf({
    required Uint8List bytes,
    required String fileName,
  }) {
    return save(preparePdf(bytes: bytes, fileName: fileName));
  }

  /// Desktop fallback — there is no save dialog wired up for those platforms,
  /// so the file goes to the documents directory.
  static Future<String?> _saveToDocuments(PreparedFile file) async {
    final directory = await getApplicationDocumentsDirectory();
    final saved = File('${directory.path}/${file.fileName}');
    await saved.writeAsBytes(file.bytes);
    return saved.path;
  }

  /// Sanitizes a filename by replacing characters no filesystem accepts.
  static String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}
