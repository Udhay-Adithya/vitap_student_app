use lib_vtop::api::vtop::parser::profile_parser::parse_student_profile;

/// VTOP renders multi-word text with a newline and a run of tabs between the
/// words, so a label cell reads `APPLICATION\r\n\t\t\t\tNUMBER`. It does not do
/// this consistently — the same page has been observed served both ways — so
/// the parser has to handle either.
///
/// Kept inline so the test carries no external fixture, and no real student
/// data. The values below are invented.
fn split_label_page() -> String {
    "<!DOCTYPE html><html><body>
  <table>
    <tr><td>APPLICATION\r\n\t\t\t\t\t\t\t\tNUMBER</td><td>2023000000</td></tr>
    <tr><td>STUDENT\r\n\t\t\t\t\t\t\t\tNAME</td><td>A Student</td></tr>
    <tr><td>DATE OF\r\n\t\t\t\t\t\t\t\tBIRTH</td><td>01-JAN-2005</td></tr>
    <tr><td>GENDER</td><td>Male</td></tr>
    <tr><td>BLOOD\r\n\t\t\t\t\t\t\t\tGROUP</td><td>O+</td></tr>
    <tr><td>EMAIL</td><td>student@example.com</td></tr>
  </table>
  <div class=\"accordion-item\">
    <strong>PROCTOR\r\n\t\t\t\t\t\t\t\tINFORMATION</strong>
    <table>
      <tr><td>FACULTY\r\n\t\t\t\t\t\t\t\tID</td><td>70000</td></tr>
      <tr><td>FACULTY\r\n\t\t\t\t\t\t\t\tNAME</td><td>A Faculty</td></tr>
      <tr><td>FACULTY\r\n\t\t\t\t\t\t\t\tEMAIL</td><td>faculty@vitap.ac.in</td></tr>
      <tr><td>SCHOOL</td><td>SCOPE</td></tr>
      <tr><td>CABIN</td><td>AB1-101</td></tr>
    </table>
  </div>
</body></html>"
        .to_string()
}

/// The same page with every label on one line, which is how VTOP served it
/// before. Both shapes have to keep working.
fn single_line_page() -> String {
    split_label_page().replace("\r\n\t\t\t\t\t\t\t\t", " ")
}

#[test]
fn split_labels_are_matched() {
    let p = parse_student_profile(split_label_page());
    assert_eq!(p.application_number, "2023000000");
    assert_eq!(p.student_name, "A Student");
    assert_eq!(p.dob, "01-JAN-2005");
    assert_eq!(p.gender, "Male");
    assert_eq!(p.blood_group, "O+");
    assert_eq!(p.email, "student@example.com");
}

#[test]
fn single_line_labels_still_work() {
    let p = parse_student_profile(single_line_page());
    assert_eq!(p.application_number, "2023000000");
    assert_eq!(p.student_name, "A Student");
    assert_eq!(p.dob, "01-JAN-2005");
    assert_eq!(p.blood_group, "O+");
}

/// The section heading is split too. Matching it against the raw html found
/// nothing, so `mentor_html` stayed `None` and every mentor field came back
/// empty regardless of its own label.
#[test]
fn the_proctor_section_is_found_when_its_heading_is_split() {
    let p = parse_student_profile(split_label_page());
    assert_eq!(p.mentor_details.faculty_id, "70000");
    assert_eq!(p.mentor_details.faculty_name, "A Faculty");
    assert_eq!(p.mentor_details.faculty_email, "faculty@vitap.ac.in");
    assert_eq!(p.mentor_details.school, "SCOPE");
    assert_eq!(p.mentor_details.cabin, "AB1-101");
}

/// `EMAIL` used to be matched with `contains`, so a `FACULTY EMAIL` cell also
/// matched it and whichever came first in the document won.
#[test]
fn a_faculty_email_is_not_mistaken_for_the_students() {
    let html = "<html><body><table>
        <tr><td>FACULTY EMAIL</td><td>faculty@vitap.ac.in</td></tr>
        <tr><td>EMAIL</td><td>student@example.com</td></tr>
      </table></body></html>"
        .to_string();
    assert_eq!(parse_student_profile(html).email, "student@example.com");
}

#[test]
fn a_missing_field_is_empty_rather_than_wrong() {
    let html = "<html><body><table>
        <tr><td>GENDER</td><td>Male</td></tr>
      </table></body></html>"
        .to_string();
    let p = parse_student_profile(html);
    assert_eq!(p.gender, "Male");
    assert!(p.student_name.is_empty());
    assert!(p.blood_group.is_empty());
}

#[test]
fn a_page_with_no_proctor_section_leaves_mentor_details_empty() {
    let html = "<html><body><table>
        <tr><td>GENDER</td><td>Male</td></tr>
      </table></body></html>"
        .to_string();
    assert!(parse_student_profile(html)
        .mentor_details
        .faculty_id
        .is_empty());
}
