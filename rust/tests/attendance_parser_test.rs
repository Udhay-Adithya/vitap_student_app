use lib_vtop::api::vtop::parser::attendance_parser::{
    has_capstone_attendance, parse_attendance, parse_full_attendance,
};

/// A trimmed Fall 2026-27 attendance page: one course's theory and lab rows.
///
/// It keeps what the parser's column arithmetic depends on:
///   * ten cells per row — VTOP dropped the "CAT2/FAT Period" column, but left
///     it in the markup as an HTML comment, header and body alike;
///   * the percentage wrapped in a nested coloured span with a `%` sign;
///   * the detail link's `onclick`, whose quotes VTOP writes as `&#39;`;
///   * the CAPSTONE/SDP button below the table.
///
/// Identifying details are replaced.
const ATTENDANCE_PAGE: &str = r#"
<div class="form-group" id="getStudentDetails">
  <table id="AttendanceDetailDataTable" class="table table-bordered table-hover responsive">
    <thead>
      <tr>
        <td><b>Sl.No.</b></td>
        <td><b>Class Group</b></td>
        <td><b>Course Detail</b></td>
        <td><b>Class Detail</b></td>
        <td><b>Faculty Detail</b></td>
        <td><b>Attended Classes</b></td>
        <td><b>Total Classes</b></td>
        <td><b>Attendance Percentage</b></td>
        <!-- <td><b>CAT2/FAT Period Att. Percentage</b></td> -->
        <td><b>Debar Status</b></td>
        <td><b>Attendance Detail</b></td>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><span>1</span></td>
        <td><span>General (Semester)</span></td>
        <td><span>CSE3009 - NoSQL Databases - Embedded Theory</span></td>
        <td><span>AP2026272000101 - C1+TCC1 - 430</span></td>
        <td><span>Test Faculty - SCOPE</span></td>
        <td><span>23</span></td>
        <td><span>25</span></td>
        <td>
          <span>
            <span style="color: green; font-size: 20px;">92%</span>
          </span>
        </td>
        <!-- <td>
          <span th:if="${attendancePeriodCalculationMapList != null}">-</span>
        </td> -->
        <td><span>-</span></td>
        <td>
          <a id="studentAttendanceDetilShow_0"
            onclick="javascript: callStudentAttendanceDetailDisplay(&#39;AP2026272&#39;,&#39;23BCE0001&#39;,&#39;AM_CSE3009_00200&#39;,&#39;ETH&#39;);"
            href="javascript:void(0);">
            <span title="Show" class="glyphicon glyphicon-eye-open"></span>
          </a>
        </td>
      </tr>
      <tr>
        <td><span>2</span></td>
        <td><span>General (Semester)</span></td>
        <td><span>CSE3009 - NoSQL Databases - Embedded Lab</span></td>
        <td><span>AP2026272000102 - L1+L2 - 409</span></td>
        <td><span>Test Faculty - SCOPE</span></td>
        <td><span>16</span></td>
        <td><span>20</span></td>
        <td>
          <span>
            <span style="color: green; font-size: 20px;">80%</span>
          </span>
        </td>
        <!-- <td>
          <span th:if="${attendancePeriodCalculationMapList != null}">-</span>
        </td> -->
        <td><span>-</span></td>
        <td>
          <a id="studentAttendanceDetilShow_1"
            onclick="javascript: callStudentAttendanceDetailDisplay(&#39;AP2026272&#39;,&#39;23BCE0001&#39;,&#39;AM_CSE3009_00200&#39;,&#39;ELA&#39;);"
            href="javascript:void(0);">
            <span title="Show" class="glyphicon glyphicon-eye-open"></span>
          </a>
        </td>
      </tr>
    </tbody>
  </table>
  <div class="text-center">
    <button type="button" class="btn btn-success"
      onclick="viewSDPAttendance()">View CAPSTONE/SDP Attendance</button>
  </div>
</div>
"#;

