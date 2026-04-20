use scraper::{Html, Selector};
use serde;
use std::collections::HashMap;

use super::super::types::*;

pub fn parse_timetable(html: String) -> Timetable {
    parse_timetable_direct(html)
}

fn parse_timetable_direct(html: String) -> Timetable {
    #[derive(serde::Serialize, serde::Deserialize)]
    struct Timing {
        serial: String,
        start_time: String,
        end_time: String,
    }

    #[derive(Debug, Clone)]
    struct RawSlot {
        serial: String,
        day: String,
        slot: String,
        course_code: String,
        course_type: String,
        room_no: String,
        block: String,
        start_time: String,
        end_time: String,
        name: String,
        class_nbr: String,
    }

    let mut weekly_timetable = Timetable {
        monday: Vec::new(),
        tuesday: Vec::new(),
        wednesday: Vec::new(),
        thursday: Vec::new(),
        friday: Vec::new(),
        saturday: Vec::new(),
        sunday: Vec::new(),
    };

    let mut classname_code: HashMap<String, String> = HashMap::new();
    let mut faculty_code: HashMap<String, String> = HashMap::new();
    let mut course_to_class_nbr: HashMap<String, String> = HashMap::new();
    let mut course_to_slot_venue: HashMap<String, (String, String)> = HashMap::new(); // Maps course_key to (slot, venue)
    let document = Html::parse_document(&html);
    let rows_selector = Selector::parse("tr").unwrap();
    let mut raw_slots: Vec<RawSlot> = Vec::new();
    let mut timings_temp: Vec<Timing> = Vec::new();
    let mut count_for_offset = 0;
    let table_selector = Selector::parse("tbody").unwrap();
    let mut table = document.select(&table_selector);
    let mut day = "".to_string();

    // First pass: extract course names, codes and faculty information
    if let Some(document) = table.next() {
        for row in document.select(&rows_selector) {
            let cells: Vec<_> = row.select(&Selector::parse("td").unwrap()).collect();
            if cells.len() > 8 {
                // Extract Class Nbr from column 6 (index 6)
                let class_nbr = cells[6]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", "");

                let cname = cells[2]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", "");
                let tep = cname
                    .split(" - ")
                    .filter(|k| !k.is_empty())
                    .collect::<Vec<_>>();
                if tep.len() > 1 {
                    let code = tep[0].trim().to_string();
                    // Join all parts except the first, then split by "(" to remove course type info
                    let name_parts = tep[1..].join(" - ");
                    let name = name_parts
                        .split_once("(")
                        .unwrap_or((&name_parts, ""))
                        .0
                        .trim()
                        .to_string();
                    if !classname_code.contains_key(&code) {
                        classname_code.insert(code.clone(), name);
                    }

                    // Extract course type from the course description to create mapping
                    let course_type = if cname.contains("( Embedded Theory )") {
                        "ETH"
                    } else if cname.contains("( Embedded Lab )") {
                        "ELA"
                    } else if cname.contains("( Theory Only )") {
                        "TH"
                    } else if cname.contains("( Project )") {
                        "PJT"
                    } else {
                        "UNK" // Unknown type
                    };

                    // Create mapping from course_code + course_type to class_nbr
                    if !class_nbr.is_empty() {
                        let course_key = format!("{}_{}", code, course_type);
                        course_to_class_nbr.insert(course_key.clone(), class_nbr.clone());

                        // Extract slot and venue information from column 7 (index 7)
                        if cells.len() > 7 {
                            let _slot_venue_text = cells[7]
                                .text()
                                .collect::<Vec<_>>()
                                .join("")
                                .trim()
                                .replace("\t", "")
                                .replace("\n", "");

                            // Parse slot and venue from the combined text
                            // Format is typically "SLOT - VENUE" where they might be in separate <p> tags
                            let paragraphs: Vec<_> =
                                cells[7].select(&Selector::parse("p").unwrap()).collect();
                            if paragraphs.len() >= 2 {
                                let slot_text = paragraphs[0]
                                    .text()
                                    .collect::<Vec<_>>()
                                    .join("")
                                    .trim()
                                    .replace(" - ", "")
                                    .replace(" -", "")
                                    .to_string();
                                let venue_text = paragraphs[1]
                                    .text()
                                    .collect::<Vec<_>>()
                                    .join("")
                                    .trim()
                                    .to_string();

                                if !slot_text.is_empty() && !venue_text.is_empty() {
                                    course_to_slot_venue
                                        .insert(course_key, (slot_text, venue_text));
                                }
                            }
                        }
                    }
                }

                // Extract faculty information from column 8 (index 8)
                let faculty_info = cells[8]
                    .text()
                    .collect::<Vec<_>>()
                    .join("")
                    .trim()
                    .replace("\t", "")
                    .replace("\n", "");

                // Extract faculty name (before the dash and department)
                if !faculty_info.is_empty() && faculty_info != "Project" && !class_nbr.is_empty() {
                    let faculty_name = faculty_info
                        .split(" - ")
                        .next()
                        .unwrap_or("")
                        .trim()
                        .to_string();

                    if !faculty_name.is_empty() {
                        // Use Class Nbr as the unique key for faculty mapping
                        faculty_code.insert(class_nbr, faculty_name);
                    }
                }
            }
        }
    }

    // Second pass: extract timetable data
    if let Some(document) = table.next() {
        for row in document.select(&rows_selector) {
            let mut cells: Vec<_> = row.select(&Selector::parse("td").unwrap()).collect();
            if cells.len() > 6 {
                if count_for_offset % 2 == 0 {
                    day = cells[0]
                        .text()
                        .collect::<Vec<_>>()
                        .join("")
                        .trim()
                        .replace("\t", "")
                        .replace("\n", "");
                    cells.remove(0);
                }

                for (index, val) in cells.iter().enumerate() {
                    if count_for_offset < 2 {
                        if count_for_offset == 0 {
                            let timing = Timing {
                                serial: index.to_string(),
                                start_time: val
                                    .text()
                                    .collect::<Vec<_>>()
                                    .join("")
                                    .trim()
                                    .replace("\t", "")
                                    .replace("\n", ""),
                                end_time: "".to_string(),
                            };
                            timings_temp.push(timing);
                        } else if count_for_offset == 1 {
                            if let Some(timing) = timings_temp.get_mut(index) {
                                timing.end_time = val
                                    .text()
                                    .collect::<Vec<_>>()
                                    .join("")
                                    .trim()
                                    .replace("\t", "")
                                    .replace("\n", "");
                            }
                        }
                    } else if count_for_offset > 3 {
                        let class_name = val
                            .text()
                            .collect::<Vec<_>>()
                            .join("")
                            .trim()
                            .replace("\t", "")
                            .replace("\n", "");
                        if class_name.len() > 5 && index != 0 {
                            let cle = class_name
                                .split("-")
                                .filter(|k| !k.is_empty())
                                .collect::<Vec<_>>();
                            if cle.len() > 2 {
                                let mut cl = class_name.split("-");
                                let course_code = class_name
                                    .split("-")
                                    .nth(1)
                                    .unwrap_or("")
                                    .trim()
                                    .to_string();

                                let slot_name = cl.next().unwrap_or("").trim().to_string();
                                let _extracted_course_code =
                                    cl.next().unwrap_or("").trim().to_string();
                                let course_type = cl.next().unwrap_or("").trim().to_string();
                                let room_no = cl.next().unwrap_or("").trim().to_string();
                                let block = cl.take(2).collect::<Vec<_>>().join(" ");

                                let course_name = {
                                    // First try direct course code lookup
                                    if let Some(name) = classname_code.get(&course_code) {
                                        name.clone()
                                    } else {
                                        // Try all possible keys in classname_code to find a match
                                        // This handles cases where course code format might be different
                                        let course_key = format!("{}_{}", course_code, course_type);
                                        let target_class_nbr = course_to_class_nbr.get(&course_key);

                                        let mut found_name = String::new();

                                        if let Some(target_nbr) = target_class_nbr {
                                            // Find the course name by matching class numbers
                                            for (stored_code, stored_name) in &classname_code {
                                                let test_key =
                                                    format!("{}_{}", stored_code, &course_type);
                                                if let Some(test_nbr) =
                                                    course_to_class_nbr.get(&test_key)
                                                {
                                                    if test_nbr == target_nbr {
                                                        found_name = stored_name.clone();
                                                        break;
                                                    }
                                                }
                                            }
                                        }

                                        // Last resort: if we can't find by class_nbr, try partial matching
                                        if found_name.is_empty() {
                                            for (stored_code, stored_name) in &classname_code {
                                                if stored_code == &course_code {
                                                    found_name = stored_name.clone();
                                                    break;
                                                }
                                            }
                                        }

                                        found_name
                                    }
                                };

                                let slot = RawSlot {
                                    serial: index.to_string(),
                                    day: day.clone(),
                                    slot: slot_name,
                                    course_code: course_code.clone(),
                                    course_type: course_type.clone(),
                                    room_no: room_no,
                                    block: block,
                                    start_time: "".to_string(),
                                    end_time: "".to_string(),
                                    name: course_name,
                                    class_nbr: {
                                        // Look up class_nbr using course_code + course_type
                                        let course_key = format!("{}_{}", course_code, course_type);
                                        course_to_class_nbr
                                            .get(&course_key)
                                            .unwrap_or(&"".to_string())
                                            .to_string()
                                    },
                                };
                                raw_slots.push(slot);
                            }
                        }
                    }
                }
                count_for_offset += 1;
            }
        }
    } else {
        return weekly_timetable;
    }

    // Assign timings to slots
    for slot in &mut raw_slots {
        if let Some(times) = timings_temp.iter().find(|t| t.serial == slot.serial) {
            slot.start_time = times.start_time.clone();
            slot.end_time = times.end_time.clone();
        }
    }

    // Group slots by course and day
    let mut grouped_slots: HashMap<String, HashMap<String, Vec<RawSlot>>> = HashMap::new();

    for slot in raw_slots {
        let day_key = slot.day.clone();
        let course_key = format!("{}_{}", slot.course_code, slot.course_type);

        grouped_slots
            .entry(course_key)
            .or_insert_with(HashMap::new)
            .entry(day_key)
            .or_insert_with(Vec::new)
            .push(slot);
    }

    // Convert grouped slots to the desired format
    for (_course_key, day_slots) in grouped_slots {
        for (day, slots) in day_slots {
            if slots.is_empty() {
                continue;
            }

            // Sort slots by start time
            let mut sorted_slots = slots;
            sorted_slots.sort_by(|a, b| a.start_time.cmp(&b.start_time));

            // Group consecutive slots of the same course
            let mut consecutive_groups: Vec<Vec<RawSlot>> = Vec::new();
            let mut current_group: Vec<RawSlot> = Vec::new();

            for slot in sorted_slots {
                if current_group.is_empty() {
                    current_group.push(slot);
                } else {
                    let last_slot = current_group.last().unwrap();
                    // Check if this slot is consecutive (end time of last = start time of current)
                    // OR if they have the same start time (parallel slots)
                    if (last_slot.end_time == slot.start_time
                        || last_slot.start_time == slot.start_time)
                        && last_slot.course_code == slot.course_code
                        && last_slot.course_type == slot.course_type
                    {
                        current_group.push(slot);
                    } else {
                        consecutive_groups.push(current_group.clone());
                        current_group.clear();
                        current_group.push(slot);
                    }
                }
            }
            if !current_group.is_empty() {
                consecutive_groups.push(current_group);
            }

            // Create TimetableClass for each group
            for group in consecutive_groups {
                if let (Some(first), Some(last)) = (group.first(), group.last()) {
                    let slots_combined = group
                        .iter()
                        .map(|s| s.slot.clone())
                        .collect::<Vec<_>>()
                        .join("+");

                    // Check if we have better slot information from the first table
                    let course_key = format!("{}_{}", first.course_code, first.course_type);
                    let final_slot =
                        if let Some((slot_from_table, _)) = course_to_slot_venue.get(&course_key) {
                            // Use slot from first table if available and non-empty
                            if !slot_from_table.is_empty() {
                                format!("{} -", slot_from_table)
                            } else {
                                format!("{} -", slots_combined)
                            }
                        } else {
                            // Use combined slots from timetable grid
                            format!("{} -", slots_combined)
                        };

                    let timetable_class = TimetableClass {
                        start_time: first.start_time.clone(),
                        end_time: last.end_time.clone(),
                        course_name: first.name.clone(),
                        slot: final_slot,
                        venue: {
                            // Try to use venue from first table if available
                            let course_key = format!("{}_{}", first.course_code, first.course_type);
                            if let Some((_, venue)) = course_to_slot_venue.get(&course_key) {
                                venue.clone()
                            } else {
                                // Fallback to parsed venue
                                format!("{}-{}", first.room_no, first.block.replace(" ", "-"))
                            }
                        },
                        faculty: {
                            // Use class_nbr to look up faculty
                            faculty_code
                                .get(&first.class_nbr)
                                .unwrap_or(&"Faculty Not Available".to_string())
                                .clone()
                        },
                        course_code: first.course_code.clone(),
                        course_type: first.course_type.clone(),
                    };

                    // Add to appropriate day
                    match day.as_str() {
                        "MON" => weekly_timetable.monday.push(timetable_class),
                        "TUE" => weekly_timetable.tuesday.push(timetable_class),
                        "WED" => weekly_timetable.wednesday.push(timetable_class),
                        "THU" => weekly_timetable.thursday.push(timetable_class),
                        "FRI" => weekly_timetable.friday.push(timetable_class),
                        "SAT" => weekly_timetable.saturday.push(timetable_class),
                        "SUN" => weekly_timetable.sunday.push(timetable_class),
                        _ => {}
                    }
                }
            }
        }
    }

    // Sort each day's classes by start time
    weekly_timetable
        .monday
        .sort_by(|a, b| a.start_time.cmp(&b.start_time));
    weekly_timetable
        .tuesday
        .sort_by(|a, b| a.start_time.cmp(&b.start_time));
    weekly_timetable
        .wednesday
        .sort_by(|a, b| a.start_time.cmp(&b.start_time));
    weekly_timetable
        .thursday
        .sort_by(|a, b| a.start_time.cmp(&b.start_time));
    weekly_timetable
        .friday
        .sort_by(|a, b| a.start_time.cmp(&b.start_time));
    weekly_timetable
        .saturday
        .sort_by(|a, b| a.start_time.cmp(&b.start_time));
    weekly_timetable
        .sunday
        .sort_by(|a, b| a.start_time.cmp(&b.start_time));

    weekly_timetable
}
