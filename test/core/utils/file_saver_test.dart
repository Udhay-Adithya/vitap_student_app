import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/utils/file_saver.dart';

void main() {
  // Real magic bytes — the detector reads the signature, not the name.
  final pdf = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D, 0x31]);
  final zip = Uint8List.fromList([0x50, 0x4B, 0x03, 0x04, 0x00, 0x00]);

  group('prepare', () {
    test('names the file from the detected format, not the requested one', () {
      // VTOP serves every download under a "downloadPdf/" path regardless of
      // the real format, so the extension can only come from the content.
      expect(
        FileSaver.prepare(bytes: zip, baseName: 'CSE1001_Unit 1').fileName,
        'CSE1001_Unit 1.zip',
      );
      expect(
        FileSaver.prepare(bytes: zip, baseName: 'anything').mimeType,
        'application/zip',
      );
    });

    test('replaces characters no filesystem accepts', () {
      // Material labels come straight from VTOP and routinely carry slashes
      // and colons, which would otherwise be read as path separators.
      final file = FileSaver.prepare(
        bytes: pdf,
        baseName: 'CSE1001_Unit 1/2: "notes" <draft>|v3?*',
      );

      expect(file.fileName, 'CSE1001_Unit 1_2_ _notes_ _draft__v3__.pdf');
    });
  });

  group('prepareAs', () {
    test('trusts the caller for downloads whose format is fixed', () {
      // The syllabus is always a .docx and "download all" always a ZIP, even
      // though both arrive over the same material download path.
      final syllabus = FileSaver.prepareAs(
        bytes: zip,
        baseName: 'CSE1001_syllabus',
        extension: 'docx',
      );

      expect(syllabus.fileName, 'CSE1001_syllabus.docx');
      expect(
        syllabus.mimeType,
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    });
  });

  group('preparePdf', () {
    test('adds the extension to a bare name', () {
      expect(
        FileSaver.preparePdf(
          bytes: pdf,
          fileName: 'general_outing_42',
        ).fileName,
        'general_outing_42.pdf',
      );
    });

    test('does not double up an extension the caller already added', () {
      // Callers are inconsistent: the outing view models pass a bare name and
      // the PDF viewer passes whatever it was constructed with. Saving
      // "pass.pdf.pdf" is the bug this locks down.
      expect(
        FileSaver.preparePdf(bytes: pdf, fileName: 'pass.pdf').fileName,
        'pass.pdf',
      );
      expect(
        FileSaver.preparePdf(bytes: pdf, fileName: 'PASS.PDF').fileName,
        'PASS.pdf',
      );
    });

    test('always reports the PDF mime type', () {
      expect(
        FileSaver.preparePdf(bytes: pdf, fileName: 'x').mimeType,
        'application/pdf',
      );
    });
  });

  group('clearViewedFilesIn', () {
    late Directory temp;

    setUp(() {
      temp = Directory.systemTemp.createTempSync('file_saver_test');
      addTearDown(() => temp.deleteSync(recursive: true));
    });

    test('removes viewed files and leaves other caches alone', () async {
      // Files opened with "View" are a student's marks sheets and outing
      // passes, and they outlived logout. Other plugins cache in the same
      // temporary directory, so only the viewed folder may go.
      final viewed = Directory('${temp.path}/${FileSaver.viewedDirectoryName}')
        ..createSync();
      File('${viewed.path}/marks.pdf').writeAsBytesSync(pdf);
      final other = File('${temp.path}/image_cache.bin')
        ..writeAsBytesSync([1, 2, 3]);

      await FileSaver.clearViewedFilesIn(temp);

      expect(viewed.existsSync(), isFalse);
      expect(other.existsSync(), isTrue);
    });

    test('does nothing when nothing was viewed', () async {
      await expectLater(FileSaver.clearViewedFilesIn(temp), completes);
    });
  });
}
