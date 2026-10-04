use lib_vtop::api::vtop::parser::exam_schedule_parser::parse_schedule;

/// A trimmed Fall 2026-27 exam schedule, two weeks before CAT2.
///
/// One table holds every exam: a class-group header and a column header, then
/// for each exam a single-cell row naming it (CAT2, CAT1) followed by that
/// exam's courses. VTOP lists the upcoming exam first. The CAT2 row is from
/// before seats were allocated, so its venue and seat cells are `-`; the CAT1
/// row has them filled in.
const SCHEDULE_PAGE: &str = r#"
<div class="fixedTableContainer" id="fixedTableContainer">
  <table class="customTable">
    <tr class="tableHeader">
      <td colspan="13" align="center"><span>General
          (Semester)</span></td>
    </tr>
    <tr class="tableHeader">
      <td><span>S.No.</span></td>
      <td><span>Course Code</span></td>
      <td><span>Course Title</span></td>
      <td><span>Course Type</span></td>
      <td><span>Class ID</span></td>
      <td><span>Slot</span></td>
      <td><span>Exam Date</span></td>
      <td><span>Exam Session</span></td>
      <td><span>Reporting Time</span></td>
      <td><span>Exam Time</span></td>
      <td><span>Venue</span></td>
      <td><span>Seat Location</span></td>
      <td><span>Seat No.</span></td>
    </tr>
    <tr class="tableContent">
      <td colspan="13" class="panelHead-secondary" align="center">CAT2</td>
    </tr>
    <tr class="tableContent">
      <td>1</td>
      <td>CSE3009</td>
      <td>NoSQL Databases</td>
      <td>ETH</td>
      <td>AP2026272000101</td>
      <td>C1+TCC1</td>
      <td>30-Sep-2026</td>
      <td>FN1</td>
      <td>09:30 AM</td>
      <td>10:00 AM - 11:30 AM</td>
      <td> <span>-</span>
      </td>
      <td><span>-</span>
      </td>
      <td><span>-</span>
      </td>
    </tr>
    <tr class="tableContent">
      <td colspan="13" class="panelHead-secondary" align="center">CAT1</td>
    </tr>
    <tr class="tableContent">
      <td>1</td>
      <td>CSE3009</td>
      <td>NoSQL Databases</td>
      <td>ETH</td>
      <td>AP2026272000101</td>
      <td>C1+TCC1</td>
      <td>19-Aug-2026</td>
      <td>FN1</td>
      <td>09:30 AM</td>
      <td>10:00 AM - 11:30 AM</td>
      <td> <span>AB2-101</span>
      </td>
      <td><span>R1C1</span>
      </td>
      <td><span>12</span>
      </td>
    </tr>
  </table>
</div>
"#;

#[test]
fn test_groups_courses_under_each_exam_in_page_order() {
    let exams = parse_schedule(SCHEDULE_PAGE.to_string());

    assert_eq!(exams.len(), 2);
    assert_eq!(exams[0].exam_type, "CAT2");
    assert_eq!(exams[1].exam_type, "CAT1");
    assert_eq!(exams[0].subjects.len(), 1);
    assert_eq!(exams[1].subjects.len(), 1);
}

#[test]
fn test_reads_every_column_of_a_course() {
    let exams = parse_schedule(SCHEDULE_PAGE.to_string());
    let course = &exams[1].subjects[0];

    assert_eq!(course.serial_number, "1");
    assert_eq!(course.course_code, "CSE3009");
    assert_eq!(course.course_name, "NoSQL Databases");
    assert_eq!(course.course_type, "ETH");
    assert_eq!(course.course_id, "AP2026272000101");
    assert_eq!(course.slot, "C1+TCC1");
    assert_eq!(course.exam_date, "19-Aug-2026");
    assert_eq!(course.exam_session, "FN1");
    assert_eq!(course.reporting_time, "09:30 AM");
    assert_eq!(course.exam_time, "10:00 AM - 11:30 AM");
    assert_eq!(course.venue, "AB2-101");
    assert_eq!(course.seat_location, "R1C1");
    assert_eq!(course.seat_number, "12");
}

/// Before seats are allocated VTOP fills venue and seat with `-`. The parser
/// passes that through; deciding how to show "not allocated yet" is the app's
/// job.
#[test]
fn test_unallocated_seat_comes_through_as_a_dash() {
    let exams = parse_schedule(SCHEDULE_PAGE.to_string());
    let course = &exams[0].subjects[0];

    assert_eq!(course.venue, "-");
    assert_eq!(course.seat_location, "-");
    assert_eq!(course.seat_number, "-");
}

#[test]
fn test_schedule_with_no_exams_yields_nothing() {
    let headers_only = SCHEDULE_PAGE
        .split(r#"<tr class="tableContent">"#)
        .next()
        .unwrap()
        .to_string()
        + "</table></div>";

    assert!(parse_schedule(headers_only).is_empty());
}
