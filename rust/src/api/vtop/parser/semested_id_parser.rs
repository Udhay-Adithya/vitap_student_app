use scraper::{Html, Selector};
use std::time::{Duration, SystemTime, UNIX_EPOCH};

use super::super::types::*;

pub fn parse_semid_from_timetable(html: String) -> SemesterData {
    let mut sem_names_ids = vec![];
    let document = Html::parse_document(&html);
    let selector = Selector::parse(r#"select[name="semesterSubId"] option"#).unwrap();
    for element in document.select(&selector).skip(1) {
        if let Some(value) = element.value().attr("value") {
            if let Some(name) = element.text().next() {
                sem_names_ids.push(SemesterInfo {
                    id: value.trim().to_string(),
                    name: name.trim().replace("- AMR", "").to_string(),
                });
            }
        }
    }
    SemesterData {
        semesters: sem_names_ids,
        update_time: SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or(Duration::new(1, 0))
            .as_secs(),
    }
}
