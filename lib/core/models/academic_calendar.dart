// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';

part 'academic_calendar.g.dart';

/// A semester's academic calendar.
///
/// VTOP serves this a month at a time behind a month-list lookup, so building
/// one of these costs a request per month. It is published once a semester and
/// then barely changes, which is why it is cached rather than refetched.
@Entity()
@JsonSerializable()
class AcademicCalendar {
  @Id()
  int? id;

  @JsonKey(name: 'semester_id')
  final String semesterId;

  @JsonKey(name: 'class_group_id')
  final String classGroupId;

  @JsonKey(name: 'months')
  @_CalendarMonthRelToManyConverter()
  final ToMany<CalendarMonthRef> months;

  /// Every dated day of the semester, in date order.
  ///
  /// VTOP lays each month out as a week grid, but the grid is a display
  /// concern: a flat list is what lets the app look up a date or find the next
  /// holiday without walking rows and columns.
  @JsonKey(name: 'days')
  @_CalendarDayRelToManyConverter()
  final ToMany<CalendarDay> days;

  /// When this was last read from VTOP. Not part of VTOP's response.
  @JsonKey(includeFromJson: false, includeToJson: false)
  DateTime? fetchedAt;

  AcademicCalendar({
    this.id,
    required this.semesterId,
    required this.classGroupId,
    required this.months,
    required this.days,
    this.fetchedAt,
  });

  factory AcademicCalendar.fromJson(Map<String, dynamic> json) =>
      _$AcademicCalendarFromJson(json);
  Map<String, dynamic> toJson() => _$AcademicCalendarToJson(this);

  @override
  String toString() {
    return 'AcademicCalendar(id: $id, semesterId: $semesterId, classGroupId: $classGroupId, months: ${months.length}, days: ${days.length})';
  }
}

/// A month the calendar covers.
@Entity()
@JsonSerializable()
class CalendarMonthRef {
  @Id()
  int? id;

  /// What VTOP shows on the button, e.g. "AUG-2026".
  @JsonKey(name: 'label')
  final String label;

  /// What VTOP's lookup expects, e.g. "01-AUG-2026". Different from the label,
  /// so both are kept.
  @JsonKey(name: 'cal_date')
  final String calDate;

  CalendarMonthRef({this.id, required this.label, required this.calDate});

  factory CalendarMonthRef.fromJson(Map<String, dynamic> json) =>
      _$CalendarMonthRefFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarMonthRefToJson(this);

  @override
  String toString() => 'CalendarMonthRef(label: $label, calDate: $calDate)';
}

/// A single dated day of the academic calendar.
@Entity()
@JsonSerializable()
class CalendarDay {
  @Id()
  int? id;

  /// ISO `YYYY-MM-DD`.
  @JsonKey(name: 'date')
  final String date;

  @JsonKey(name: 'day')
  final int day;

  /// "Sunday" through "Saturday".
  @JsonKey(name: 'weekday')
  final String weekday;

  @JsonKey(name: 'events')
  @_CalendarEventRelToManyConverter()
  final ToMany<CalendarEvent> events;

  CalendarDay({
    this.id,
    required this.date,
    required this.day,
    required this.weekday,
    required this.events,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json) =>
      _$CalendarDayFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarDayToJson(this);

  @override
  String toString() =>
      'CalendarDay(date: $date, weekday: $weekday, events: ${events.length})';
}

/// One entry on a calendar day.
///
/// Which of the two fields is the headline depends on the day. An exam carries
/// it in the description ("CAT - I - General (Semester)") and a generic label
/// ("Exam Days"); a named holiday does the opposite, keeping the description
/// generic ("Holiday - General (Semester)") and putting "Independence Day" in
/// the label.
@Entity()
@JsonSerializable()
class CalendarEvent {
  @Id()
  int? id;

  @JsonKey(name: 'description')
  final String description;

  /// The parenthesised qualifier with its brackets stripped. Empty when VTOP
  /// gave the entry no qualifier.
  @JsonKey(name: 'label')
  final String label;

  CalendarEvent({this.id, required this.description, required this.label});

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarEventToJson(this);

  @override
  String toString() =>
      'CalendarEvent(description: $description, label: $label)';
}

class _CalendarMonthRelToManyConverter
    implements JsonConverter<ToMany<CalendarMonthRef>, List<dynamic>?> {
  const _CalendarMonthRelToManyConverter();

  @override
  ToMany<CalendarMonthRef> fromJson(List<dynamic>? json) => ToMany(
    items:
        json
            ?.map((e) => CalendarMonthRef.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  @override
  List<Map<String, dynamic>> toJson(ToMany<CalendarMonthRef> rel) =>
      rel.map((e) => e.toJson()).toList();
}

class _CalendarDayRelToManyConverter
    implements JsonConverter<ToMany<CalendarDay>, List<dynamic>?> {
  const _CalendarDayRelToManyConverter();

  @override
  ToMany<CalendarDay> fromJson(List<dynamic>? json) => ToMany(
    items:
        json
            ?.map((e) => CalendarDay.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  @override
  List<Map<String, dynamic>> toJson(ToMany<CalendarDay> rel) =>
      rel.map((e) => e.toJson()).toList();
}

class _CalendarEventRelToManyConverter
    implements JsonConverter<ToMany<CalendarEvent>, List<dynamic>?> {
  const _CalendarEventRelToManyConverter();

  @override
  ToMany<CalendarEvent> fromJson(List<dynamic>? json) => ToMany(
    items:
        json
            ?.map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  @override
  List<Map<String, dynamic>> toJson(ToMany<CalendarEvent> rel) =>
      rel.map((e) => e.toJson()).toList();
}
