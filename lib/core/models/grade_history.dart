// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';

part 'grade_history.g.dart';

@Entity()
@JsonSerializable()
class GradeHistory {
  @Id()
  int? id;

  @JsonKey(name: 'credits_registered')
  final String creditsRegistered;
  @JsonKey(name: 'credits_earned')
  final String creditsEarned;
  @JsonKey(name: 'cgpa')
  final String cgpa;
  @_CourseRelToManyConverter()
  @JsonKey(name: 'courses')
  final ToMany<Course> courses;

  GradeHistory({
    this.id,
    required this.creditsRegistered,
    required this.creditsEarned,
    required this.cgpa,
    required this.courses,
  });

  factory GradeHistory.fromJson(Map<String, dynamic> json) =>
      _$GradeHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$GradeHistoryToJson(this);

  @override
  String toString() {
    return 'GradeHistory(id: $id, creditsRegistered: $creditsRegistered, creditsEarned: $creditsEarned, cgpa: $cgpa, courses: ${courses.toString()})';
  }
}

@Entity()
@JsonSerializable()
class Course {
  @Id()
  int? id;
  @JsonKey(name: 'course_code')
  String courseCode;
  @JsonKey(name: 'course_title')
  String courseTitle;
  @JsonKey(name: 'course_type')
  String courseType;
  @JsonKey(name: 'credits')
  String credits;
  @JsonKey(name: 'grade')
  String grade;
  @JsonKey(name: 'exam_month')
  String examMonth;
  @JsonKey(name: 'course_distribution')
  String courseDistribution;

  Course({
    this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.courseType,
    required this.credits,
    required this.grade,
    required this.examMonth,
    required this.courseDistribution,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseToJson(this);

  @override
  String toString() {
    return 'Course(id: $id, courseCode: $courseCode, courseTitle: $courseTitle, courseType: $courseType, credits: $credits, grade: $grade, examMonth: $examMonth, courseDistribution: $courseDistribution)';
  }
}

class _CourseRelToManyConverter
    implements JsonConverter<ToMany<Course>, List<dynamic>?> {
  const _CourseRelToManyConverter();

  @override
  ToMany<Course> fromJson(List<dynamic>? json) {
    final items =
        json?.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList() ??
        [];
    return ToMany<Course>(items: items);
  }

  @override
  List<Map<String, dynamic>>? toJson(ToMany<Course> rel) =>
      rel.map((e) => e.toJson()).toList();
}
