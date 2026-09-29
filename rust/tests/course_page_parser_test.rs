use lib_vtop::api::vtop::parser::course_page_parser::{
    parse_course_detail_page, parse_courses_for_course_page, parse_slots_for_course_page,
};

/// A trimmed course list response for Winter 2025-26.
///
/// The course dropdown comes back together with the still-empty slot and
/// faculty dropdowns, each with its own placeholder. One real title contains
/// VTOP's own " - " separator.
const COURSES: &str = r#"
<div id="getCourseForCoursePage">
  <select class="form-select" name ="courseCode" id="courseCode"
    onchange="javascript: getSlotIdForCoursePage(&#39;courseCode&#39;,&#39;getSlotIdForCoursePage&#39;,&#39;source&#39;);" >
    <option value="" selected="selected">--Choose Course --</option>
    <option value="AP2025264000388">CSE1008 - Theory of Computation - TH</option>
    <option value="AP2025264000495">CSE4004 - Web Technologies - ETH</option>
    <option value="AP2025264000558">CSE4004 - Web Technologies - ELA</option>
    <option value="AP2025264000114">STS4006 - Advanced Competitive Coding - II - TH</option>
  </select>
  <div id="getSlotIdForCoursePage">
    <select class="form-select" name="slotId" id="slotId">
      <option value="" selected="selected" >-- Choose Slot --</option>
    </select>
    <div id="getFacultyForCoursePage">
      <select class="form-select" name="faculty" id="faculty">
        <option value="" selected="selected" >-- Choose Faculty --</option>
      </select>
    </div>
  </div>
</div>
"#;

/// A trimmed slot response for CSE1008: the whole page again, so the semester
/// and course dropdowns come back too, then the slot dropdown and a table of
/// every class of the course. Each row's View button passes the semester, the
/// faculty's employee id and the class id, quoted as `&#39;`. Faculty are
/// replaced.
const SLOTS: &str = r#"
<form class="form-horizontal" method="post" id="StudentCoursePage" name="StudentCoursePage" autocomplete="off">
  <input type="hidden" name="authorizedID" id="authorizedID" value="23BCE0001" />
  <select class="form-select" name="semesterSubId" id="semesterSubId">
    <option value="" selected="selected">-- Choose Semester --</option>
    <option value="AP2026272">Fall Semester 2026-27</option>
    <option value="AP2025264" selected="selected">Winter Semester 2025-26</option>
  </select>
  <select class="form-select" name ="courseCode" id="courseCode">
    <option value="">--Choose Course --</option>
    <option value="AP2025264000388" selected="selected">CSE1008 - Theory of Computation - TH</option>
    <option value="AP2025264000495">CSE4004 - Web Technologies - ETH</option>
  </select>
  <select class="form-select" name="slotId" id="slotId"
    onchange="javascript: getFacultyForCoursePage(&#39;courseCode&#39;,&#39;slotId&#39;,&#39;getFacultyForCoursePage&#39;,&#39;source&#39;);" >
    <option value="" selected="selected" >-- Choose Slot --</option>
    <option value="3637">A1+TA1+TAA1</option>
    <option value="3700">A2+TA2+TAA2</option>
    <option value="3701">B1+TB1+TBB1</option>
    <option value="3702">B2+TB2+TBB2</option>
  </select>
  <select class="form-select" name="faculty" id="faculty">
    <option value="" selected="selected" >-- Choose Faculty --</option>
  </select>
  <table>
    <tr Style="background-color: #3c8dbc; color: #fff;">
      <td><b>Sl.No.</b></td>
      <td><b>Class Group</b></td>
      <td><b>Course Code</b></td>
      <td><b>Course Title</b></td>
      <td><b>Course Type</b></td>
      <td><b>Class Id</b></td>
      <td><b>Slot</b></td>
      <td><b>Faculty</b></td>
      <td><b>Action</b></td>
    </tr>
    <tr>
      <td>1</td>
      <td>General (Semester)</td>
      <td>CSE1008</td>
      <td>Theory of Computation</td>
      <td>Theory Only</td>
      <td>AP2025264000449</td>
      <td>A1/TA1/TAA1</td>
      <td>70001 - Test Faculty - SCOPE</td>
      <td>
        <button style="padding:3px 12px;" class="btn btn-primary" type="button"
          onclick="javascript: processViewStudentCourseDetail(&#39;AP2025264&#39;,&#39;70001&#39;,&#39;AP2025264000449&#39;);">View</button>
      </td>
    </tr>
    <tr>
      <td>2</td>
      <td>General (Semester)</td>
      <td>CSE1008</td>
      <td>Theory of Computation</td>
      <td>Theory Only</td>
      <td>AP2025264000438</td>
      <td>B2/TB2/TBB2</td>
      <td>70002 - Another Faculty - SCOPE</td>
      <td>
        <button style="padding:3px 12px;" class="btn btn-primary" type="button"
          onclick="javascript: processViewStudentCourseDetail(&#39;AP2025264&#39;,&#39;70002&#39;,&#39;AP2025264000438&#39;);">View</button>
      </td>
    </tr>
  </table>
