use crate::api::vtop::types::course_page::*;
use scraper::{Html, Selector};

/// Parses the courses dropdown from the course page HTML response
pub fn parse_courses_for_course_page(html: String) -> CoursesResponse {
    let document = Html::parse_document(&html);
    let mut courses = Vec::new();

    // Select option elements within the courseCode select
    let select_selector =
        Selector::parse("select#courseCode option, select[name='courseCode'] option")
            .unwrap_or_else(|_| Selector::parse("option").unwrap());

    for option in document.select(&select_selector) {
        let value = option.value().attr("value").unwrap_or("").to_string();
        let label = option.text().collect::<String>().trim().to_string();

        // Skip the placeholder option
        if value.is_empty() || label.starts_with("--") || label.starts_with("-- ") {
            continue;
        }

        // Parse the label to extract course code, title, and type
        // Format: "CSE2009 - Soft Computing - ETH"
        let parts: Vec<&str> = label.split(" - ").collect();
        let (course_code, course_title, course_type) = if parts.len() >= 3 {
            (
                parts[0].trim().to_string(),
                parts[1..parts.len() - 1].join(" - ").trim().to_string(),
                parts[parts.len() - 1].trim().to_string(),
            )
        } else if parts.len() == 2 {
            (
                parts[0].trim().to_string(),
                parts[1].trim().to_string(),
                String::new(),
            )
        } else {
            (label.clone(), String::new(), String::new())
        };

        courses.push(CourseOption {
            value,
            label,
            course_code,
            course_title,
            course_type,
        });
    }

    CoursesResponse { courses }
}

/// Parses the slots and class entries from the slot selection response
pub fn parse_slots_for_course_page(html: String, semester_id: &str) -> SlotsResponse {
    let document = Html::parse_document(&html);
    let mut slots = Vec::new();
    let mut class_entries = Vec::new();

    // Parse slot options
    let slot_selector = Selector::parse("select#slotId option, select[name='slotId'] option")
        .unwrap_or_else(|_| Selector::parse("option").unwrap());

    for option in document.select(&slot_selector) {
        let value = option.value().attr("value").unwrap_or("").to_string();
        let label = option.text().collect::<String>().trim().to_string();

        // Skip the placeholder option
        if value.is_empty() || label.starts_with("--") || label.starts_with("-- ") {
            continue;
        }

        slots.push(SlotOption { value, label });
    }

    // Parse class entries from the table
    let table_selector = Selector::parse("table").unwrap();
    let row_selector = Selector::parse("tr").unwrap();
    let cell_selector = Selector::parse("td").unwrap();
    let button_selector = Selector::parse("button").unwrap();

    for table in document.select(&table_selector) {
        let rows: Vec<_> = table.select(&row_selector).collect();

        // Skip header row
        for row in rows.iter().skip(1) {
            let cells: Vec<_> = row.select(&cell_selector).collect();

            if cells.len() >= 9 {
                // Extract data from cells
                let sl_no = cells[0]
                    .text()
                    .collect::<String>()
                    .trim()
                    .parse::<i32>()
                    .unwrap_or(0);
                let class_group = cells[1].text().collect::<String>().trim().to_string();
                let course_code = cells[2].text().collect::<String>().trim().to_string();
                let course_title = cells[3].text().collect::<String>().trim().to_string();
                let course_type = cells[4].text().collect::<String>().trim().to_string();
                let class_id = cells[5].text().collect::<String>().trim().to_string();
                let slot = cells[6].text().collect::<String>().trim().to_string();
                let faculty = cells[7].text().collect::<String>().trim().to_string();

                // Extract erp_id from the button onclick attribute
                let mut erp_id = String::new();
                if let Some(button) = cells[8].select(&button_selector).next() {
                    if let Some(onclick) = button.value().attr("onclick") {
                        // Parse: processViewStudentCourseDetail('AP2025264','70735','AP2025264000442')
                        if let Some(erp) = parse_erp_id_from_onclick(onclick) {
                            erp_id = erp;
                        }
                    }
                }

                if sl_no > 0 {
                    class_entries.push(CourseClassEntry {
                        sl_no,
                        class_group,
                        course_code,
                        course_title,
                        course_type,
                        class_id: class_id.clone(),
                        slot,
                        faculty,
                        semester_id: semester_id.to_string(),
                        erp_id,
                    });
                }
            }
        }
    }

    SlotsResponse {
        slots,
        class_entries,
    }
}

