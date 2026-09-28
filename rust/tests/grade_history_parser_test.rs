use lib_vtop::api::vtop::parser::grade_history_parser::parse_grade_history;

/// A trimmed grade history page: the student details table, three courses of
/// the "Effective Grades" table, and the CGPA summary.
///
/// What it preserves:
///   * the student details table is also a `table.customTable`, and must not be
///     read as courses;
///   * a course with a detail view is followed by a hidden `tr.tableContent`
///     holding a nested table of attempts that repeats the course code — it
///     must not be counted as another course;
///   * the last course has no detail button, just an empty tenth cell;
///   * the CGPA summary is a differently classed table further down.
///
/// Identity and grades are replaced.
const GRADE_HISTORY_PAGE: &str = r#"
<div id="main-section">
  <form role="form" id="studentGradeView" name="studentGradeView" method="post" autocomplete="off">
    <input type="hidden" name="authorizedID" id="authorizedID" value="23BCE0001" />
    <div align="center" id="fixedTableContainer" class="fixedTableContainer">
      <table class="customTable" style="align: center;">
        <tr class="tableHeader">
          <td>Reg.No.</td><td>Name</td><td>Programme and Branch</td>
          <td>Programme Mode</td><td>Study System</td><td>Gender</td>
          <td>YearJoined</td><td>Edu Status</td><td>School</td><td>Campus</td>
        </tr>
        <tr class="tableContent">
          <td>23BCE0001</td><td>TEST STUDENT</td>
          <td>B.Tech. - Computer Science and Engineering</td>
          <td>Regular</td><td>FFCS</td><td>OTHER</td><td>2023</td>
          <td>Admitted</td><td>SCOPE</td><td>AMR</td>
        </tr>
      </table>
    </div>
    <div align="center" id="fixedTableContainer" class="fixedTableContainer">
      <table class="customTable" style="align: center;">
        <tr class="tableHeader">
          <td colspan="11">Effective Grades
          </td>
        </tr>
        <tr class="tableHeader">
          <td>Sl.No.</td>
          <td>Course Code</td>
          <td>Course Title</td>
          <td>Course Type</td>
          <td>Credits</td>
          <td>Grade</td>
          <td>Exam Month</td>
          <td>Result Declared</td>
          <td>Course Distribution</td>
          <td>Detail View</td>
        </tr>
        <tr class="tableContent">
          <td class="textAlign-center">1</td>
          <td class="textAlign-center">CSE1012</td>
          <td>Problem Solving using Python</td>
          <td class="textAlign-center">ETL</td>
          <td class="textAlign-center">4.0</td>
          <td class="textAlign-center">A</td>
          <td class="textAlign-center">Jan-2024</td>
          <td class="textAlign-center">29-Mar-2024</td>
          <td class="textAlign-center">UC</td>
          <td class="textAlign-center">
            <button type="button" name="action"
              onclick="javascript:toggleDiv(&#39;CSE1012&#39;);"
              class="icon-button">
              <span class="glyphicon glyphicon-menu-down glyphiconDefault"></span>
            </button>
          </td>
        </tr>
        <tr class="tableContent" style="display: none;" id="detailsView_CSE1012">
          <td colspan="11" align="center">
            <div align="center">
              <table class="customTable-level1" style="align: center; width: 90%">
                <tr class="tableHeader-level1">
                  <td>Course Code</td><td>Course Title</td><td>Course Type</td>
                  <td>Credits</td><td>Grade</td><td>Exam Month</td>
                  <td>Result Declared</td>
                </tr>
                <tr class="tableContent-level1">
                  <td class="textAlign-center">CSE1012</td>
                  <td>Problem Solving using Python</td>
                  <td class="textAlign-center">ETL</td>
                  <td class="textAlign-center">4.0</td>
                  <td class="textAlign-center">A</td>
                  <td class="textAlign-center">Jan-2024</td>
                  <td class="textAlign-center">29-Mar-2024</td>
                </tr>
                <tr class="tableContent-level1">
                  <td class="textAlign-center">CSE1012</td>
                  <td>Problem Solving using Python</td>
                  <td class="textAlign-center">ETH</td>
                  <td class="textAlign-center"></td>
                  <td class="textAlign-center">-</td>
                  <td class="textAlign-center">Jan-2024</td>
                  <td class="textAlign-center">29-Mar-2024</td>
                </tr>
              </table>
            </div>
          </td>
        </tr>
        <tr class="tableContent">
          <td class="textAlign-center">2</td>
          <td class="textAlign-center">MAT1011</td>
          <td>Calculus for Engineers</td>
          <td class="textAlign-center">TH</td>
          <td class="textAlign-center">3.0</td>
          <td class="textAlign-center">B</td>
          <td class="textAlign-center">Jan-2024</td>
          <td class="textAlign-center">29-Mar-2024</td>
          <td class="textAlign-center">FC</td>
          <td class="textAlign-center">
            <button type="button" name="action"
              onclick="javascript:toggleDiv(&#39;MAT1011&#39;);"
              class="icon-button">
              <span class="glyphicon glyphicon-menu-down glyphiconDefault"></span>
            </button>
          </td>
        </tr>
        <tr class="tableContent" style="display: none;" id="detailsView_MAT1011">
          <td colspan="11" align="center">
            <div align="center">
              <table class="customTable-level1" style="align: center; width: 90%">
                <tr class="tableHeader-level1">
                  <td>Course Code</td><td>Course Title</td><td>Course Type</td>
                  <td>Credits</td><td>Grade</td><td>Exam Month</td>
                  <td>Result Declared</td>
                </tr>
                <tr class="tableContent-level1">
                  <td class="textAlign-center">MAT1011</td>
                  <td>Calculus for Engineers</td>
                  <td class="textAlign-center">TH</td>
                  <td class="textAlign-center">3.0</td>
                  <td class="textAlign-center">B</td>
                  <td class="textAlign-center">Jan-2024</td>
                  <td class="textAlign-center">29-Mar-2024</td>
                </tr>
              </table>
            </div>
          </td>
        </tr>
        <tr class="tableContent">
          <td class="textAlign-center">3</td>
          <td class="textAlign-center">STS4006</td>
          <td>Advanced Competitive Coding - II</td>
          <td class="textAlign-center">TH</td>
          <td class="textAlign-center">3.0</td>
          <td class="textAlign-center">S</td>
          <td class="textAlign-center">May-2026</td>
          <td class="textAlign-center">15-Jun-2026</td>
          <td class="textAlign-center">UE</td>
          <td class="textAlign-center">
          </td>
        </tr>
      </table>
    </div>
    <div class="box-body table-responsive ">
      <table class="table table-hover table-bordered">
        <thead style="background-color: #626D71">
          <tr>
            <td>Credits Registered</td><td>Credits Earned</td><td>CGPA</td>
            <td>S Grades</td><td>A Grades</td><td>B Grades</td><td>C Grades</td>
            <td>D Grades</td><td>E Grades</td><td>F Grades</td><td>N Grades</td>
          </tr>
        </thead>
        <tbody>
          <tr style="font-weight: bold;">
            <td>10.0</td><td>10.0</td><td>8.60</td>
            <td>1</td><td>1</td><td>1</td><td>0</td>
            <td>0</td><td>0</td><td>0</td><td>0</td>
          </tr>
        </tbody>
      </table>
    </div>
  </form>
