use crate::api::vtop::types::GetFaculty;
use scraper::{Html, Selector};

pub fn parse_faculty_search(html: String) -> GetFaculty {
    let document = Html::parse_document(&html);
    let rows_selector = Selector::parse("tr").unwrap();

    // Skip header row and find the data row
    for row in document.select(&rows_selector).skip(1) {
        let cells: Vec<_> = row.select(&Selector::parse("td").unwrap()).collect();
        if cells.len() >= 4 {
            // Extract employee ID from button onclick attribute
            let button_selector = Selector::parse("button").unwrap();
            let emp_id = if let Some(button) = row.select(&button_selector).next() {
                if let Some(onclick) = button.value().attr("onclick") {
                    // Extract ID from onclick - handle both &quot; and regular quotes
                    let extracted_id = if onclick.contains("&quot;") {
                        onclick.split("&quot;").nth(1).unwrap_or("").to_string()
                    } else if onclick.contains('"') {
                        // Handle regular quotes: getEmployeeIdNo("30058");
                        onclick.split('"').nth(1).unwrap_or("").to_string()
                    } else {
                        // Fallback: extract numbers from the string
                        onclick
                            .chars()
                            .filter(|c| c.is_ascii_digit())
                            .collect::<String>()
                    };
                    // println!("Extracted emp_id from onclick: {}, ID: {}", onclick, extracted_id);
                    extracted_id
                } else if let Some(id) = button.value().attr("id") {
                    id.to_string()
                } else {
                    String::new()
                }
            } else {
                String::new()
            };

            return GetFaculty {
                faculty_name: cells[0]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", ""),
                designation: cells[1]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", ""),
                school_or_centre: cells[2]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", ""),
                emp_id,
            };
        }
    }

    // Return empty faculty if no data found
    GetFaculty {
        faculty_name: String::new(),
        designation: String::new(),
        school_or_centre: String::new(),
        emp_id: String::new(),
    }
}