/// Parses the detailed course page with all lectures and materials
pub fn parse_course_detail_page(html: String) -> CoursePageDetail {
    let document = Html::parse_document(&html);

    // Extract course info from the first table
    let course_info = extract_course_info(&document);

    // Extract semester_id and class_id from hidden inputs
    let semester_id = extract_hidden_input_value(&document, "semesterSubId");
    let class_id = extract_hidden_input_value(&document, "classId");
    let course_id = extract_hidden_input_value(&document, "courseId");

    // Update course_info with course_id
    let mut course_info = course_info;
    course_info.course_id = course_id;

    // Extract download paths
    let download_all_path = extract_download_path(&document, "allCourseMeterialDownload/1/1");
    let download_general_materials_path =
        extract_download_path(&document, "allCourseMeterialDownload/2/1");
    let syllabus_download_path = extract_download_path(&document, "courseSyllabusDownload");

    // Build course plan download path
    let course_plan_download_path = if !semester_id.is_empty() && !class_id.is_empty() {
        Some(format!(
            "academics/common/CoursePlanExcelDownload?semesterSubId={}&classId={}",
            semester_id, class_id
        ))
    } else {
        None
    };

    // Extract lectures
    let lectures = extract_lectures(&document);

    CoursePageDetail {
        course_info,
        semester_id,
        download_all_path,
        download_general_materials_path,
        syllabus_download_path,
        course_plan_download_path,
        lectures,
    }
}

/// Extracts course information from the first table
fn extract_course_info(document: &Html) -> CourseInfo {
    let table_selector = Selector::parse("table").unwrap();
    let row_selector = Selector::parse("tr").unwrap();
    let cell_selector = Selector::parse("td").unwrap();

    let mut course_info = CourseInfo {
        class_group: String::new(),
        course_code: String::new(),
        course_title: String::new(),
        course_type: String::new(),
        class_id: String::new(),
        slot: String::new(),
        faculty: String::new(),
        course_id: String::new(),
    };

    // Find the first table with course info
    if let Some(table) = document.select(&table_selector).next() {
        let rows: Vec<_> = table.select(&row_selector).collect();

        // Find the data row (skip header)
        for row in rows.iter().skip(1) {
            let cells: Vec<_> = row.select(&cell_selector).collect();

            if cells.len() >= 7 {
                course_info.class_group = cells[0].text().collect::<String>().trim().to_string();
                course_info.course_code = cells[1].text().collect::<String>().trim().to_string();
                course_info.course_title = cells[2].text().collect::<String>().trim().to_string();
                course_info.course_type = cells[3].text().collect::<String>().trim().to_string();
                course_info.class_id = cells[4].text().collect::<String>().trim().to_string();
                course_info.slot = cells[5].text().collect::<String>().trim().to_string();
                course_info.faculty = cells[6].text().collect::<String>().trim().to_string();
                break;
            }
        }
    }

    course_info
}

/// Extracts hidden input value by name
fn extract_hidden_input_value(document: &Html, name: &str) -> String {
    let selector = Selector::parse(&format!("input[name='{}'], input#{}", name, name)).unwrap();

    document
        .select(&selector)
        .next()
        .and_then(|input| input.value().attr("value"))
        .unwrap_or("")
        .to_string()
}

/// Extracts download path from href containing the specified pattern
fn extract_download_path(document: &Html, pattern: &str) -> Option<String> {
    let link_selector =
        Selector::parse("a[href*='vtopDownload'], a[onclick*='vtopDownload']").unwrap();

    for link in document.select(&link_selector) {
        // Check href attribute
        if let Some(href) = link.value().attr("href") {
            if href.contains(pattern) {
                // Extract path from javascript:vtopDownload('...')
                if let Some(path) = extract_path_from_vtop_download(href) {
                    return Some(path);
                }
            }
        }

        // Check onclick attribute
        if let Some(onclick) = link.value().attr("onclick") {
            if onclick.contains(pattern) {
                if let Some(path) = extract_path_from_vtop_download(onclick) {
                    return Some(path);
                }
            }
        }
    }

    None
}

