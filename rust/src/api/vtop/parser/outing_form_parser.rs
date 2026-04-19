use crate::api::vtop::types::outing_info::OutingInfo;
use crate::api::vtop::vtop_errors::VtopError;
use scraper::{Html, Selector};

pub fn parse_outing_form(html: String) -> Result<OutingInfo, VtopError> {
    let document = Html::parse_document(&html);

    let input_selector = Selector::parse("input")
        .map_err(|_| VtopError::ParseError("Failed to create selector".to_string()))?;

    let mut outing_info = OutingInfo {
        registration_number: String::new(),
        name: String::new(),
        application_no: String::new(),
        gender: String::new(),
        hostel_block: String::new(),
        room_number: String::new(),
        parent_contact_number: String::new(),
    };

    for input in document.select(&input_selector) {
        if let Some(id) = input.value().attr("id") {
            if let Some(value) = input.value().attr("value") {
                match id {
                    "regNo" => outing_info.registration_number = value.to_string(),
                    "name" => outing_info.name = value.to_string(),
                    "applicationNo" => outing_info.application_no = value.to_string(),
                    "gender" => outing_info.gender = value.to_string(),
                    "hostelBlock" => outing_info.hostel_block = value.to_string(),
                    "roomNo" => outing_info.room_number = value.to_string(),
                    "parentContactNumber" => outing_info.parent_contact_number = value.to_string(),
                    _ => {}
                }
            }
        }
    }

    // Validate that we got the required fields
    if outing_info.registration_number.is_empty() {
        return Err(VtopError::ParseError(
            "Failed to parse outing form - missing registration number".to_string(),
        ));
    }

    Ok(outing_info)
}