</form>
"#;

/// A trimmed course detail page. Hidden inputs carry the class, semester and
/// course ids; three buttons at the top link the bulk and syllabus downloads;
/// the first table describes the class; the second lists lectures, each date
/// given twice (the second in brackets) and each with zero or more reference
/// materials. Every download is `javascript:vtopDownload(&#39;…&#39;)`. Three
/// lectures of the real 59 are kept: none, one and three materials.
const DETAIL: &str = r#"
<form id="CoursePageDetail">
  <input type="hidden" name="authorizedID" id="authorizedID" value="23BCE0001" />
  <input type="hidden" name="message" id="message" value="" />
  <input type="hidden" name="classId" id="classId"
    value="AP2025264000421" />
  <input type="hidden" name="semesterSubId" id="semesterSubId"
    value="AP2025264" />
  <input type="hidden" name="courseId" id="courseId"
    value="AM_CSE1008_00200" />
  <input type="hidden" name="courseType" id="courseType"
    value="TH" />
  <table class="table">
    <tr>
      <td><b>Class Group</b></td>
      <td><b>Course Code</b></td>
      <td><b>Course Title</b></td>
      <td><b>Course Type</b></td>
      <td><b>Class Id</b></td>
      <td><b>Slot</b></td>
      <td><b>Faculty</b></td>
    </tr>
    <tr>
      <td>General (Semester)</td>
      <td>CSE1008</td>
      <td>Theory of Computation</td>
      <td>Theory Only</td>
      <td>AP2025264000421</td>
      <td>A1+TA1+TAA1</td>
      <td>70003 - Third Faculty - SCOPE</td>
    </tr>
  </table>
  <a class="btn btn-md btn-primary btn-block" id="btn"
    href="javascript:vtopDownload(&#39;academics/common/allCourseMeterialDownload/1/1/AP2025264/AP2025264000421&#39;)">Download All Reference Materials</a>
  <a class="btn btn-md btn-primary btn-block" id="btn"
    href="javascript:vtopDownload(&#39;academics/common/allCourseMeterialDownload/2/1/AP2025264/AP2025264000421&#39;)">Download General Materials</a>
  <a class="btn btn-primary"
    href="javascript:vtopDownload(&#39;courseSyllabusDownload/AM_CSE1008_00200/TH&#39;)">Download Syllabus</a>
  <table class="table">
    <tr>
      <td><b>Sl.No.</b></td>
      <td><b>Lecture Date</b></td>
      <td><b>Lecture Day</b></td>
      <td><b>Lecture Topic</b></td>
      <td><b>Reference Material</b></td>
    </tr>
    <tr>
      <td>1</td>
      <td>
        <span>09-12-2025</span><br/>
        <span>[09-Dec-2025]</span>
      </td>
      <td >TUE</td>
      <td>Mathematical preliminaries and notations</td>
      <td>
      </td>
    </tr>
    <tr>
      <td>2</td>
      <td>
        <span>11-12-2025</span><br/>
        <span>[11-Dec-2025]</span>
      </td>
      <td >THU</td>
      <td>Zero Hour Class - Syllabus, COs, POs, CO-PO mapping</td>
      <td>
        <p>
          <a class="btn btn-link"
            href="javascript:vtopDownload(&#39;downloadPdf/AP2025264/AP2025264000421/19/11-12-2025&#39;)">
            <span>Reference Material I</span>
          </a>
        </p>
      </td>
    </tr>
    <tr>
      <td>3</td>
      <td>
        <span>12-12-2025</span><br/>
        <span>[12-Dec-2025]</span>
      </td>
      <td >FRI</td>
      <td>Module - 1 Mathematical preliminaries and notations</td>
      <td>
        <p>
          <a class="btn btn-link"
            href="javascript:vtopDownload(&#39;downloadPdf/AP2025264/AP2025264000421/19/12-12-2025&#39;)">
            <span>Reference Material I</span>
          </a>
        </p>
        <p>
          <a class="btn btn-link"
            href="javascript:vtopDownload(&#39;downloadPdf/AP2025264/AP2025264000421/20/12-12-2025&#39;)">
            <span>Reference Material II</span>
          </a>
        </p>
        <p>
          <a class="btn btn-link"
            href="javascript:vtopDownload(&#39;downloadPdf/AP2025264/AP2025264000421/21/12-12-2025&#39;)">
            <span>Reference Material III</span>
          </a>
        </p>
      </td>
    </tr>
  </table>