/// Extracts lectures from the lecture table
fn extract_lectures(document: &Html) -> Vec<LectureEntry> {
    let mut lectures = Vec::new();
    let table_selector = Selector::parse("table").unwrap();
    let row_selector = Selector::parse("tr").unwrap();
    let cell_selector = Selector::parse("td").unwrap();
    let link_selector = Selector::parse("a").unwrap();
    let span_selector = Selector::parse("span").unwrap();

    // Find the table with lectures (it has columns: Sl.No., Lecture Date, Lecture Day, Lecture Topic, Reference Material)
    for table in document.select(&table_selector) {
        let rows: Vec<_> = table.select(&row_selector).collect();

        // Check if this is the lecture table by examining headers
        if rows.is_empty() {
            continue;
        }

        let header_text = rows[0].text().collect::<String>();
        if !header_text.contains("Lecture Date") && !header_text.contains("Lecture Topic") {
            continue;
        }

        // Process lecture rows
        for row in rows.iter().skip(1) {
            let cells: Vec<_> = row.select(&cell_selector).collect();

            if cells.len() >= 5 {
                let sl_no = cells[0]
                    .text()
                    .collect::<String>()
                    .trim()
                    .parse::<i32>()
                    .unwrap_or(0);

                // Extract date - there are two spans inside
                let date;
                let formatted_date;
                let spans: Vec<_> = cells[1].select(&span_selector).collect();
                if spans.len() >= 2 {
                    date = spans[0].text().collect::<String>().trim().to_string();
                    formatted_date = spans[1]
                        .text()
                        .collect::<String>()
                        .trim()
                        .trim_start_matches('[')
                        .trim_end_matches(']')
                        .to_string();
                } else if !spans.is_empty() {
                    date = spans[0].text().collect::<String>().trim().to_string();
                    formatted_date = date.clone();
                } else {
                    date = cells[1].text().collect::<String>().trim().to_string();
                    formatted_date = date.clone();
                }

                let day = cells[2].text().collect::<String>().trim().to_string();
                let topic = cells[3].text().collect::<String>().trim().to_string();

                // Extract reference materials
                let mut reference_materials = Vec::new();
                for link in cells[4].select(&link_selector) {
                    if let Some(href) = link.value().attr("href") {
                        if href.contains("vtopDownload") {
                            let label = link.text().collect::<String>().trim().to_string();
                            if let Some(download_path) = extract_path_from_vtop_download(href) {
                                reference_materials.push(ReferenceMaterial {
                                    label,
                                    download_path,
                                });
                            }
                        }
                    }
                }

                if sl_no > 0 {
                    lectures.push(LectureEntry {
                        sl_no,
                        date,
                        formatted_date,
                        day,
                        topic,
                        reference_materials,
                    });
                }
            }
        }

        // Found the lecture table, no need to continue
        if !lectures.is_empty() {
            break;
        }
    }

    lectures
}

/// Parses ERP ID from onclick handler: processViewStudentCourseDetail('AP2025264','70735','AP2025264000442')
fn parse_erp_id_from_onclick(onclick: &str) -> Option<String> {
    // Find the function call and extract parameters
    if onclick.contains("processViewStudentCourseDetail") {
        // Extract content between parentheses
        let start = onclick.find('(')?;
        let end = onclick.rfind(')')?;
        let params = &onclick[start + 1..end];

        // Split by comma and extract the second parameter (erp_id)
        let parts: Vec<&str> = params.split(',').collect();
        if parts.len() >= 2 {
            return Some(
                parts[1]
                    .trim()
                    .trim_matches('\'')
                    .trim_matches('&')
                    .trim_matches('#')
                    .trim_matches(';')
                    .to_string(),
            );
        }
    }
    None
}

/// Extracts path from vtopDownload JavaScript call
fn extract_path_from_vtop_download(href: &str) -> Option<String> {
    // Format: javascript:vtopDownload('path/here')
    // or: vtopDownload('path/here')

    // Handle HTML entity encoding &#39; for single quotes
    let cleaned = href.replace("&#39;", "'");

    let start = cleaned.find("vtopDownload(")?;
    let path_start = cleaned[start..].find('\'')? + start + 1;
    let path_end = cleaned[path_start..].find('\'')? + path_start;

    Some(cleaned[path_start..path_end].to_string())
}
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_path_from_vtop_download() {
        let href = "javascript:vtopDownload('downloadPdf/AP2025264/AP2025264000442/19/10-12-2025')";
        assert_eq!(
            extract_path_from_vtop_download(href),
            Some("downloadPdf/AP2025264/AP2025264000442/19/10-12-2025".to_string())
        );
    }

    #[test]
    fn test_parse_erp_id_from_onclick() {
        let onclick = "javascript: processViewStudentCourseDetail(&#39;AP2025264&#39;,&#39;70735&#39;,&#39;AP2025264000442&#39;);";
        // Note: The HTML entities need to be handled
        let cleaned = onclick.replace("&#39;", "'");
        assert!(cleaned.contains("70735"));
    }
}
