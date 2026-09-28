use lib_vtop::api::vtop::parser::faculty::parseabout::parse_faculty_data;
use lib_vtop::api::vtop::parser::faculty::parsesearch::{
    parse_all_faculty_search, parse_faculty_search,
};

/// A trimmed faculty search result. Each row ends in a button whose `id` is
/// the employee number, also passed (with `&quot;` quotes) to its `onclick`.
/// The header row uses `td`, like the data rows. Names and numbers are
/// replaced.
const SEARCH_RESULTS: &str = r#"
<div class="tab-content clearfix">
  <div class="tab-pane active" id="4a">
    <table class="table" border="1">
      <tr style="text-align: center; border-style: solid;">
        <td>Name of the Faculty</td>
        <td>Designation</td>
        <td>School / Centre</td>
        <td>Action</td>
      </tr>
      <tr style="text-align: center; border-style: solid;">
        <td>Dr. Test Faculty</td>
        <td>Associate Professor Senior</td>
        <td>VIT-AP School of Business</td>
        <td>
          <button type="button" class="btn btn-primary" value="select" id="70001" onclick="getEmployeeIdNo(&quot;70001&quot;);">
            <span class="glyphicon glyphicon-ok"></span>
          </button>
        </td>
      </tr>
      <tr style="text-align: center; border-style: solid;">
        <td>Dr. Another Faculty</td>
        <td>Assistant Professor Sr. Grade-2</td>
        <td>School of Computer Science &amp; Engineering</td>
        <td>
          <button type="button" class="btn btn-primary" value="select" id="70002" onclick="getEmployeeIdNo(&quot;70002&quot;);">
            <span class="glyphicon glyphicon-ok"></span>
          </button>
        </td>
      </tr>
    </table>
  </div>
</div>
"#;

/// A trimmed faculty profile: the details table, whose second row carries a
/// third cell holding the photo (`rowspan`, base64 elided), and the open hours
/// table with its two header rows. Name, email and cabin are replaced.
const PROFILE: &str = r#"
<div class="" id="showDetails">
  <div class="table-responsive">
    <table class="table table-bordered" >
      <tr>
        <td><b>Name of the Faculty </b></td>
        <td style="font-weight: bold;">Dr. Test Faculty</td>
        <td></td>
      </tr>
      <tr >
        <td><b>Designation</b></td>
        <td>Associate Professor Senior</td>
        <td rowspan="10">
          <img src="data:JPEG;base64,/9j/4AAQ" alt="Image Not Available" width="150" height="180"/>
        </td>
      </tr>
      <tr>
        <td><b>Name of Department</b></td>
        <td>Department of Business School</td>
      </tr>
      <tr>
        <td><b>School / Centre Name </b></td>
        <td >VIT-AP School of Business</td>
      </tr>
      <tr>
        <td><b>E-Mail Id </b></td>
        <td >test.faculty@example.edu</td>
      </tr>
      <tr>
        <td><b> Cabin Number </b></td>
        <td >AB1-000</td>
      </tr>
    </table>
    <div>
      <table class="table table-bordered">
        <thead>
          <tr role="row">
            <th colspan="8">OPEN HOURS</th>
          </tr>
          <tr role="row">
            <th colspan="1"><b> Week Day</b></th>
            <th colspan="2"><b>Timings</b></th>
          </tr>
        </thead>
        <tbody>
          <tr role="row" class="odd">
            <td colspan="1">WEDNESDAY</td>
            <td colspan="2" >11:00 AM - 01:00 PM</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</div>
"#;

#[test]
fn test_search_reads_every_result_row() {
    let results = parse_all_faculty_search(SEARCH_RESULTS.to_string());

    assert_eq!(results.len(), 2);
    assert_eq!(results[0].faculty_name, "Dr. Test Faculty");
    assert_eq!(results[0].designation, "Associate Professor Senior");
    assert_eq!(results[0].school_or_centre, "VIT-AP School of Business");
    assert_eq!(results[0].emp_id, "70001");
    assert_eq!(
        results[1].school_or_centre,
        "School of Computer Science & Engineering"
    );
    assert_eq!(results[1].emp_id, "70002");
}

/// The header row has four cells too; only the missing button keeps it out.
#[test]
fn test_search_header_row_is_not_a_result() {
    let results = parse_all_faculty_search(SEARCH_RESULTS.to_string());

    assert!(results
        .iter()
        .all(|r| r.faculty_name != "Name of the Faculty"));
}

/// Without the `id` attribute the employee number is still in the `onclick`.
#[test]
fn test_search_falls_back_to_the_onclick_for_the_employee_number() {
    let without_ids = SEARCH_RESULTS
        .replace(r#" id="70001""#, "")
        .replace(r#" id="70002""#, "");

    let results = parse_all_faculty_search(without_ids);

    assert_eq!(results[0].emp_id, "70001");
    assert_eq!(results[1].emp_id, "70002");
}

#[test]
fn test_single_search_takes_the_first_result() {
    assert_eq!(
        parse_faculty_search(SEARCH_RESULTS.to_string()).emp_id,
        "70001"
    );
}

#[test]
fn test_search_with_no_matches_yields_nothing() {
    let header_only = r#"
    <table class="table" border="1">
      <tr>
        <td>Name of the Faculty</td><td>Designation</td>
        <td>School / Centre</td><td>Action</td>
      </tr>
    </table>
    "#;

    assert!(parse_all_faculty_search(header_only.to_string()).is_empty());
    assert_eq!(parse_faculty_search(header_only.to_string()).emp_id, "");
}

#[test]
fn test_profile_reads_the_details_table() {
    let details = parse_faculty_data(PROFILE.to_string());

    assert_eq!(details.name, "Dr. Test Faculty");
    assert_eq!(details.designation, "Associate Professor Senior");
    assert_eq!(details.department, "Department of Business School");
    assert_eq!(details.school_centre, "VIT-AP School of Business");
    assert_eq!(details.email, "test.faculty@example.edu");
    assert_eq!(details.cabin_number, "AB1-000");
}

/// The open hours table opens with a title row and a column header row; only
/// the day rows below them are office hours.
#[test]
fn test_profile_reads_only_the_open_hours_rows() {
    let details = parse_faculty_data(PROFILE.to_string());

    assert_eq!(details.office_hours.len(), 1);
    assert_eq!(details.office_hours[0].day, "WEDNESDAY");
    assert_eq!(details.office_hours[0].timings, "11:00 AM - 01:00 PM");
}