</div>
"#;

#[test]
fn test_reads_the_cgpa_summary() {
    let history = parse_grade_history(GRADE_HISTORY_PAGE.to_string());

    assert_eq!(history.credits_registered, "10.0");
    assert_eq!(history.credits_earned, "10.0");
    assert_eq!(history.cgpa, "8.60");
}

/// Each course's detail view repeats its code in a nested table of attempts.
/// Counting those would list CSE1012 three times and inflate the credits the
/// app adds up.
#[test]
fn test_lists_each_course_once_despite_its_detail_view() {
    let history = parse_grade_history(GRADE_HISTORY_PAGE.to_string());
    let codes: Vec<_> = history
        .courses
        .iter()
        .map(|c| c.course_code.as_str())
        .collect();

    assert_eq!(codes, ["CSE1012", "MAT1011", "STS4006"]);
}

#[test]
fn test_reads_every_column_of_a_course() {
    let history = parse_grade_history(GRADE_HISTORY_PAGE.to_string());
    let course = &history.courses[0];

    assert_eq!(course.course_title, "Problem Solving using Python");
    assert_eq!(course.course_type, "ETL");
    assert_eq!(course.credits, "4.0");
    assert_eq!(course.grade, "A");
    assert_eq!(course.exam_month, "Jan-2024");
    assert_eq!(course.course_distribution, "UC");
}

#[test]
fn test_course_without_a_detail_button_is_still_read() {
    let history = parse_grade_history(GRADE_HISTORY_PAGE.to_string());
    let last = history.courses.last().unwrap();

    assert_eq!(last.course_code, "STS4006");
    assert_eq!(last.grade, "S");
    assert_eq!(last.course_distribution, "UE");
}

#[test]
fn test_student_details_table_is_not_read_as_a_course() {
    let history = parse_grade_history(GRADE_HISTORY_PAGE.to_string());

    assert!(history.courses.iter().all(|c| c.course_code != "23BCE0001"));
}

/// A student in their first semester has no CGPA table yet.
#[test]
fn test_missing_cgpa_table_reads_as_not_available() {
    let without_summary = GRADE_HISTORY_PAGE
        .split(r#"<div class="box-body table-responsive ">"#)
        .next()
        .unwrap()
        .to_string();

    let history = parse_grade_history(without_summary);

    assert_eq!(history.cgpa, "N/A");
    assert_eq!(history.credits_registered, "N/A");
    assert_eq!(history.credits_earned, "N/A");
    assert_eq!(history.courses.len(), 3);
}