</form>
"#;

#[test]
fn test_courses_skip_the_placeholder() {
    let courses = parse_courses_for_course_page(COURSES.to_string()).courses;

    assert_eq!(courses.len(), 4);
    assert!(courses.iter().all(|c| !c.value.is_empty()));
}

#[test]
fn test_courses_split_code_title_and_type() {
    let courses = parse_courses_for_course_page(COURSES.to_string()).courses;

    assert_eq!(courses[0].value, "AP2025264000388");
    assert_eq!(courses[0].label, "CSE1008 - Theory of Computation - TH");
    assert_eq!(courses[0].course_code, "CSE1008");
    assert_eq!(courses[0].course_title, "Theory of Computation");
    assert_eq!(courses[0].course_type, "TH");
    assert_eq!(courses[2].course_type, "ELA");
}

/// The label separator also appears inside titles. Splitting naively would
/// cut "Advanced Competitive Coding - II" short and take "II" as its type.
#[test]
fn test_courses_keep_a_title_that_contains_the_separator() {
    let courses = parse_courses_for_course_page(COURSES.to_string()).courses;

    assert_eq!(courses[3].course_code, "STS4006");
    assert_eq!(courses[3].course_title, "Advanced Competitive Coding - II");
    assert_eq!(courses[3].course_type, "TH");
}

/// The slot response repeats the semester and course dropdowns. Only the slot
/// dropdown's options are slots.
#[test]
fn test_slots_come_only_from_the_slot_dropdown() {
    let slots = parse_slots_for_course_page(SLOTS.to_string(), "AP2025264").slots;

    let labels: Vec<_> = slots.iter().map(|s| s.label.as_str()).collect();
    assert_eq!(
        labels,
        ["A1+TA1+TAA1", "A2+TA2+TAA2", "B1+TB1+TBB1", "B2+TB2+TBB2"]
    );
    assert_eq!(slots[0].value, "3637");
}

#[test]
fn test_slots_read_every_class_of_the_course() {
    let entries = parse_slots_for_course_page(SLOTS.to_string(), "AP2025264").class_entries;

    assert_eq!(entries.len(), 2);
    let first = &entries[0];
    assert_eq!(first.sl_no, 1);
    assert_eq!(first.class_group, "General (Semester)");
    assert_eq!(first.course_code, "CSE1008");
    assert_eq!(first.course_title, "Theory of Computation");
    assert_eq!(first.course_type, "Theory Only");
    assert_eq!(first.class_id, "AP2025264000449");
    assert_eq!(first.slot, "A1/TA1/TAA1");
    assert_eq!(first.faculty, "70001 - Test Faculty - SCOPE");
    assert_eq!(first.semester_id, "AP2025264");
}

