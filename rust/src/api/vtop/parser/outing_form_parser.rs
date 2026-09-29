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

    // Outside the hours it takes applications, VTOP still serves the page but
    // leaves the student fields out. Say so, rather than reporting a page that
    // could not be read.
    if outing_info.registration_number.is_empty() {
        return Err(VtopError::OutingFormUnavailable(vtop_notice(&document)));
    }

    Ok(outing_info)
}

/// VTOP's own explanation of when the form is open, if the page carries one.
///
/// It sits in a hidden `jsonBom` input, e.g. "You are eligible to fill this
/// form from Tuesday 12:00AM to Friday 11:59PM".
fn vtop_notice(document: &Html) -> String {
    let selector = Selector::parse("input#jsonBom").unwrap();
    document
        .select(&selector)
        .next()
        .and_then(|input| input.value().attr("value"))
        .map(|value| value.split_whitespace().collect::<Vec<_>>().join(" "))
        .unwrap_or_default()
}