/// A trimmed attendance detail response for the theory row above.
///
/// VTOP sends two tables: a one-row course summary, then the day-by-day list.
/// The summary row has more than six cells, so only the table id keeps it out
/// of the result. The three rows cover each status VTOP uses, including an
/// absence carrying a remark.
const DETAIL_PAGE: &str = r#"
<div id="StudentAttendanceDetailFragment">
  <table id="StudentCourseDetailDataTable" class="table table-bordered responsive">
    <thead>
      <tr>
        <td><b>Class Group</b></td>
        <td><b>Course Detail</b></td>
        <td><b>Class Detail</b></td>
        <td><b>Faculty Detail</b></td>
        <td><b>Registered Date &amp; Time</b></td>
        <td><b>Attendance Date / Type</b></td>
        <td><b>Attendance Status</b></td>
        <td><b>Debar Status</b></td>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><span>General (Semester)</span></td>
        <td><span>CSE3009 - NoSQL Databases - Embedded Theory</span></td>
        <td><span>AP2026272000101 - C1+TCC1 - 430</span></td>
        <td><span>Test Faculty - SCOPE</span></td>
        <td><span>05-07-2026 09:38:13</span></td>
        <td><span>06-07-2026</span><span><span> / Manual</span></span></td>
        <td>
          <span>
            <span><b>Present :</b> 14</span><br/>
            <span><b>Absent :</b> 2</span><br/>
            <span><b>Attended :</b> 23</span><br/>
            <span><b>Total Class :</b> 25</span><br/>
          </span>
        </td>
        <td><span>-</span></td>
      </tr>
    </tbody>
  </table>
  <table id="StudentAttendanceDetailDataTable" class="table table-bordered table-hover responsive">
    <thead>
      <tr>
        <td>Sl.No.</td>
        <td>Date</td>
        <td>Slot</td>
        <td>Day / Time</td>
        <td>Status</td>
        <td>Remarks</td>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td align="center"><span>1</span></td>
        <td align="center"><span>24-09-2026</span></td>
        <td align="center"><span>C1</span></td>
        <td align="center"><span>THU / 09:00-09:50</span></td>
        <td align="center"><span><span>On Duty</span></span></td>
        <td><span></span></td>
      </tr>
      <tr>
        <td align="center"><span>2</span></td>
        <td align="center"><span>19-09-2026</span></td>
        <td align="center"><span>C1</span></td>
        <td align="center"><span>SAT / 10:00-10:50</span></td>
        <td align="center"><span><span>Present</span></span></td>
        <td><span></span></td>
      </tr>
      <tr>
        <td align="center"><span>3</span></td>
        <td align="center"><span>18-09-2026</span></td>
        <td align="center"><span>TCC1</span></td>
        <td align="center"><span>FRI / 08:00-08:50</span></td>
        <td align="center"><span><span style="color: red;">Absent</span></span></td>
        <td><span>No punch found during class hours between faculty punch.</span></td>
      </tr>
    </tbody>
  </table>
</div>
"#;

#[test]
fn test_parses_each_course_row() {
    let records = parse_attendance(ATTENDANCE_PAGE.to_string());

    assert_eq!(records.len(), 2);
    let theory = &records[0];
    assert_eq!(theory.course_code, "CSE3009");
    assert_eq!(theory.course_name, "NoSQL Databases");
    assert_eq!(theory.course_type, "Embedded Theory");
    assert_eq!(theory.class_number, "AP2026272000101");
    assert_eq!(theory.course_slot, "C1+TCC1");
    assert_eq!(theory.faculty, "Test Faculty - SCOPE");
    assert_eq!(theory.attended_classes, "23");
    assert_eq!(theory.total_classes, "25");
}

/// The detail request needs the course id and type code, and they only exist
/// inside the `onclick`. VTOP writes its quotes there as `&#39;`, so a regex
/// written against the source text rather than the parsed attribute would find
/// nothing, and every "view detail" tap would ask for an empty course.
#[test]
fn test_reads_course_id_and_type_code_from_the_detail_link() {
    let records = parse_attendance(ATTENDANCE_PAGE.to_string());

    assert_eq!(records[0].course_id, "AM_CSE3009_00200");
    assert_eq!(records[0].course_type_code, "ETH");
    assert_eq!(records[1].course_id, "AM_CSE3009_00200");
    assert_eq!(records[1].course_type_code, "ELA");
}

#[test]
fn test_percentage_sign_is_stripped() {
    let records = parse_attendance(ATTENDANCE_PAGE.to_string());

    assert_eq!(records[0].attendance_percentage, "92");
    assert_eq!(records[1].attendance_percentage, "80");
}

/// VTOP no longer serves the period percentage column (it survives only as an
/// HTML comment), so rows have ten cells. The parser must fall back to "0" for
/// that value and read debar status from the ninth cell.
#[test]
fn test_row_without_period_column_defaults_it_to_zero() {
    let records = parse_attendance(ATTENDANCE_PAGE.to_string());

    assert_eq!(records[0].debar_status, "-");
    assert_eq!(records[0].attendance_between_percentage, "0");
}

#[test]
fn test_page_with_no_course_rows_yields_nothing() {
    let header_only = ATTENDANCE_PAGE.split("<tbody>").next().unwrap().to_string()
        + "<tbody></tbody></table></div>";

    assert!(parse_attendance(header_only).is_empty());
}

#[test]
fn test_capstone_button_is_detected_on_the_real_page() {
    assert!(has_capstone_attendance(ATTENDANCE_PAGE));

    let without_button = ATTENDANCE_PAGE.replace("View CAPSTONE/SDP Attendance", "Refresh");
    assert!(!has_capstone_attendance(&without_button));
}

#[test]
fn test_detail_reads_only_the_day_by_day_table() {
    let records = parse_full_attendance(DETAIL_PAGE.to_string());

    assert_eq!(records.len(), 3);
    assert_eq!(records[0].serial, "1");
    assert_eq!(records[0].date, "24-09-2026");
    assert_eq!(records[0].slot, "C1");
    assert_eq!(records[0].day_time, "THU / 09:00-09:50");
    assert_eq!(records[0].status, "On Duty");
}

#[test]
fn test_detail_keeps_the_status_and_remark_of_an_absence() {
    let records = parse_full_attendance(DETAIL_PAGE.to_string());

    assert_eq!(records[1].status, "Present");
    assert_eq!(records[1].remark, "");
    assert_eq!(records[2].status, "Absent");
    assert_eq!(
        records[2].remark,
        "No punch found during class hours between faculty punch."
    );
}
