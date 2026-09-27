use crate::api::vtop::types::grade_view::*;
use regex::Regex;
use scraper::{ElementRef, Html, Selector};

const GRADE_LABELS: [&str; 7] = ["S", "A", "B", "C", "D", "E", "F"];

/// Collapses the heavy tab/newline whitespace VTOP pads cells with.
fn clean(element: &ElementRef) -> String {
    element
        .text()
        .collect::<String>()
        .split_whitespace()
        .collect::<Vec<_>>()
        .join(" ")
}

fn is_numeric(value: &str) -> bool {
    !value.is_empty() && value.parse::<f64>().is_ok()
}

/// Finds the innermost table containing `marker`.
///
/// The detail response injects the stats and marks tables inside a cell of the
/// outer grade table, so a plain "table containing X" search matches the
/// wrapper. Restricting to leaf tables (no nested table) selects the real one.
fn find_leaf_table<'a>(doc: &'a Html, marker: &str) -> Option<ElementRef<'a>> {
    let table_selector = Selector::parse("table").unwrap();
    doc.select(&table_selector).find(|table| {
        table.select(&table_selector).next().is_none()
            && table.text().collect::<String>().contains(marker)
    })
}

/// Parses the per-course grade list from a `doStudentGradeView` response.
///
/// # Examples
///
/// ```
/// let html = r#"
/// <table class="table table-hover table-bordered">
///   <tr><th>Sl.No.</th><th>Course Code</th><th>Course Title</th><th>Course Type</th>
///       <th>Grading Type</th><th>Grand Total</th><th>Grade</th><th>View Mark</th></tr>
///   <tr>
///     <td>1</td><td>CSE1008</td><td>Theory of Computation</td><td>Theory Only</td>
///     <td>RG</td><td>63</td><td>B</td>
///     <td><button onclick="javascript:getGradeViewDetails('AM_CSE1008_00200');">+</button></td>
///   </tr>
/// </table>
/// "#.to_string();
/// let courses = lib_vtop::api::vtop::parser::grade_view_parser::parse_grade_view(html);
/// assert_eq!(courses.len(), 1);
/// assert_eq!(courses[0].course_code, "CSE1008");
/// assert_eq!(courses[0].grade, "B");
/// assert_eq!(courses[0].course_id, "AM_CSE1008_00200");
/// ```
pub fn parse_grade_view(html: String) -> Vec<GradeViewCourse> {
    let document = Html::parse_document(&html);
    let mut courses = Vec::new();

    let table_selector = Selector::parse("table").unwrap();
    let row_selector = Selector::parse("tr").unwrap();
    let td_selector = Selector::parse("td").unwrap();
    let course_id_re = Regex::new(r"getGradeViewDetails\(\s*'([^']+)'\s*\)").unwrap();

    // The grade list is the table carrying a "View Mark" column.
    let table = match document
        .select(&table_selector)
        .find(|t| t.text().collect::<String>().contains("View Mark"))
    {
        Some(t) => t,
        None => return courses,
    };

    for row in table.select(&row_selector) {
        let cells: Vec<_> = row.select(&td_selector).collect();
        if cells.len() < 8 {
            continue;
        }

        let serial = clean(&cells[0]);
        // A real row always leads with a numeric serial; skip headers/spacers.
        if serial.parse::<u32>().is_err() {
            continue;
        }

        let view_cell_html = cells[7].html().replace("&#39;", "'");
        let course_id = course_id_re
            .captures(&view_cell_html)
            .and_then(|c| c.get(1))
            .map(|m| m.as_str().to_string())
            .unwrap_or_default();

        courses.push(GradeViewCourse {
            serial_number: serial,
            course_code: clean(&cells[1]),
            course_title: clean(&cells[2]),
            course_type: clean(&cells[3]),
            grading_type: clean(&cells[4]),
            grand_total: clean(&cells[5]),
            grade: clean(&cells[6]),
            course_id,
        });
    }

    courses
}

fn parse_statistics(document: &Html) -> GradeStatistics {
    let mut stats = GradeStatistics {
        class_strength: String::new(),
        grading_strength: String::new(),
        mean: String::new(),
        sd: String::new(),
        grade_ranges: Vec::new(),
    };

    let table = match find_leaf_table(document, "Range of Grades") {
        Some(t) => t,
        None => return stats,
    };

    let row_selector = Selector::parse("tr").unwrap();
    let cell_selector = Selector::parse("td, th").unwrap();

    // The meaningful row holds class strength, grading strength, mean, SD and
    // one range per grade. It is the row whose first cell is numeric.
    let values = table.select(&row_selector).find_map(|row| {
        let cells: Vec<String> = row.select(&cell_selector).map(|c| clean(&c)).collect();
        if cells.len() >= 4 && is_numeric(&cells[0]) {
            Some(cells)
        } else {
            None
        }
    });

    if let Some(values) = values {
        stats.class_strength = values.first().cloned().unwrap_or_default();
        stats.grading_strength = values.get(1).cloned().unwrap_or_default();
        stats.mean = values.get(2).cloned().unwrap_or_default();
        stats.sd = values.get(3).cloned().unwrap_or_default();
        for (label, range) in GRADE_LABELS.iter().zip(values.iter().skip(4)) {
            stats.grade_ranges.push(GradeRange {
                grade: label.to_string(),
                range: range.clone(),
            });
        }
    }

    stats
}

/// Parses the mark breakdown and class statistics from a `getGradeViewDetails`
/// response.
pub fn parse_grade_view_detail(html: String) -> GradeViewDetail {
    let document = Html::parse_document(&html);

    let mut detail = GradeViewDetail {
        class_number: String::new(),
        course_type: String::new(),
        marks: Vec::new(),
        total: String::new(),
        statistics: parse_statistics(&document),
    };

    let table = match find_leaf_table(&document, "Mark Title") {
        Some(t) => t,
        None => return detail,
    };

    let row_selector = Selector::parse("tr").unwrap();
    let cell_selector = Selector::parse("td, th").unwrap();

    for row in table.select(&row_selector) {
        let cells: Vec<String> = row.select(&cell_selector).map(|c| clean(&c)).collect();
        if cells.is_empty() {
            continue;
        }

        let joined = cells.join(" ");

        // Title row: "Class Number : ...", "Course Type : ...".
        if joined.contains("Class Number") && detail.class_number.is_empty() {
            for cell in &cells {
                if cell.starts_with("Class Number") {
                    detail.class_number = cell
                        .split_once(':')
                        .map(|x| x.1)
                        .unwrap_or("")
                        .trim()
                        .to_string();
                } else if cell.starts_with("Course Type") {
                    detail.course_type = cell
                        .split_once(':')
                        .map(|x| x.1)
                        .unwrap_or("")
                        .trim()
                        .to_string();
                }
            }
            continue;
        }

        // Total row.
        if cells[0].eq_ignore_ascii_case("total") {
            detail.total = cells.get(1).cloned().unwrap_or_default();
            continue;
        }

        // A mark component always leads with a numeric serial.
        if cells.len() >= 7 && cells[0].parse::<u32>().is_ok() {
            detail.marks.push(MarkComponent {
                serial_number: cells[0].clone(),
                mark_title: cells[1].clone(),
                max_mark: cells[2].clone(),
                weightage: cells[3].clone(),
                status: cells[4].clone(),
                scored_mark: cells[5].clone(),
                weightage_mark: cells[6].clone(),
            });
        }
    }

    detail
}
