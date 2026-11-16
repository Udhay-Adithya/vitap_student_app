// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';

part 'capstone_attendance.g.dart';

/// Capstone/SDP attendance for the current semester.
///
/// This is deliberately not an [Attendance]: a capstone has no course code,
/// slot or faculty, and VTOP tracks it as a daily punch with a
/// present/on-duty/absent tally rather than as classes attended out of classes
/// held. Squeezing it into a course record meant inventing values for every
/// field it does not have.
@Entity()
@JsonSerializable()
class CapstoneAttendance {
  @Id()
  int? id;

  /// "Capstone" or "SDP", as VTOP labels the registration.
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'guide_evaluation_status')
  final String guideEvaluationStatus;

  @JsonKey(name: 'date_of_registration')
  final String dateOfRegistration;

  @JsonKey(name: 'present')
  final String present;

  @JsonKey(name: 'on_duty')
  final String onDuty;

  @JsonKey(name: 'absent')
  final String absent;

  /// Stripped of its "%" on the Rust side, so it parses as a number.
  @JsonKey(name: 'percentage')
  final String percentage;

  @JsonKey(name: 'punches')
  @_CapstonePunchRelToManyConverter()
  final ToMany<CapstonePunch> punches;

  CapstoneAttendance({
    this.id,
    required this.title,
    required this.guideEvaluationStatus,
    required this.dateOfRegistration,
    required this.present,
    required this.onDuty,
    required this.absent,
    required this.percentage,
    required this.punches,
  });

  factory CapstoneAttendance.fromJson(Map<String, dynamic> json) =>
      _$CapstoneAttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$CapstoneAttendanceToJson(this);

  @override
  String toString() {
    return 'CapstoneAttendance(id: $id, title: $title, guideEvaluationStatus: $guideEvaluationStatus, dateOfRegistration: $dateOfRegistration, present: $present, onDuty: $onDuty, absent: $absent, percentage: $percentage, punches: ${punches.toString()})';
  }
}

/// The day counts and percentage as numbers.
///
/// The three counts stay separate everywhere: an on-duty day is neither
/// attended nor absent, and folding them into an attended/total pair is what
/// loses that distinction.
extension CapstoneAttendanceTally on CapstoneAttendance {
  int get presentDays => int.tryParse(present) ?? 0;
  int get onDutyDays => int.tryParse(onDuty) ?? 0;
  int get absentDays => int.tryParse(absent) ?? 0;
  int get totalDays => presentDays + onDutyDays + absentDays;

  /// Null when VTOP sends something unparseable, so callers can say so rather
  /// than showing a confident 0% that reads as "you never turned up".
  double? get percentageValue => double.tryParse(percentage);
}

/// One day in the capstone attendance calendar.
@Entity()
@JsonSerializable()
class CapstonePunch {
  @Id()
  int? id;

  @JsonKey(name: 'serial')
  final String serial;

  @JsonKey(name: 'date')
  final String date;

  @JsonKey(name: 'day')
  final String day;

  /// Free text from VTOP: "Instructional", "Holiday", "No Instructional",
  /// "CAT1", ... Not an enum, since VTOP adds day types.
  @JsonKey(name: 'day_type')
  final String dayType;

  /// "Present", "Absent" or "On Duty". Empty on days that carry no status at
  /// all — holidays, non-instructional days, days not yet reached.
  @JsonKey(name: 'status')
  final String status;

  /// Empty when there was no punch.
  @JsonKey(name: 'punch_time')
  final String punchTime;

  CapstonePunch({
    this.id,
    required this.serial,
    required this.date,
    required this.day,
    required this.dayType,
    required this.status,
    required this.punchTime,
  });

  factory CapstonePunch.fromJson(Map<String, dynamic> json) =>
      _$CapstonePunchFromJson(json);
  Map<String, dynamic> toJson() => _$CapstonePunchToJson(this);

  @override
  String toString() {
    return 'CapstonePunch(id: $id, serial: $serial, date: $date, day: $day, dayType: $dayType, status: $status, punchTime: $punchTime)';
  }
}

class _CapstonePunchRelToManyConverter
    implements JsonConverter<ToMany<CapstonePunch>, List<dynamic>?> {
  const _CapstonePunchRelToManyConverter();

  @override
  ToMany<CapstonePunch> fromJson(List<dynamic>? json) {
    final items =
        json
            ?.map((e) => CapstonePunch.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return ToMany<CapstonePunch>(items: items);
  }

  @override
  List<Map<String, dynamic>>? toJson(ToMany<CapstonePunch> rel) =>
      rel.map((e) => e.toJson()).toList();
}
