use super::super::types::*;
use scraper::{ElementRef, Html, Selector};

pub fn parse_marks(html: String) -> Vec<Marks> {
    let document = Html::parse_document(&html);
    let mut courses: Vec<Marks> = Vec::new();

    let mut course = Marks {
        serial_number: "".to_string(),
        course_code: "".to_string(),
        course_title: "".to_string(),
        course_type: "".to_string(),
        faculty: "".to_string(),
        slot: "".to_string(),
        details: vec![],
    };

    fn extract_text(el: Option<&ElementRef>) -> String {
        el.map(|e| e.text().collect::<Vec<_>>().join(""))
            .unwrap_or_default()
            .trim()
            .replace(['\t', '\n'], "")
    }

    let mut bmarks = false;
    for row in document.select(&Selector::parse("tr.tableContent").unwrap()) {
        let cells: Vec<_> = row.select(&Selector::parse("td").unwrap()).collect();
        if bmarks {
            let marks_el: Vec<_> = cells[0]
                .select(&Selector::parse("tr.tableContent-level1").unwrap())
                .collect();
            let mut marks_vec: Vec<MarksRecordEach> = vec![];
            for i in marks_el {
                let mk: Vec<_> = i.select(&Selector::parse("td").unwrap()).collect();
                let mut marksiter = mk.iter();
                let marks = MarksRecordEach {
                    serial_number: extract_text(marksiter.next()),
                    mark_title: extract_text(marksiter.next()),
                    max_mark: extract_text(marksiter.next()),
                    weightage: extract_text(marksiter.next()),
                    status: extract_text(marksiter.next()),
                    scored_mark: extract_text(marksiter.next()),
                    weightage_mark: extract_text(marksiter.next()),
                    remark: extract_text(marksiter.next()),
                };
                marks_vec.push(marks);
            }
            course.details = marks_vec;

            courses.push(course.clone());
            course = Marks {
                serial_number: "".to_string(),
                course_code: "".to_string(),
                course_title: "".to_string(),
                course_type: "".to_string(),
                faculty: "".to_string(),
                slot: "".to_string(),
                details: vec![],
            };
        } else {
            course = Marks {
                serial_number: cells[0]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", ""),
                course_code: cells[2]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", ""),
                course_title: cells[3]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", ""),
                course_type: cells[4]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", ""),
                faculty: cells[6]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", ""),
                slot: cells[7]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", ""),
                details: vec![],
            }
        }

        bmarks = !bmarks
    }
    courses
}
