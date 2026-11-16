import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'digital_assignment_model.g.dart';

// ---------------------------------------------------------------------------
// JSON helpers
// ---------------------------------------------------------------------------

List<DigitalAssignment> digitalAssignmentsFromJson(String str) =>
    List<DigitalAssignment>.from(
      (json.decode(str) as List).map(
        (x) => DigitalAssignment.fromJson(x as Map<String, dynamic>),
      ),
    );

String digitalAssignmentsToJson(List<DigitalAssignment> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

@JsonSerializable()
class DigitalAssignment {
  @JsonKey(name: 'serial_number')
  final String serialNumber;

  @JsonKey(name: 'class_id')
  final String classId;

  @JsonKey(name: 'course_code')
  final String courseCode;

  @JsonKey(name: 'course_title')
  final String courseTitle;

  @JsonKey(name: 'course_type')
  final String courseType;

  @JsonKey(name: 'faculty')
  final String faculty;

  @JsonKey(name: 'details')
  final List<AssignmentDetail> details;

  DigitalAssignment({
    required this.serialNumber,
    required this.classId,
    required this.courseCode,
    required this.courseTitle,
    required this.courseType,
    required this.faculty,
    required this.details,
  });

  factory DigitalAssignment.fromJson(Map<String, dynamic> json) =>
      _$DigitalAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$DigitalAssignmentToJson(this);
}

@JsonSerializable()
class AssignmentDetail {
  @JsonKey(name: 'serial_number')
  final String serialNumber;

  @JsonKey(name: 'assignment_title')
  final String assignmentTitle;

  @JsonKey(name: 'max_assignment_mark')
  final String maxAssignmentMark;

  @JsonKey(name: 'assignment_weightage_mark')
  final String assignmentWeightageMark;

  @JsonKey(name: 'due_date')
  final String dueDate;

  @JsonKey(name: 'can_qp_download')
  final bool canQpDownload;

  @JsonKey(name: 'qp_download_url')
  final String qpDownloadUrl;

  @JsonKey(name: 'submission_status')
  final String submissionStatus;

  @JsonKey(name: 'can_update')
  final bool canUpdate;

  @JsonKey(name: 'mcode')
  final String mcode;

  @JsonKey(name: 'can_da_download')
  final bool canDaDownload;

  @JsonKey(name: 'da_download_url')
  final String daDownloadUrl;

  AssignmentDetail({
    required this.serialNumber,
    required this.assignmentTitle,
    required this.maxAssignmentMark,
    required this.assignmentWeightageMark,
    required this.dueDate,
    required this.canQpDownload,
    required this.qpDownloadUrl,
    required this.submissionStatus,
    required this.canUpdate,
    required this.mcode,
    required this.canDaDownload,
    required this.daDownloadUrl,
  });

  factory AssignmentDetail.fromJson(Map<String, dynamic> json) =>
      _$AssignmentDetailFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentDetailToJson(this);
}

// ---------------------------------------------------------------------------
// Submission Status Helpers
// ---------------------------------------------------------------------------

/// Submission status classification.
///
/// The Rust bridge returns three possible values for `submissionStatus`:
///   - `""` (empty string) → deadline not passed yet, can still upload → **Pending**
///   - `"File Not Uploaded"` → deadline passed without submission → **Missed**
///   - A date string like `"24 Jan 2026 11:48 PM"` → file was submitted → **Submitted**
enum SubmissionState {
  /// Deadline still open, assignment can be submitted.
  pending,

  /// Deadline passed, file was never uploaded.
  missed,

  /// File was successfully submitted (status contains the submission date).
  submitted,
}

/// Determine the [SubmissionState] from the raw `submissionStatus` string.
SubmissionState getSubmissionState(String submissionStatus) {
  if (submissionStatus.isEmpty) return SubmissionState.pending;
  if (submissionStatus == 'File Not Uploaded') return SubmissionState.missed;
  return SubmissionState.submitted;
}

/// Counts for each submission state within a list of assignment details.
class SubmissionCounts {
  final int submitted;
  final int pending;
  final int missed;
  final int total;

  const SubmissionCounts({
    required this.submitted,
    required this.pending,
    required this.missed,
    required this.total,
  });

  factory SubmissionCounts.fromDetails(List<AssignmentDetail> details) {
    int submitted = 0;
    int pending = 0;
    int missed = 0;
    for (final d in details) {
      switch (getSubmissionState(d.submissionStatus)) {
        case SubmissionState.submitted:
          submitted++;
          break;
        case SubmissionState.pending:
          pending++;
          break;
        case SubmissionState.missed:
          missed++;
          break;
      }
    }
    return SubmissionCounts(
      submitted: submitted,
      pending: pending,
      missed: missed,
      total: details.length,
    );
  }
}
