use crate::api::vtop::types::{GradeHistory, MentorDetails, StudentProfile};
use scraper::{Html, Selector};

/// Parses a student profile HTML page and returns a `StudentProfile` struct with extracted profile, mentor, and grade history details.
///
/// Extracts key student information, mentor (proctor) details, and the base64-encoded profile picture from the provided HTML.
/// Fields not present in the HTML are set to empty strings or `"N/A"` as appropriate.
///
/// # Examples
///
/// ```
/// let html = std::fs::read_to_string("student_profile.html").unwrap();
/// let profile = parse_student_profile(html);
/// assert!(!profile.student_name.is_empty());
/// ```
pub fn parse_student_profile(html: String) -> StudentProfile {
    let doc = Html::parse_document(&html);

    /// Searches for a table row whose first cell contains the specified label (case-insensitive) and returns the trimmed text of the second cell.
    ///
    /// Returns an empty string if no matching row is found.
    ///
    /// # Examples
    ///
    /// ```
    /// use scraper::{Html, Selector};
    /// let html = r#"
    ///     <table>
    ///         <tr><td>Student Name</td><td>Jane Doe</td></tr>
    ///         <tr><td>Email</td><td>jane@example.com</td></tr>
    ///     </table>
    /// "#;
    /// let doc = Html::parse_document(html);
    /// let value = extract_table_value(&doc, "Student Name");
    /// assert_eq!(value, "Jane Doe");
    /// ```
    fn extract_table_value(doc: &Html, label: &str) -> String {
        let selector = Selector::parse("tr").unwrap();
        let td_selector = Selector::parse("td").unwrap();
        for row in doc.select(&selector) {
            let mut tds = row.select(&td_selector);
            if let Some(label_td) = tds.next() {
                let label_text = label_td.text().collect::<String>().trim().to_uppercase();
                if label_text.contains(&label.to_uppercase()) {
                    if let Some(val_td) = tds.next() {
                        return val_td.text().collect::<String>().trim().to_string();
                    }
                }
            }
        }
        "".to_string()
    }

    /// Searches for a table row whose first cell contains the specified label (case-insensitive) and returns the trimmed text of the second cell.
    ///
    /// Returns an empty string if no matching row is found.
    ///
    /// # Examples
    ///
    /// ```
    /// use scraper::Html;
    /// let html = r#"
    ///     <table>
    ///         <tr><td>Faculty Name</td><td>Dr. Smith</td></tr>
    ///         <tr><td>Faculty Email</td><td>smith@example.com</td></tr>
    ///     </table>
    /// "#;
    /// let doc = Html::parse_fragment(html);
    /// let value = extract_table_value_any(&doc, "Faculty Name");
    /// assert_eq!(value, "Dr. Smith");
    /// ```
    fn extract_table_value_any(doc: &Html, label: &str) -> String {
        let selector = Selector::parse("tr").unwrap();
        for row in doc.select(&selector) {
            let tds: Vec<_> = row.select(&Selector::parse("td").unwrap()).collect();
            if tds.len() >= 2 {
                let label_text = tds[0].text().collect::<String>().trim().to_uppercase();
                if label_text.contains(&label.to_uppercase()) {
                    return tds[1].text().collect::<String>().trim().to_string();
                }
            }
        }
        "".to_string()
    }

    // Extract base64 profile picture
    let mut base64_pfp = String::new();
    let img_selector = Selector::parse("img.img.border.border-primary").unwrap();
    if let Some(img) = doc.select(&img_selector).next() {
        if let Some(src) = img.value().attr("src") {
            if let Some(idx) = src.find("base64,") {
                let start = idx + 7;
                if start < src.len() {
                    base64_pfp = src[start..].to_string();
                }
            }
        }
    }

    // Extract main profile fields
    let application_number = extract_table_value(&doc, "APPLICATION NUMBER");
    let student_name = extract_table_value(&doc, "STUDENT NAME");
    let dob = extract_table_value(&doc, "DATE OF BIRTH");
    let gender = extract_table_value(&doc, "GENDER");
    let blood_group = extract_table_value(&doc, "BLOOD GROUP");
    let email = extract_table_value(&doc, "EMAIL");

    // Mentor details (proctor)
    let mentor_section_selector = Selector::parse("div.accordion-item").unwrap();
    let mut mentor_html = None;
    for section in doc.select(&mentor_section_selector) {
        if section
            .html()
            .to_uppercase()
            .contains("PROCTOR INFORMATION")
        {
            mentor_html = Some(Html::parse_fragment(&section.html()));
            break;
        }
    }
    let mentor_doc = mentor_html.as_ref();

    let mentor = |label: &str| {
        if let Some(doc) = mentor_doc {
            extract_table_value_any(doc, label)
        } else {
            "".to_string()
        }
    };

    let mentor_details = MentorDetails {
        faculty_id: mentor("FACULTY ID"),
        faculty_name: mentor("FACULTY NAME"),
        faculty_designation: mentor("FACULTY DESIGNATION"),
        school: mentor("SCHOOL"),
        cabin: mentor("CABIN"),
        faculty_department: mentor("FACULTY DEPARTMENT"),
        faculty_email: mentor("FACULTY EMAIL"),
        faculty_intercom: mentor("FACULTY INTERCOM"),
        faculty_mobile_number: mentor("FACULTY MOBILE NUMBER"),
    };

    // Grade history (not present in this HTML, so fill with N/A)
    let grade_history = GradeHistory {
        credits_registered: "N/A".to_string(),
        credits_earned: "N/A".to_string(),
        cgpa: "N/A".to_string(),
        courses: Vec::new(),
    };

    StudentProfile {
        application_number,
        student_name,
        dob,
        gender,
        blood_group,
        email,
        base64_pfp,
        grade_history,
        mentor_details,
    }
}
