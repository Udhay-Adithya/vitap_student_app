// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';

import 'grade_history.dart';
import 'mentor_details.dart';

part 'profile.g.dart';

@Entity()
@JsonSerializable()
class Profile {
  @Id()
  int? id;

  @JsonKey(name: 'application_number')
  final String applicationNumber;

  /// Registration number scraped after login (e.g. `23BCE7625`).
  ///
  /// Distinct from the login id the user typed — VTOP accepts several. Empty
  /// for profiles cached before this field existed.
  @JsonKey(name: 'registration_number', defaultValue: '')
  final String registrationNumber;

  @JsonKey(name: 'student_name')
  final String studentName;
  @JsonKey(name: 'dob')
  final String dob;
  @JsonKey(name: 'gender')
  final String gender;
  @JsonKey(name: 'blood_group')
  final String bloodGroup;
  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'base64_pfp')
  final String? base64Pfp;

  @JsonKey(name: 'grade_history')
  @_GradeHistoryRelToOneConverter()
  final ToOne<GradeHistory> gradeHistory;

  @JsonKey(name: 'mentor_details')
  @_MentorDetailsRelToOneConverter()
  final ToOne<MentorDetails> mentorDetails;

  Profile({
    this.id,
    required this.applicationNumber,
    this.registrationNumber = '',
    required this.studentName,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.email,
    this.base64Pfp,
    required this.gradeHistory,
    required this.mentorDetails,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @override
  String toString() {
    return 'Profile(id: $id, applicationNumber: $applicationNumber, registrationNumber: $registrationNumber, studentName: $studentName, dob: $dob, gender: $gender, bloodGroup: $bloodGroup, email: $email, base64Pfp: $base64Pfp, gradeHistory: ${gradeHistory.toString()}, mentorDetails: ${mentorDetails.toString()})';
  }
}

// Converters for Profile relations
class _GradeHistoryRelToOneConverter
    implements JsonConverter<ToOne<GradeHistory>, Map<String, dynamic>?> {
  const _GradeHistoryRelToOneConverter();

  @override
  ToOne<GradeHistory> fromJson(Map<String, dynamic>? json) =>
      ToOne<GradeHistory>(
        target: json != null ? GradeHistory.fromJson(json) : null,
      );

  @override
  Map<String, dynamic>? toJson(ToOne<GradeHistory> rel) => rel.target?.toJson();
}

class _MentorDetailsRelToOneConverter
    implements JsonConverter<ToOne<MentorDetails>, Map<String, dynamic>?> {
  const _MentorDetailsRelToOneConverter();

  @override
  ToOne<MentorDetails> fromJson(Map<String, dynamic>? json) =>
      ToOne<MentorDetails>(
        target: json != null ? MentorDetails.fromJson(json) : null,
      );

  @override
  Map<String, dynamic>? toJson(ToOne<MentorDetails> rel) =>
      rel.target?.toJson();
}
