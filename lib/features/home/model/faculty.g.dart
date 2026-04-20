// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faculty.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacultyListItem _$FacultyListItemFromJson(Map<String, dynamic> json) =>
    FacultyListItem(
      facultyName: json['faculty_name'] as String,
      designation: json['designation'] as String,
      schoolOrCentre: json['school_or_centre'] as String,
      empId: json['emp_id'] as String,
    );

Map<String, dynamic> _$FacultyListItemToJson(FacultyListItem instance) =>
    <String, dynamic>{
      'faculty_name': instance.facultyName,
      'designation': instance.designation,
      'school_or_centre': instance.schoolOrCentre,
      'emp_id': instance.empId,
    };
