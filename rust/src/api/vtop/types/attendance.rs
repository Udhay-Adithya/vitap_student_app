use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[frb(dart_metadata=("freezed", "immutable" import "package:meta/meta.dart" as meta))]
#[frb(json_serializable)]
#[frb]
pub struct AttendanceRecord {
    pub class_number: String,
    pub course_code: String,
    pub course_name: String,
    pub course_type: String,
    pub course_type_code: String, // Short code like TH, ETH, ELA
    pub course_slot: String,
    pub faculty: String,
    pub attended_classes: String,
    pub total_classes: String,
    pub attendance_percentage: String,
    pub attendance_between_percentage: String,
    pub debar_status: String,
    pub course_id: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[frb(dart_metadata=("freezed", "immutable" import "package:meta/meta.dart" as meta))]
#[frb(json_serializable)]
#[frb]
pub struct AttendanceDetailRecord {
    pub serial: String,
    pub date: String,
    pub slot: String,
    pub day_time: String,
    pub status: String,
    pub remark: String,
}
