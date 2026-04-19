use crate::api::vtop::types::*;
use scraper::{Html, Selector};

pub fn parse_hostel_leave(html: String) -> Vec<GeneralOutingRecord> {
    let document = Html::parse_document(&html);
    let table_selector = Selector::parse("table#BookingRequests").unwrap();
    let row_selector = Selector::parse("tr").unwrap();
    let cell_selector = Selector::parse("td").unwrap();

    let mut records = Vec::new();

    if let Some(table) = document.select(&table_selector).next() {
        // Skip header row and process data rows
        for row in table.select(&row_selector).skip(1) {
            let cells: Vec<_> = row.select(&cell_selector).collect();

            // Need at least 11 columns based on actual HTML structure
            if cells.len() >= 11 {
                // Helper function to extract and clean text
                let extract_text = |index: usize| -> String {
                    cells[index]
                        .text()
                        .collect::<Vec<_>>()
                        .join("")
                        .trim()
                        .replace("\t", "")
                        .replace("\n", " ")
                        .trim()
                        .to_string()
                };

                // Status is at index 9 in the actual HTML structure
                let status_text = extract_text(9);

                // Extract leave_id from download link's data-url attribute
                let download_selector = Selector::parse("a[data-url]").unwrap();
                let (can_download, leave_id) =
                    if let Some(download_link) = cells[10].select(&download_selector).next() {
                        if let Some(data_url) = download_link.value().attr("data-url") {
                            // Extract ID from URL like "/vtop/hostel/downloadLeavePass/L2234920"
                            let id = data_url.split('/').last().unwrap_or("").to_string();
                            (true, id)
                        } else {
                            (false, String::new())
                        }
                    } else {
                        (false, String::new())
                    };

                let record = GeneralOutingRecord {
                    serial: extract_text(0),
                    registration_number: extract_text(1),
                    place_of_visit: extract_text(2),
                    purpose_of_visit: extract_text(3),
                    from_date: extract_text(4),
                    from_time: extract_text(5),
                    to_date: extract_text(6),
                    to_time: extract_text(7),
                    status: status_text,
                    can_download,
                    leave_id,
                };

                records.push(record);
            }
        }
    }

    records
}