/// The detail request needs the faculty's employee id, which only exists as
/// the second argument of the View button's `onclick`.
#[test]
fn test_slots_read_the_employee_id_from_the_view_button() {
    let entries = parse_slots_for_course_page(SLOTS.to_string(), "AP2025264").class_entries;

    assert_eq!(entries[0].erp_id, "70001");
    assert_eq!(entries[1].erp_id, "70002");
}

#[test]
fn test_detail_reads_the_class_from_the_first_table() {
    let detail = parse_course_detail_page(DETAIL.to_string());
    let info = &detail.course_info;

    assert_eq!(info.class_group, "General (Semester)");
    assert_eq!(info.course_code, "CSE1008");
    assert_eq!(info.course_title, "Theory of Computation");
    assert_eq!(info.course_type, "Theory Only");
    assert_eq!(info.class_id, "AP2025264000421");
    assert_eq!(info.slot, "A1+TA1+TAA1");
    assert_eq!(info.faculty, "70003 - Third Faculty - SCOPE");
}

#[test]
fn test_detail_reads_ids_from_the_hidden_inputs() {
    let detail = parse_course_detail_page(DETAIL.to_string());

    assert_eq!(detail.semester_id, "AP2025264");
    assert_eq!(detail.course_info.course_id, "AM_CSE1008_00200");
}

#[test]
fn test_detail_reads_the_download_paths() {
    let detail = parse_course_detail_page(DETAIL.to_string());

    assert_eq!(
        detail.download_all_path.as_deref(),
        Some("academics/common/allCourseMeterialDownload/1/1/AP2025264/AP2025264000421")
    );
    assert_eq!(
        detail.download_general_materials_path.as_deref(),
        Some("academics/common/allCourseMeterialDownload/2/1/AP2025264/AP2025264000421")
    );
    assert_eq!(
        detail.syllabus_download_path.as_deref(),
        Some("courseSyllabusDownload/AM_CSE1008_00200/TH")
    );
    assert_eq!(
        detail.course_plan_download_path.as_deref(),
        Some("academics/common/CoursePlanExcelDownload?semesterSubId=AP2025264&classId=AP2025264000421")
    );
}

#[test]
fn test_detail_reads_each_lecture() {
    let lectures = parse_course_detail_page(DETAIL.to_string()).lectures;

    assert_eq!(lectures.len(), 3);
    assert_eq!(lectures[0].sl_no, 1);
    assert_eq!(lectures[0].date, "09-12-2025");
    assert_eq!(lectures[0].formatted_date, "09-Dec-2025");
    assert_eq!(lectures[0].day, "TUE");
    assert_eq!(
        lectures[0].topic,
        "Mathematical preliminaries and notations"
    );
}

#[test]
fn test_detail_reads_every_reference_material_of_a_lecture() {
    let lectures = parse_course_detail_page(DETAIL.to_string()).lectures;

    assert!(lectures[0].reference_materials.is_empty());
    assert_eq!(lectures[1].reference_materials.len(), 1);

    let materials = &lectures[2].reference_materials;
    assert_eq!(materials.len(), 3);
    assert_eq!(materials[0].label, "Reference Material I");
    assert_eq!(
        materials[0].download_path,
        "downloadPdf/AP2025264/AP2025264000421/19/12-12-2025"
    );
    assert_eq!(materials[2].label, "Reference Material III");
    assert_eq!(
        materials[2].download_path,
        "downloadPdf/AP2025264/AP2025264000421/21/12-12-2025"
    );
}

/// The class table comes first on the page, and must not be read as lectures.
#[test]
fn test_detail_without_a_lecture_table_has_no_lectures() {
    let without_lectures = DETAIL
        .split("<a class=\"btn btn-md btn-primary btn-block\"")
        .next()
        .unwrap()
        .to_string()
        + "</form>";

    let detail = parse_course_detail_page(without_lectures);

    assert!(detail.lectures.is_empty());
    assert_eq!(detail.course_info.course_code, "CSE1008");
    assert_eq!(detail.download_all_path, None);
}
