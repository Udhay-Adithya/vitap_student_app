use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[frb(dart_metadata=("freezed", "immutable" import "package:meta/meta.dart" as meta))]
#[frb(json_serializable)]
#[frb]
pub struct WeekendOutingRecord {
    pub serial: String,
    pub registration_number: String,
    pub hostel_block: String,
    pub room_number: String,
    pub place_of_visit: String,
    pub purpose_of_visit: String,
    pub time: String,
    #[serde(default)]
    pub contact_number: String,
    #[serde(default)]
    pub parent_contact_number: String,
    pub date: String,
    #[serde(default)]
    pub booking_id: String,
    pub status: String,
    pub can_download: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[frb(dart_metadata=("freezed", "immutable" import "package:meta/meta.dart" as meta))]
#[frb(json_serializable)]
#[frb]
pub struct WeekendOutingFormData {
    pub purpose_of_visit: String,
    pub outing_date: String,
    pub contact_number: String,
    pub out_place: String,
    pub out_time: String,
    pub parent_contact_number: String,
}
