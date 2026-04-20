use super::GradeCourseHistory;
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[frb(dart_metadata=("freezed", "immutable" import "package:meta/meta.dart" as meta))]
#[frb(json_serializable)]
#[frb]
pub struct GradeHistory {
    pub credits_registered: String,
    pub credits_earned: String,
    pub cgpa: String,
    pub courses: Vec<GradeCourseHistory>,
}
