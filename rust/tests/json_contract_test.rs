//! The Rust half of the bridge's JSON contract.
//!
//! Most VTOP data crosses the bridge as a JSON string: Rust serializes a
//! struct, Dart decodes it with a hand-written or generated `fromJson`.
//! Nothing in either language checks that the two agree, so a renamed field
//! compiles on both sides and shows up as "Invalid response format from
//! server" on a student's phone.
//!
//! So the JSON lives in `test_fixtures/contract/`, committed. This asserts
//! Rust still produces it; `test/contract/rust_json_contract_test.dart`
//! asserts Dart still reads it. Rename a field on either side and that side's
//! test fails in the pull request that did it.
//!
//! The fixtures are not regenerated as part of a normal change. Regenerating
//! one is how you declare a deliberate change to the wire format — and the
//! Dart test is then what tells you the app has to change with it.

use lib_vtop::api::vtop::types::*;
use serde_json::{json, Value};

fn fixture(name: &str) -> Value {
    let path = format!(
        "{}/../test_fixtures/contract/{name}",
        env!("CARGO_MANIFEST_DIR")
    );
    let text =
        std::fs::read_to_string(&path).unwrap_or_else(|e| panic!("could not read {path}: {e}"));
    serde_json::from_str(&text).unwrap_or_else(|e| panic!("{name} is not valid JSON: {e}"))
}

fn attendance_record() -> AttendanceRecord {
    AttendanceRecord {
        class_number: "AP2026272000101".into(),
        course_code: "CSE3009".into(),
        course_name: "NoSQL Databases".into(),
        course_type: "Embedded Theory".into(),
        course_type_code: "ETH".into(),
        course_slot: "C1+TCC1".into(),
        faculty: "Test Faculty - SCOPE".into(),
        attended_classes: "23".into(),
        total_classes: "25".into(),
        attendance_percentage: "92".into(),
        attendance_between_percentage: "0".into(),
        debar_status: "-".into(),
        course_id: "AM_CSE3009_00200".into(),
    }
}

fn capstone() -> CapstoneAttendance {
    CapstoneAttendance {
        info: CapstoneInfo {
            title: "A capstone project".into(),
            guide_evaluation_status: "Registered".into(),
            date_of_registration: "2026-07-06 00:00:00.0".into(),
        },
        summary: CapstoneSummary {
            present: "14".into(),
            on_duty: "4".into(),
            absent: "2".into(),
            percentage: "90".into(),
        },
        punches: vec![CapstonePunch {
            serial: "1".into(),
            date: "17-07-2026".into(),
            day: "FRIDAY".into(),
            day_type: "Instructional".into(),
            status: "Present".into(),
            punch_time: "09:05".into(),
        }],
    }
}

fn timetable_class() -> TimetableClass {
    TimetableClass {
        start_time: "09:00".into(),
        end_time: "09:50".into(),
        course_name: "NoSQL Databases".into(),
        slot: "C1".into(),
        venue: "430".into(),
        faculty: "Test Faculty".into(),
        course_code: "CSE3009".into(),
        course_type: "Embedded Theory".into(),
    }
}

fn timetable() -> Timetable {
    Timetable {
        monday: vec![timetable_class()],
        tuesday: vec![],
        wednesday: vec![],
        thursday: vec![timetable_class()],
        friday: vec![],
        saturday: vec![],
        sunday: vec![],
    }
}

fn general_outing() -> Vec<GeneralOutingRecord> {
    vec![GeneralOutingRecord {
        serial: "1".into(),
        registration_number: "23BCE0001".into(),
        place_of_visit: "Vijayawada".into(),
        purpose_of_visit: "Shopping".into(),
        from_date: "2026-01-12 00:00:00.0".into(),
        from_time: "12:00 PM".into(),
        to_date: "2026-01-12 00:00:00.0".into(),
        to_time: "07:00 PM".into(),
        status: "Leave Request Accepted".into(),
        can_download: true,
        leave_id: "L2000001".into(),
    }]
}

fn weekend_outing() -> Vec<WeekendOutingRecord> {
    vec![WeekendOutingRecord {
        serial: "1".into(),
        registration_number: "23BCE0001".into(),
        hostel_block: "MH-1".into(),
        room_number: "101".into(),
        place_of_visit: "Vijayawada".into(),
        purpose_of_visit: "Shopping".into(),
        time: "10:30 AM- 4:30PM".into(),
        contact_number: "".into(),
        parent_contact_number: "".into(),
        date: "2026-07-26".into(),
        booking_id: "W26000000001".into(),
        status: "Outing Request Accepted".into(),
        can_download: true,
    }]
}

/// The two keys mirror the private `AttendanceWithCapstone` the bridge
/// serializes, which an integration test cannot reach. The Dart repository
/// reads `payload['records']` and `payload['capstone']` by hand.
#[test]
fn test_attendance_matches_the_committed_json() {
    let produced = json!({ "records": vec![attendance_record()], "capstone": capstone() });

    assert_eq!(produced, fixture("attendance.json"));
}

/// `CapstoneAttendance` holds its fields in two nested structs but is
/// `#[serde(flatten)]`ed on the wire, because the Dart model is flat. Losing
/// those attributes would nest the JSON and leave every capstone field empty
/// on screen without failing anything else.
#[test]
fn test_capstone_is_flat_on_the_wire() {
    let produced = serde_json::to_value(capstone()).unwrap();
    let object = produced.as_object().unwrap();

    assert!(object.contains_key("title"));
    assert!(object.contains_key("present"));
    assert!(!object.contains_key("info"));
    assert!(!object.contains_key("summary"));
}

#[test]
fn test_timetable_matches_the_committed_json() {
    let produced = serde_json::to_value(timetable()).unwrap();

    assert_eq!(produced, fixture("timetable.json"));
}

/// The days are renamed to match the Dart model's `@JsonKey(name: 'Monday')`.
/// Drop the `#[serde(rename)]` attributes and every day reads as empty.
#[test]
fn test_timetable_days_are_capitalised() {
    let produced = serde_json::to_value(timetable()).unwrap();
    let object = produced.as_object().unwrap();

    assert!(object.contains_key("Monday"));
    assert!(!object.contains_key("monday"));
}

#[test]
fn test_general_outing_matches_the_committed_json() {
    let produced = serde_json::to_value(general_outing()).unwrap();

    assert_eq!(produced, fixture("general_outing.json"));
}

#[test]
fn test_weekend_outing_matches_the_committed_json() {
    let produced = serde_json::to_value(weekend_outing()).unwrap();

    assert_eq!(produced, fixture("weekend_outing.json"));
}
