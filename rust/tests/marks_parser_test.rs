use lib_vtop::api::vtop::parser::marks_parser::parse_marks;

/// A trimmed Fall 2026-27 marks page.
///
/// VTOP lays marks out as pairs of `tr.tableContent` rows: a course row, then a
/// row holding a nested table of that course's assessments, each value wrapped
/// in `<output>`. The parser relies on that strict alternation. The first course
/// is from the real page; the second repeats its shape so the pairing is
/// exercised across more than one course. Identifying details are replaced.
const MARKS_PAGE: &str = r#"
<div id="main-section">
  <form role="form" id="studentMarkView" name="studentMarkView" method="post" autocomplete="off">
    <input type="hidden" name="authorizedID" id="authorizedID" value="23BCE0001" />
    <div id="fixedTableContainer" class="fixedTableContainer">
      <table class="customTable" style="align: center;">
        <tr class="tableHeader">
          <td>Sl.No.</td>
          <td>ClassNbr</td>
          <td>Course Code</td>
          <td>Course Title</td>
          <td>Course Type</td>
          <td>Course System</td>
          <td>Faculty</td>
          <td>Slot</td>
          <td>Course Mode</td>
        </tr>
        <tr class="tableContent" >
          <td>1</td>
          <td>AP2026272000101</td>
          <td>CSE3009</td>
          <td>NoSQL Databases</td>
          <td>Embedded Theory</td>
          <td>FFCS</td>
          <td>Test Faculty</td>
          <td>C1+TCC1</td>
          <td>CBL</td>
        </tr>
        <tr class="tableContent">
          <td colspan="9" align="center">
            <table class="customTable-level1" style="align: center;width: 80%;" >
              <tr class="tableHeader-level1">
                <td>Sl.No.</td>
                <td>Mark Title</td>
                <td>Max. Mark</td>
                <td>Weightage %</td>
                <td>Status</td>
                <td>Scored Mark</td>
                <td>Weightage Mark</td>
                <td>Remark</td>
              </tr>
              <tr class="tableContent-level1">
                <td><output>1</output></td>
                <td><output>CAT1</output></td>
                <td><output>50</output></td>
                <td><output>15</output></td>
                <td><output>Present</output></td>
                <td><output>40.0</output></td>
                <td><output>12.0</output></td>
                <td><output></output></td>
              </tr>
              <tr class="tableContent-level1">
                <td><output>2</output></td>
                <td><output>Digital Assessment-1</output></td>
                <td><output>20</output></td>
                <td><output>10</output></td>
                <td><output>Present</output></td>
                <td><output>18.0</output></td>
                <td><output>9.0</output></td>
                <td><output></output></td>
              </tr>
            </table>
          </td>
        </tr>
        <tr class="tableContent" >
          <td>2</td>
          <td>AP2026272000103</td>
          <td>MAT2002</td>
          <td>Applications of Differential and Difference Equations</td>
          <td>Theory Only</td>
          <td>FFCS</td>
          <td>Another Faculty</td>
          <td>A1+TA1</td>
          <td>CBL</td>
        </tr>
        <tr class="tableContent">
          <td colspan="9" align="center">
            <table class="customTable-level1" style="align: center;width: 80%;" >
              <tr class="tableHeader-level1">
                <td>Sl.No.</td>
                <td>Mark Title</td>
                <td>Max. Mark</td>
                <td>Weightage %</td>
                <td>Status</td>
                <td>Scored Mark</td>
                <td>Weightage Mark</td>
                <td>Remark</td>
              </tr>
              <tr class="tableContent-level1">
                <td><output>1</output></td>
                <td><output>CAT1</output></td>
                <td><output>50</output></td>
                <td><output>15</output></td>
                <td><output>Absent</output></td>
                <td><output>0.0</output></td>
                <td><output>0.0</output></td>
                <td><output>Medical</output></td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </div>
  </form>
</div>
"#;

#[test]
fn test_parses_each_course() {
    let courses = parse_marks(MARKS_PAGE.to_string());

    assert_eq!(courses.len(), 2);
    let course = &courses[0];
    assert_eq!(course.serial_number, "1");
    assert_eq!(course.course_code, "CSE3009");
    assert_eq!(course.course_title, "NoSQL Databases");
    assert_eq!(course.course_type, "Embedded Theory");
    assert_eq!(course.faculty, "Test Faculty");
    assert_eq!(course.slot, "C1+TCC1");
}

#[test]
fn test_reads_assessments_out_of_their_output_elements() {
    let courses = parse_marks(MARKS_PAGE.to_string());
    let details = &courses[0].details;

    assert_eq!(details.len(), 2);
    assert_eq!(details[0].serial_number, "1");
    assert_eq!(details[0].mark_title, "CAT1");
    assert_eq!(details[0].max_mark, "50");
    assert_eq!(details[0].weightage, "15");
    assert_eq!(details[0].status, "Present");
    assert_eq!(details[0].scored_mark, "40.0");
    assert_eq!(details[0].weightage_mark, "12.0");
    assert_eq!(details[0].remark, "");
    assert_eq!(details[1].mark_title, "Digital Assessment-1");
}

/// Courses and their assessments are paired purely by row order. If the
/// pairing slipped, the second course would show the first course's marks.
#[test]
fn test_each_course_gets_its_own_assessments() {
    let courses = parse_marks(MARKS_PAGE.to_string());

    assert_eq!(courses[1].course_code, "MAT2002");
    assert_eq!(courses[1].details.len(), 1);
    assert_eq!(courses[1].details[0].status, "Absent");
    assert_eq!(courses[1].details[0].remark, "Medical");
}

/// The assessment header row sits inside the nested table with its own class,
/// so it must not turn into an assessment called "Mark Title".
#[test]
fn test_assessment_header_is_not_an_assessment() {
    let courses = parse_marks(MARKS_PAGE.to_string());

    assert!(courses
        .iter()
        .flat_map(|c| &c.details)
        .all(|d| d.mark_title != "Mark Title"));
}

#[test]
fn test_semester_with_no_marks_yet_yields_nothing() {
    let header_only = r#"
    <table class="customTable">
      <tr class="tableHeader">
        <td>Sl.No.</td><td>ClassNbr</td><td>Course Code</td><td>Course Title</td>
        <td>Course Type</td><td>Course System</td><td>Faculty</td><td>Slot</td>
        <td>Course Mode</td>
      </tr>
    </table>
    "#;

    assert!(parse_marks(header_only.to_string()).is_empty());
}
