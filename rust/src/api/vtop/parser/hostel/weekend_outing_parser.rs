use crate::api::vtop::types::*;
use scraper::{Html, Selector};

pub fn parse_weekend_outing(html: String) -> Vec<WeekendOutingRecord> {
    let document = Html::parse_document(&html);
    let table_selector = Selector::parse("table#BookingRequests").unwrap();
    let row_selector = Selector::parse("tr").unwrap();
    let cell_selector = Selector::parse("td").unwrap();

    let mut records = Vec::new();

    if let Some(table) = document.select(&table_selector).next() {
        // Skip header row and process data rows
        for row in table.select(&row_selector).skip(1) {
            let cells: Vec<_> = row.select(&cell_selector).collect();

            // Helper function to extract and clean text
            let extract_text = |index: usize| -> String {
                if index < cells.len() {
                    cells[index]
                        .text()
                        .collect::<Vec<_>>()
                        .join("")
                        .trim()
                        .replace("\t", "")
                        .replace("\n", " ")
                        .trim()
                        .to_string()
                } else {
                    String::new()
                }
            };

            // Detect if this is weekend format (14 columns) or weekday format (11 columns)
            let is_weekend_format = cells.len() >= 14;

            if cells.len() >= 11 {
                let (
                    contact_number,
                    parent_contact_number,
                    date_idx,
                    booking_id_idx,
                    status_idx,
                    download_idx,
                ) = if is_weekend_format {
                    // Weekend format: Contact Number (7), Parent Contact Number (8), Date (9), Booking Id (10), Status (12), Download (13)
                    (extract_text(7), extract_text(8), 9, 10, 12, 13)
                } else {
                    // Weekday format: Date (7), Status (9), Download (10)
                    (String::new(), String::new(), 7, 0, 9, 10)
                };

                let status_text = extract_text(status_idx);

                // Extract booking_id from download link's data-leave-url attribute or from cell text
                let download_selector = Selector::parse("a[data-leave-url]").unwrap();
                let booking_id = if is_weekend_format {
                    // In weekend format, booking_id is in a separate column
                    let booking_id_text = extract_text(booking_id_idx);
                    if !booking_id_text.is_empty() {
                        booking_id_text
                    } else if let Some(download_link) =
                        cells[download_idx].select(&download_selector).next()
                    {
                        if let Some(data_url) = download_link.value().attr("data-leave-url") {
                            data_url.split('/').last().unwrap_or("").to_string()
                        } else {
                            String::new()
                        }
                    } else {
                        String::new()
                    }
                } else if let Some(download_link) =
                    cells[download_idx].select(&download_selector).next()
                {
                    if let Some(data_url) = download_link.value().attr("data-leave-url") {
                        // Extract ID from URL like "/vtop/hostel/downloadOutingForm/W23235307220"
                        data_url.split('/').last().unwrap_or("").to_string()
                    } else {
                        String::new()
                    }
                } else {
                    String::new()
                };

                // Check if download is available (booking_id exists and status is accepted)
                let can_download = !booking_id.is_empty()
                    && status_text.to_lowercase().trim() == "outing request accepted";

                let record = WeekendOutingRecord {
                    serial: extract_text(0),
                    registration_number: extract_text(1),
                    hostel_block: extract_text(2),
                    room_number: extract_text(3),
                    place_of_visit: extract_text(4),
                    purpose_of_visit: extract_text(5),
                    time: extract_text(6),
                    contact_number,
                    parent_contact_number,
                    date: extract_text(date_idx),
                    booking_id,
                    status: status_text,
                    can_download,
                };

                records.push(record);
            }
        }
    }

    records
}
