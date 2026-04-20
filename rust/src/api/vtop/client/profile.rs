use crate::api::vtop::{
    parser,
    types::*,
    vtop_client::VtopClient,
    vtop_errors::VtopError,
    vtop_errors::VtopResult,
    vtop_errors::{map_reqwest_error, map_response_read_error},
};

impl VtopClient {
    /// Retrieves the complete academic grade history for the authenticated student.
    ///
    /// Fetches comprehensive grade records spanning all completed semesters, including course-wise
    /// grades, credit information, GPA/CGPA calculations, and academic performance trends. This data
    /// is essential for tracking academic progress, calculating overall performance, and preparing
    /// transcripts or academic reports.
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<GradeHistory>` containing:
    /// - **Overall Performance**:
    ///   - Cumulative GPA (CGPA)
    ///   - Total credits earned
    ///   - Total credits attempted
    ///   - Overall grade point average
    /// - **Semester-wise Records**: For each semester:
    ///   - Semester name and academic year
    ///   - Semester GPA (SGPA)
    ///   - Credits earned in that semester
    ///   - List of courses taken
    /// - **Course-wise Details**: For each course:
    ///   - Course code and name
    ///   - Course type (Theory/Lab/Project)
    ///   - Credits
    ///   - Grade obtained (A, B+, C, etc.)
    ///   - Grade points
    ///   - Internal marks and external marks
    ///   - Total marks
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - The response cannot be parsed (malformed HTML/data)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let grade_history = client.get_grade_history().await?;
    ///
    /// // Display overall performance
    /// println!("CGPA: {:.2}", grade_history.cgpa);
    /// println!("Total Credits: {}", grade_history.total_credits);
    ///
    /// // Display semester-wise performance
    /// for semester in &grade_history.semesters {
    ///     println!("\n{} - SGPA: {:.2}", semester.name, semester.sgpa);
    ///     
    ///     for course in &semester.courses {
    ///         println!("  {} | {} | Grade: {} | Credits: {}",
    ///             course.code,
    ///             course.name,
    ///             course.grade,
    ///             course.credits
    ///         );
    ///     }
    /// }
    /// # Ok(())
    /// # }
    /// ```
    ///
    /// ```
    /// # async fn example2(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Calculate semester-wise GPA trend
    /// let grade_history = client.get_grade_history().await?;
    ///
    /// println!("Academic Performance Trend:");
    /// for semester in &grade_history.semesters {
    ///     let bar = "█".repeat((semester.sgpa * 10.0) as usize);
    ///     println!("{:20} | {:.2} {}", semester.name, semester.sgpa, bar);
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_grade_history(&mut self) -> VtopResult<GradeHistory> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!(
            "{}/vtop/examinations/examGradeView/StudentGradeHistory",
            self.config.base_url
        );
        let body = format!(
            "verifyMenu=true&_csrf={}&authorizedID={}&nocache=@(new Date().getTime())",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            self.username
        );

        let res = self
            .client
            .post(url)
            .body(body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        // Check for session expiration and auto re-authenticate if needed
        self.handle_session_check(&res).await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        let grade_history = parser::grade_history_parser::parse_grade_history(text);
        Ok(grade_history)
    }

    /// Retrieves the comprehensive student profile with all personal and academic information.
    ///
    /// Fetches the complete student profile containing personal details, contact information,
    /// program enrollment data, and full academic grade history. This is a combined operation
    /// that makes multiple requests to gather all profile information into a single unified
    /// data structure. This method is ideal for profile pages, academic dashboards, or
    /// generating comprehensive student reports.
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<StudentProfile>` containing:
    /// - **Personal Information**:
    ///   - Full name and registration number
    ///   - Date of birth and gender
    ///   - Blood group
    ///   - Profile photograph URL
    ///   - Category (General/OBC/SC/ST)
    /// - **Contact Details**:
    ///   - Personal email and university email
    ///   - Mobile number
    ///   - Current address and permanent address
    ///   - Parent/guardian contact information
    /// - **Academic Information**:
    ///   - Program name (B.Tech, M.Tech, etc.)
    ///   - Branch/specialization
    ///   - School/department
    ///   - Current semester
    ///   - Admission year and category
    ///   - Student type (Regular/Lateral)
    /// - **Grade History**: Complete academic performance (see `get_grade_history()` for details)
    ///   - CGPA and semester-wise SGPA
    ///   - Course-wise grades and credits
    /// - **Additional Details**:
    ///   - Proctor/mentor information
    ///   - Hostel information (if applicable)
    ///   - Library card details
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - Network communication fails during profile or grade history fetch (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - The response data cannot be parsed correctly
    /// - Session expires during either request and re-authentication fails
    ///
    /// # Notes
    ///
    /// This method makes two internal API calls:
    /// 1. Fetches basic profile information
    /// 2. Fetches grade history (via `get_grade_history()`)
    ///
    /// Both are combined into a single `StudentProfile` object for convenience.
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let profile = client.get_student_profile().await?;
    ///
    /// // Display student information
    /// println!("=== Student Profile ===");
    /// println!("Name: {}", profile.student_name);
    /// println!("Reg No: {}", profile.registration_number);
    /// println!("Program: {} - {}", profile.program, profile.branch);
    /// println!("Email: {}", profile.email);
    /// println!("Phone: {}", profile.phone);
    /// println!("\nAcademic Performance:");
    /// println!("CGPA: {:.2}", profile.grade_history.cgpa);
    /// println!("Credits Earned: {}", profile.grade_history.total_credits);
    /// # Ok(())
    /// # }
    /// ```
    ///
    /// ```
    /// # async fn example2(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Generate a student report card
    /// let profile = client.get_student_profile().await?;
    ///
    /// println!("╔═══════════════════════════════════════╗");
    /// println!("║       STUDENT ACADEMIC REPORT         ║");
    /// println!("╠═══════════════════════════════════════╣");
    /// println!("║ Name: {:<31} ║", profile.student_name);
    /// println!("║ Reg:  {:<31} ║", profile.registration_number);
    /// println!("║ Program: {:<28} ║", profile.program);
    /// println!("║ CGPA: {:<31.2} ║", profile.grade_history.cgpa);
    /// println!("╚═══════════════════════════════════════╝");
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_student_profile(
        &mut self,
    ) -> VtopResult<crate::api::vtop::types::student_profile::StudentProfile> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        // Fetch basic profile data
        let url = format!(
            "{}/vtop/studentsRecord/StudentProfileAllView",
            self.config.base_url
        );
        let body = format!(
            "_csrf={}&authorizedID={}&nocache=@(new Date().getTime())",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            self.username
        );

        let res = self
            .client
            .post(url)
            .body(body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        // Check for session expiration and auto re-authenticate if needed
        self.handle_session_check(&res).await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        let mut profile = crate::api::vtop::parser::profile_parser::parse_student_profile(text);

        // Fetch grade history and add it to the profile
        let grade_history = self.get_grade_history().await?;
        profile.grade_history = grade_history;

        Ok(profile)
    }
}
