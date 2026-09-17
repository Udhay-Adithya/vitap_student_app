use crate::api::vtop::{
    parser, types::*, vtop_client::VtopClient, vtop_errors::map_response_read_error,
    vtop_errors::VtopError, vtop_errors::VtopResult,
};
use chrono::Utc;
use reqwest::multipart::Form;

impl VtopClient {
    /// Retrieves the graded courses for a semester from the grade view page.
    ///
    /// Grades are visible for a semester only once it has ended; the current
    /// semester returns nothing until results are published. Each returned
    /// course carries a `course_id` for looking up its detailed marks with
    /// [`get_grade_view_detail`](Self::get_grade_view_detail).
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The semester id (obtained from `get_semesters()`)
    ///
    /// # Errors
    ///
    /// Returns an error if the session is not authenticated, the CSRF token is
    /// missing, or network communication fails.
    pub async fn get_grade_view(&mut self, semester_id: &str) -> VtopResult<Vec<GradeViewCourse>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        // No StudentGradeView page load first. The comment here used to say VTOP
        // required it; on a session where that page has never been opened,
        // doStudentGradeView returns the full grade table on the first request,
        // so it was a wasted round trip on every fetch.
        //
        // doStudentGradeView is posted as multipart, matching the page's form.
        let url = format!(
            "{}/vtop/examinations/examGradeView/doStudentGradeView",
            self.config.base_url
        );
        let authorizedid_v = self.username.clone();
        let semestersubid_v = semester_id.to_string();
        let res = self
            .post_multipart_with_session_retry(url, |csrf| {
                Form::new()
                    .text("authorizedID", authorizedid_v.clone())
                    .text("semesterSubId", semestersubid_v.clone())
                    .text("_csrf", csrf.to_string())
            })
            .await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        Ok(parser::grade_view_parser::parse_grade_view(text))
    }

    /// Retrieves the mark breakdown and class statistics for one course.
    ///
    /// This is the data behind an expandable tile on the grade view page: the
    /// per-component marks (CAT, FAT, quizzes), the total, and the class
    /// statistics (strength, mean, standard deviation, and grade cutoffs).
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The semester id
    /// * `course_id` - The course id, from [`GradeViewCourse::course_id`]
    ///
    /// # Errors
    ///
    /// Returns an error if the session is not authenticated, the CSRF token is
    /// missing, or network communication fails.
    pub async fn get_grade_view_detail(
        &mut self,
        semester_id: &str,
        course_id: &str,
    ) -> VtopResult<GradeViewDetail> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let url = format!(
            "{}/vtop/examinations/examGradeView/getGradeViewDetails",
            self.config.base_url
        );
        let timestamp = Utc::now().format("%a, %d %b %Y %H:%M:%S GMT").to_string();
        let body = format!(
            "authorizedID={}&x={}&semesterSubId={}&courseId={}&_csrf={}",
            self.username,
            urlencoding::encode(&timestamp),
            semester_id,
            course_id,
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
        );

        let res = self.post_form_with_session_retry(url, body).await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        Ok(parser::grade_view_parser::parse_grade_view_detail(text))
    }
}
