use crate::api::vtop::types::GetFaculty;
use scraper::{Html, Selector};

fn extract_emp_id_from_row(row: &scraper::ElementRef) -> String {
    let button_selector = Selector::parse("button").unwrap();
    if let Some(button) = row.select(&button_selector).next() {
        // Prefer the `id` attribute on the button (e.g. id="70447")
        if let Some(id) = button.value().attr("id") {
            if !id.is_empty() {
                return id.to_string();
            }
        }
        if let Some(onclick) = button.value().attr("onclick") {
            // Handle both &quot; and regular " variants
            if onclick.contains("&quot;") {
                return onclick.split("&quot;").nth(1).unwrap_or("").to_string();
            } else if onclick.contains('"') {
                return onclick.split('"').nth(1).unwrap_or("").to_string();
            } else {
                // Fallback: extract digits
                return onclick
                    .chars()
                    .filter(|c| c.is_ascii_digit())
                    .collect::<String>();
            }
        }
    }
    String::new()
}

fn clean(text: String) -> String {
    text.trim().replace('\t', "").replace('\n', "")
}

/// Parse the first matching faculty from a search-by-name/id response.
/// Used by the existing single-search flow.
pub fn parse_faculty_search(html: String) -> GetFaculty {
    parse_all_faculty_search(html)
        .into_iter()
        .next()
        .unwrap_or_else(|| GetFaculty {
            faculty_name: String::new(),
            designation: String::new(),
            school_or_centre: String::new(),
            emp_id: String::new(),
        })
}

/// Parse every row from the faculty-list response (e.g. empId=*).
/// Returns one `GetFaculty` per data row, skipping the header row.
pub fn parse_all_faculty_search(html: String) -> Vec<GetFaculty> {
    let document = Html::parse_document(&html);
    let rows_selector = Selector::parse("tr").unwrap();
    let td_selector = Selector::parse("td").unwrap();
    let mut results = Vec::new();

    // Skip the first <tr> which is the header row
    for row in document.select(&rows_selector).skip(1) {
        let cells: Vec<_> = row.select(&td_selector).collect();
        if cells.len() < 4 {
            continue;
        }
        let emp_id = extract_emp_id_from_row(&row);
        if emp_id.is_empty() {
            continue; // skip rows without a valid employee button
        }
        results.push(GetFaculty {
            faculty_name: clean(cells[0].text().collect::<Vec<_>>().join("")),
            designation: clean(cells[1].text().collect::<Vec<_>>().join("")),
            school_or_centre: clean(cells[2].text().collect::<Vec<_>>().join("")),
            emp_id,
        });
    }
    results
}
