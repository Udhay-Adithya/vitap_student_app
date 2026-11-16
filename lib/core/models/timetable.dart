// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';

part 'timetable.g.dart';

@Entity()
@JsonSerializable()
class Timetable {
  @Id()
  int? id;

  @JsonKey(name: 'Monday')
  @_DayRelToManyConverter()
  final ToMany<Day> monday;

  @JsonKey(name: 'Tuesday')
  @_DayRelToManyConverter()
  final ToMany<Day> tuesday;

  @JsonKey(name: 'Wednesday')
  @_DayRelToManyConverter()
  final ToMany<Day> wednesday;

  @JsonKey(name: 'Thursday')
  @_DayRelToManyConverter()
  final ToMany<Day> thursday;

  @JsonKey(name: 'Friday')
  @_DayRelToManyConverter()
  final ToMany<Day> friday;

  @JsonKey(name: 'Saturday')
  @_DayRelToManyConverter()
  final ToMany<Day> saturday;

  @JsonKey(name: 'Sunday')
  @_DayRelToManyConverter()
  final ToMany<Day> sunday;

  factory Timetable.fromJson(Map<String, dynamic> json) =>
      _$TimetableFromJson(json);

  Timetable({
    this.id,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });
  Map<String, dynamic> toJson() => _$TimetableToJson(this);

  @override
  String toString() {
    return 'Timetable(id: $id, monday: $monday, tuesday: $tuesday, wednesday: $wednesday, thursday: $thursday, friday: $friday, saturday: $saturday, sunday: $sunday)';
  }
}

@Entity()
@JsonSerializable()
class Day {
  @Id()
  int? id;

  @JsonKey(name: 'start_time')
  String? startTime;
  @JsonKey(name: 'end_time')
  String? endTime;
  @JsonKey(name: 'course_name')
  String? courseName;
  @JsonKey(name: 'slot')
  String? slot;
  @JsonKey(name: 'venue')
  String? venue;
  @JsonKey(name: 'faculty')
  String? faculty;
  @JsonKey(name: 'course_code')
  String? courseCode;
  @JsonKey(name: 'course_type')
  String? courseType;

  Day({
    this.id,
    this.startTime,
    this.endTime,
    this.courseName,
    this.slot,
    this.venue,
    this.faculty,
    this.courseCode,
    this.courseType,
  });

  factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);
  Map<String, dynamic> toJson() => _$DayToJson(this);
}

class _DayRelToManyConverter
    implements JsonConverter<ToMany<Day>, List<dynamic>?> {
  const _DayRelToManyConverter();

  @override
  ToMany<Day> fromJson(List<dynamic>? json) {
    final items =
        json?.map((e) => Day.fromJson(e as Map<String, dynamic>)).toList() ??
        [];
    return ToMany<Day>(items: items);
  }

  @override
  List<Map<String, dynamic>>? toJson(ToMany<Day> rel) =>
      rel.map((e) => e.toJson()).toList();
}
