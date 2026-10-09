use crate::api::vtop::types::{GradeCourseHistory, GradeHistory};
use scraper::{Html, Selector};

/// Parses an HTML string containing a student's grade history and extracts summary and course details.
///
/// Returns a `GradeHistory` struct containing credits registered, credits earned, CGPA, and a vector of course details.
///
/// # Examples
///
/// ```
/// use lib_vtop::api::vtop::parser::grade_history_parser::parse_grade_history;
///
/// // A page with no CGPA table at all — a student in their first semester.
/// let grade_history = parse_grade_history("<html></html>".to_string());
///
/// assert_eq!(grade_history.cgpa, "N/A");
/// assert!(grade_history.courses.is_empty());
/// ```
pub fn parse_grade_history(html: String) -> GradeHistory {
    let doc = Html::parse_document(&html);

    // Parse CGPA summary table (Credits Registered, Credits Earned, CGPA)
    let mut credits_registered = String::from("N/A");
    let mut credits_earned = String::from("N/A");
    let mut cgpa = String::from("N/A");

    let cgpa_table_selector = Selector::parse("table.table.table-hover.table-bordered").unwrap();
    if let Some(table) = doc
        .select(&cgpa_table_selector)
        .find(|t| t.html().contains("CGPA"))
    {
        let row_selector = Selector::parse("tbody tr").unwrap();
        if let Some(row) = table.select(&row_selector).next() {
            let tds: Vec<_> = row.select(&Selector::parse("td").unwrap()).collect();
            if tds.len() >= 3 {
                credits_registered = tds[0].text().collect::<String>().trim().to_string();
                credits_earned = tds[1].text().collect::<String>().trim().to_string();
                cgpa = tds[2].text().collect::<String>().trim().to_string();
            }
        }
    }

    // Parse all course grade rows
    let mut courses = Vec::new();
    let course_table_selector = Selector::parse("table.customTable").unwrap();
    for table in doc.select(&course_table_selector) {
        // Only process tables with "Course Code" header
        if !table.html().contains("Course Code") {
            continue;
        }
        let row_selector = Selector::parse("tr.tableContent").unwrap();
        // Course table column indices
        const COURSE_CODE_COL: usize = 1;
        const COURSE_TITLE_COL: usize = 2;
        const COURSE_TYPE_COL: usize = 3;
        const CREDITS_COL: usize = 4;
        const GRADE_COL: usize = 5;
        const EXAM_MONTH_COL: usize = 6;
        const COURSE_DISTRIBUTION_COL: usize = 8;
        const MIN_COLUMNS: usize = 10;

        for row in table.select(&row_selector) {
            let tds: Vec<_> = row.select(&Selector::parse("td").unwrap()).collect();
            if tds.len() >= MIN_COLUMNS {
                let course_code = tds[COURSE_CODE_COL]
                    .text()
                    .collect::<String>()
                    .trim()
                    .to_string();
                // Skip header rows or rows with empty course code
                if course_code == "Course Code" || course_code.is_empty() {
                    continue;
                }
                let course_title = tds[COURSE_TITLE_COL]
                    .text()
                    .collect::<String>()
                    .trim()
                    .to_string();
                let course_type = tds[COURSE_TYPE_COL]
                    .text()
                    .collect::<String>()
                    .trim()
                    .to_string();
                let credits = tds[CREDITS_COL]
                    .text()
                    .collect::<String>()
                    .trim()
                    .to_string();
                let grade = tds[GRADE_COL].text().collect::<String>().trim().to_string();
                let exam_month = tds[EXAM_MONTH_COL]
                    .text()
                    .collect::<String>()
                    .trim()
                    .to_string();
                let course_distribution = tds[COURSE_DISTRIBUTION_COL]
                    .text()
                    .collect::<String>()
                    .trim()
                    .to_string();

                courses.push(GradeCourseHistory {
                    course_code,
                    course_title,
                    course_type,
                    credits,
                    grade,
                    exam_month,
                    course_distribution,
                });
            }
        }
    }

    GradeHistory {
        credits_registered,
        credits_earned,
        cgpa,
        courses,
    }
}
