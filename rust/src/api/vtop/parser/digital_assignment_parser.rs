use super::super::types::*;
use regex::Regex;
use scraper::{Html, Selector};

pub fn parse_all_assignments(html: String) -> Vec<DigitalAssignments> {
    let document = Html::parse_document(&html);
    let rows_selector = Selector::parse("tr").unwrap();
    let mut all_assignments: Vec<DigitalAssignments> = Vec::new();

    for row in document.select(&rows_selector).skip(1) {
        let cells: Vec<_> = row.select(&Selector::parse("td").unwrap()).collect();
        if cells.len() == 7 {
            let serial_number = cells[0]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let class_id = cells[1]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let course_code = cells[2]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let course_title = cells[3]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let course_type = cells[4]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let faculty = cells[5]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let details: Vec<AssignmentRecordEach> = Vec::new(); // Details to be filled separately
            let assignment = DigitalAssignments {
                serial_number,
                class_id,
                course_code,
                course_title,
                course_type,
                faculty,
                details,
            };
            all_assignments.push(assignment);
        }
    }

    all_assignments
}

pub fn parse_per_course_dassignments(html: String) -> Vec<AssignmentRecordEach> {
    let mut course_assignments: Vec<AssignmentRecordEach> = Vec::new();
    let document = Html::parse_document(&html);
    let rows_selector = Selector::parse("tr").unwrap();
    for row in document.select(&rows_selector).skip(4) {
        let cells: Vec<_> = row.select(&Selector::parse("td").unwrap()).collect();
        if cells.len() == 9 {
            let serial_number = cells[0]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let assignment_title = cells[1]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let max_assignment_mark = cells[2]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let assignment_weightage_mark = cells[3]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let due_date = cells[4]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let can_qp_download = cells[5].inner_html().trim().contains("Download");
            let re_for_url = Regex::new(r"vtopDownload\('([^']+)'\)").unwrap();
            let qp_download_url;
            if can_qp_download {
                qp_download_url = cells[5]
                    .select(&Selector::parse("a").unwrap())
                    .next()
                    .and_then(|a| a.value().attr("href"))
                    .and_then(|href| {
                        re_for_url
                            .captures(href)
                            .and_then(|caps| caps.get(1))
                            .map(|m| m.as_str().to_string())
                    })
                    .unwrap_or_default();
            } else {
                qp_download_url = String::new();
            }
            let submission_status = cells[6]
                .text()
                .collect::<Vec<_>>()
                .join("")
                .trim()
                .replace("\t", "")
                .replace("\n", "");
            let can_update = cells[7].inner_html().trim().contains("pencil");
            let mcode;
            if can_update {
                mcode = cells[7]
                    .select(&Selector::parse("input").unwrap())
                    .find(|input| input.value().attr("name") == Some("code"))
                    .and_then(|input| input.value().attr("value"))
                    .unwrap_or("")
                    .to_string();
            } else {
                mcode = String::new();
            }
            let can_da_download = cells[8].inner_html().trim().contains("Download")
                && (!submission_status.eq("") && !submission_status.contains("File Not Uploaded"));
            let da_download_url;
            if can_da_download {
                da_download_url = cells[8]
                    .select(&Selector::parse("a").unwrap())
                    .next()
                    .and_then(|a| a.value().attr("href"))
                    .and_then(|href| {
                        re_for_url
                            .captures(href)
                            .and_then(|caps| caps.get(1))
                            .map(|m| m.as_str().to_string())
                    })
                    .unwrap_or_default();
            } else {
                da_download_url = String::new();
            }
            let record = AssignmentRecordEach {
                serial_number,
                assignment_title,
                max_assignment_mark,
                assignment_weightage_mark,
                due_date,
                can_qp_download,
                qp_download_url,
                submission_status,
                can_update,
                mcode,
                can_da_download,
                da_download_url,
            };
            course_assignments.push(record);
        }
    }
    course_assignments
}

pub fn parse_process_upload_assignment_response(html: String) -> Vec<Vec<String>> {
    let document = Html::parse_document(&html);
    let input_selector = Selector::parse("input").unwrap();
    let inputs: Vec<_> = document.select(&input_selector).collect();
    let mut code_vec: Vec<String> = Vec::new();
    let mut opt_vec: Vec<String> = Vec::new();
    for row in &inputs {
        if row.value().attr("name").unwrap_or("").to_string() == "code" {
            code_vec.push(row.value().attr("value").unwrap_or("").to_string());
        } else if row.value().attr("name").unwrap_or("").to_string() == "opt" {
            opt_vec.push(row.value().attr("value").unwrap_or("").to_string());
        }
    }
    vec![code_vec, opt_vec]
}

pub fn parse_upload_assignment_response(html: String) -> String {
    let document = Html::parse_document(&html);
    let span_selector = Selector::parse("span").unwrap();
    let spans: Vec<_> = document.select(&span_selector).collect();
    if spans.len() > 0
        && spans[0].text().collect::<Vec<_>>().join("") == "Uploaded successfully".to_string()
    {
        return spans[0].text().collect::<Vec<_>>().join("");
    } else if spans.len() > 0
        && spans[0]
            .text()
            .collect::<Vec<_>>()
            .join("")
            .ends_with("@vitapstudent.ac.in")
    {
        if spans.len() > 1
            && spans[1].text().collect::<Vec<_>>().join("").is_empty()
            && spans[2].text().collect::<Vec<_>>().join("").is_empty()
        {
            return "OTP Required".to_string();
        } else if spans.len() > 1
            && spans[2].text().collect::<Vec<_>>().join("")
                == "Invalid OTP. Please try again.".to_string()
        {
            return spans[2].text().collect::<Vec<_>>().join("");
        } else {
            return "Unknown error from OTP page try re-uploading.".to_string();
        }
    } else if spans.len() > 1 {
        return spans[1].text().collect::<Vec<_>>().join("");
    }
    return "Failed - Unknown Error".to_string();
}
