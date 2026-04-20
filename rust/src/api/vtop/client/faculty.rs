use crate::api::vtop::{
    parser,
    types::*,
    vtop_client::VtopClient,
    vtop_errors::VtopError,
    vtop_errors::VtopResult,
    vtop_errors::{map_reqwest_error, map_response_read_error},
};

impl VtopClient {
    /// Searches for faculty members by name or employee ID.
    ///
    /// Performs a search query against the VTOP faculty database to find faculty members
    /// matching the provided search term. Returns a list of matching faculty with basic
    /// information like name, employee ID, department, and designation.
    ///
    /// # Arguments
    ///
    /// * `search_term` - The search query string (can be partial name, full name, or employee ID)
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<GetFaculty>` containing:
    /// - List of matching faculty members
    /// - Each entry includes: employee ID, name, department, designation, school
    /// - Search metadata (total results, query info)
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The search term is empty or invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Search by name
    /// let results = client.get_faculty_search("Sharma".to_string()).await?;
    /// for faculty in results.faculty_list {
    ///     println!("{} - {} ({})",
    ///         faculty.name,
    ///         faculty.designation,
    ///         faculty.department
    ///     );
    /// }
    ///
    /// // Search by employee ID
    /// let results = client.get_faculty_search("EMP123".to_string()).await?;
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_faculty_search(&mut self, search_term: String) -> VtopResult<GetFaculty> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!(
            "{}/vtop/hrms/EmployeeSearchForStudent",
            self.config.base_url
        );
        let body = format!(
            "_csrf={}&empId={}&authorizedID={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            urlencoding::encode(&search_term),
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
        // print!("Fetched faculty search data: {}", text);
        Ok(parser::faculty::parsesearch::parse_faculty_search(text))
    }

    /// Retrieves detailed information about a specific faculty member.
    ///
    /// Fetches comprehensive profile information for a faculty member identified by their
    /// employee ID. This includes personal details, academic qualifications, research interests,
    /// contact information, and professional experience.
    ///
    /// # Arguments
    ///
    /// * `emp_id` - The employee ID of the faculty member (obtained from `get_faculty_search()`)
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<FacultyDetails>` containing comprehensive information:
    /// - Full name and employee ID
    /// - Department and school affiliation
    /// - Designation and position
    /// - Email address and phone number
    /// - Office location and cabin number
    /// - Educational qualifications
    /// - Research areas and interests
    /// - Publications and achievements
    /// - Consultation hours/availability
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The provided employee ID is invalid or not found
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // First search for faculty
    /// let search_results = client.get_faculty_search("Sharma".to_string()).await?;
    ///
    /// // Then get detailed information
    /// if let Some(faculty) = search_results.faculty_list.first() {
    ///     let details = client.get_faculty_data(faculty.emp_id.clone()).await?;
    ///     println!("Name: {}", details.name);
    ///     println!("Email: {}", details.email);
    ///     println!("Department: {}", details.department);
    ///     println!("Cabin: {}", details.cabin_number);
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_faculty_data(&mut self, emp_id: String) -> VtopResult<FacultyDetails> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!(
            "{}/vtop/hrms/EmployeeSearch1ForStudent",
            self.config.base_url
        );
        let body = format!(
            "_csrf={}&empId={}&authorizedID={}&x={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            emp_id,
            self.username,
            chrono::Utc::now().to_rfc2822()
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
        let faculty_details = parser::faculty::parseabout::parse_faculty_data(text);
        Ok(faculty_details)
    }

    /// Fetches the complete list of all faculty members in a single request.
    ///
    /// Uses `empId=` to retrieve every faculty member from VTOP in one HTTP call,
    /// returning their basic details (name, designation, school, employee ID).
    /// Use `get_faculty_data()` on a specific `emp_id` to get full profile details.
    pub async fn get_all_faculty(&mut self) -> VtopResult<Vec<GetFaculty>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!(
            "{}/vtop/hrms/EmployeeSearchForStudent",
            self.config.base_url
        );
        let body = format!(
            "_csrf={}&empId=&authorizedID={}&x={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            self.username,
            chrono::Utc::now().to_rfc2822()
        );

        let res = self
            .client
            .post(url)
            .body(body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&res).await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        Ok(parser::faculty::parsesearch::parse_all_faculty_search(text))
    }
}
