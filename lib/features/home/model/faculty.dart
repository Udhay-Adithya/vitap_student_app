import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'faculty.g.dart';

List<FacultyListItem> facultyListFromJson(String str) =>
    List<FacultyListItem>.from(
      (json.decode(str) as List).map(
        (x) => FacultyListItem.fromJson(x as Map<String, dynamic>),
      ),
    );

@JsonSerializable()
class FacultyListItem {
  @JsonKey(name: 'faculty_name')
  final String facultyName;
  final String designation;
  @JsonKey(name: 'school_or_centre')
  final String schoolOrCentre;
  @JsonKey(name: 'emp_id')
  final String empId;

  const FacultyListItem({
    required this.facultyName,
    required this.designation,
    required this.schoolOrCentre,
    required this.empId,
  });

  factory FacultyListItem.fromJson(Map<String, dynamic> json) =>
      _$FacultyListItemFromJson(json);
  Map<String, dynamic> toJson() => _$FacultyListItemToJson(this);
}
