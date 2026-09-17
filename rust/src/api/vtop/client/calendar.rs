use crate::api::vtop::{
    parser, types::*, vtop_client::VtopClient, vtop_errors::map_response_read_error,
    vtop_errors::VtopError, vtop_errors::VtopResult,
};
use chrono::Utc;

/// VTOP's default class group, "All Class Group (Combined)".
pub const DEFAULT_CLASS_GROUP: &str = "COMB";

impl VtopClient {
    /// Posts one of the calendar's AJAX lookups.
    ///
    /// They all take the same envelope and differ only in the extra fields, so
    /// the envelope is built once here.
    async fn post_calendar(&mut self, path: &str, extra: &str) -> VtopResult<String> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!("{}{}", self.config.base_url, path);
        let timestamp = Utc::now().format("%a, %d %b %Y %H:%M:%S GMT").to_string();
        let body = format!(
            "_csrf={}&authorizedID={}&x={}&{}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            self.username,
            timestamp,
            extra
        );
        let res = self.post_form_with_session_retry(url, body).await?;
        res.text().await.map_err(map_response_read_error)
    }

    /// Retrieves the class groups available for a semester.
    ///
    /// Class groups are semester dependent, so VTOP only renders them once a
    /// semester is chosen.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    pub async fn get_calendar_class_groups(
        &mut self,
        semester_id: &str,
    ) -> VtopResult<Vec<ClassGroup>> {
        let text = self
            .post_calendar(
                "/vtop/getDateForSemesterPreview",
                &format!("paramReturnId=getDateForSemesterPreview&semSubId={semester_id}"),
            )
            .await?;
        Ok(parser::calendar_parser::parse_class_groups(text))
    }

    /// Retrieves the months a semester's calendar covers.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester.
    /// * `class_group_id` - The class group, e.g. [`DEFAULT_CLASS_GROUP`].
    ///
    /// # Returns
    ///
    /// One entry per month, each carrying the `cal_date` that
    /// [`Self::get_calendar_month`] expects.
    pub async fn get_calendar_months(
        &mut self,
        semester_id: &str,
        class_group_id: &str,
    ) -> VtopResult<Vec<CalendarMonthRef>> {
        let text = self
            .post_calendar(
                "/vtop/getListForSemester",
                &format!(
                    "paramReturnId=getListForSemester&semSubId={semester_id}&classGroupId={class_group_id}"
                ),
            )
            .await?;
        Ok(parser::calendar_parser::parse_calendar_months(text))
    }

    /// Retrieves one month of a semester's calendar.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester.
    /// * `cal_date` - The month to view, from [`CalendarMonthRef::cal_date`] —
    ///   e.g. "01-AUG-2026".
    /// * `class_group_id` - The class group, e.g. [`DEFAULT_CLASS_GROUP`].
    ///
    /// # Returns
    ///
    /// The month's days, in date order.
    pub async fn get_calendar_month(
        &mut self,
        semester_id: &str,
        cal_date: &str,
        class_group_id: &str,
    ) -> VtopResult<Vec<CalendarDay>> {
        let text = self
            .post_calendar(
                "/vtop/processViewCalendar",
                &format!("calDate={cal_date}&semSubId={semester_id}&classGroupId={class_group_id}"),
            )
            .await?;
        Ok(parser::calendar_parser::parse_calendar_month(
            text,
            cal_date.to_string(),
        ))
    }

    /// Retrieves a semester's whole academic calendar.
    ///
    /// VTOP serves the calendar a month at a time, so this is one request for
    /// the month list plus one per month — seven or so for a semester. It is
    /// meant to be called once and the result cached, not on every page open.
    ///
    /// A month that fails to load is skipped rather than failing the whole
    /// calendar: a calendar missing one month is still worth showing, and the
    /// gap is visible in `months` against `days`.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester.
    /// * `class_group_id` - The class group, e.g. [`DEFAULT_CLASS_GROUP`].
    pub async fn get_academic_calendar(
        &mut self,
        semester_id: &str,
        class_group_id: &str,
    ) -> VtopResult<AcademicCalendar> {
        let months = self
            .get_calendar_months(semester_id, class_group_id)
            .await?;

        let mut days: Vec<CalendarDay> = Vec::new();
        for month in &months {
            if let Ok(month_days) = self
                .get_calendar_month(semester_id, &month.cal_date, class_group_id)
                .await
            {
                days.extend(month_days);
            }
        }

        days.sort_by(|a, b| a.date.cmp(&b.date));

        Ok(AcademicCalendar {
            semester_id: semester_id.to_string(),
            class_group_id: class_group_id.to_string(),
            months,
            days,
        })
    }
}
