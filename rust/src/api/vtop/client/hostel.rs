use crate::api::vtop::{
    parser,
    types::*,
    vtop_client::VtopClient,
    vtop_errors::VtopError,
    vtop_errors::VtopResult,
    vtop_errors::{map_reqwest_error, map_response_read_error},
};

impl VtopClient {
    /// Retrieves the student's general outing (day leave) records from VTOP.
    ///
    /// Fetches a list of all general outing applications submitted by the student, including
    /// both approved and pending requests. General outings are typically used for day trips
    /// or short leaves that don't require overnight permission.
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<GeneralOutingRecord>>` containing:
    /// - Leave application ID (for PDF download)
    /// - Purpose of visit/outing
    /// - Destination/place of visit
    /// - Outing date and time
    /// - Return date and time
    /// - Application status (pending/approved/rejected)
    /// - Parent contact number
    /// - Application submission timestamp
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let outings = client.get_general_outing_reports().await?;
    /// for outing in outings {
    ///     println!("Destination: {}", outing.destination);
    ///     println!("Date: {}", outing.outing_date);
    ///     println!("Status: {}", outing.status);
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_general_outing_reports(&mut self) -> VtopResult<Vec<GeneralOutingRecord>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!("{}/vtop/hostel/StudentGeneralOuting", self.config.base_url);
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
        let leave_data = parser::hostel::general_outing_parser::parse_hostel_leave(text);
        Ok(leave_data)
    }

    /// Downloads the PDF pass for a specific general outing application.
    ///
    /// Retrieves the official leave pass document in PDF format for an approved general
    /// outing. This pass typically needs to be shown to hostel security when leaving campus.
    /// The PDF contains student details, outing information, and approval signatures.
    ///
    /// # Arguments
    ///
    /// * `leave_id` - The unique identifier of the leave application (obtained from `get_general_outing_reports()`)
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<u8>>` containing the PDF file as a byte vector that can be:
    /// - Saved to disk as a `.pdf` file
    /// - Displayed in a PDF viewer
    /// - Shared or printed
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The provided leave ID is invalid or not found
    /// - The leave application is not yet approved (may return empty/error)
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // First get the outing records
    /// let outings = client.get_general_outing_reports().await?;
    ///
    /// // Download PDF for an approved outing
    /// if let Some(outing) = outings.iter().find(|o| o.status == "Approved") {
    ///     let pdf_bytes = client.get_general_outing_pdf(outing.leave_id.clone()).await?;
    ///     
    ///     // Save to file
    ///     std::fs::write("outing_pass.pdf", pdf_bytes)?;
    ///     println!("PDF saved successfully");
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_general_outing_pdf(&mut self, leave_id: String) -> VtopResult<Vec<u8>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!(
            "{}/vtop/hostel/downloadLeavePass/{}?authorizedID={}&_csrf={}&x={}",
            self.config.base_url,
            leave_id,
            self.username,
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            chrono::Utc::now().to_rfc2822()
        );

        let res = self
            .client
            .get(url)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        // Check for session expiration and auto re-authenticate if needed
        self.handle_session_check(&res).await?;

        let bytes = res.bytes().await.map_err(map_response_read_error)?;
        Ok(bytes.to_vec())
    }

    /// Retrieves the student's weekend outing records from VTOP.
    ///
    /// Fetches a list of all weekend outing bookings made by the student, including past and
    /// upcoming weekend leaves. Weekend outings typically require advance booking and cover
    /// Friday evening through Sunday night or longer holiday periods.
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<WeekendOutingRecord>>` containing:
    /// - Booking ID (for PDF download)
    /// - Outing type (weekend/holiday)
    /// - Check-out date and time
    /// - Expected check-in date and time
    /// - Destination information
    /// - Booking status (confirmed/pending/cancelled)
    /// - Emergency contact details
    /// - Mode of transport
    /// - Booking timestamp
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let weekend_outings = client.get_weekend_outing_reports().await?;
    /// for outing in weekend_outings {
    ///     println!("Checkout: {}", outing.checkout_date);
    ///     println!("Expected return: {}", outing.checkin_date);
    ///     println!("Status: {}", outing.status);
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_weekend_outing_reports(&mut self) -> VtopResult<Vec<WeekendOutingRecord>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!("{}/vtop/hostel/StudentWeekendOuting", self.config.base_url);
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
        let hostel_data = parser::hostel::weekend_outing_parser::parse_weekend_outing(text);
        Ok(hostel_data)
    }

    /// Downloads the PDF pass for a specific weekend outing booking.
    ///
    /// Retrieves the official weekend outing pass document in PDF format. This pass must be
    /// shown to hostel security when leaving for a weekend outing and upon return. The PDF
    /// includes student details, outing dates, emergency contacts, and approval information.
    ///
    /// # Arguments
    ///
    /// * `booking_id` - The unique identifier of the weekend outing booking (obtained from `get_weekend_outing_reports()`)
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<u8>>` containing the PDF file as a byte vector that can be:
    /// - Saved to disk as a `.pdf` file
    /// - Displayed in a PDF viewer
    /// - Shared with parents or guardians
    /// - Shown to security personnel
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The provided booking ID is invalid or not found
    /// - The booking is not yet confirmed (may return empty/error)
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Get weekend outing records
    /// let outings = client.get_weekend_outing_reports().await?;
    ///
    /// // Download PDF for a confirmed booking
    /// if let Some(outing) = outings.iter().find(|o| o.status == "Confirmed") {
    ///     let pdf_bytes = client.get_hostel_outing_pdf(outing.booking_id.clone()).await?;
    ///     
    ///     // Save to file
    ///     std::fs::write("weekend_pass.pdf", pdf_bytes)?;
    ///     println!("Weekend pass downloaded");
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_hostel_outing_pdf(&mut self, booking_id: String) -> VtopResult<Vec<u8>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!(
            "{}/vtop/hostel/downloadOutingForm/{}?authorizedID={}&_csrf={}&x={}",
            self.config.base_url,
            booking_id,
            self.username,
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            chrono::Utc::now().to_rfc2822()
        );

        let res = self
            .client
            .get(url)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        // Check for session expiration and auto re-authenticate if needed
        self.handle_session_check(&res).await?;

        let bytes = res.bytes().await.map_err(map_response_read_error)?;
        Ok(bytes.to_vec())
    }

    /// Submits a new general outing application form to VTOP.
    ///
    /// Creates a new day outing application with the provided details. The application will
    /// be submitted to the hostel administration for approval. This method follows a two-step
    /// process: first fetching the student's pre-filled form data, then submitting the complete
    /// form with both user-provided and auto-populated information.
    ///
    /// # Arguments
    ///
    /// * `out_place` - Destination or place to be visited
    /// * `purpose_of_visit` - The reason for the outing (e.g., "Medical appointment", "Shopping", "Family visit")
    /// * `outing_date` - The date of the outing in format "DD-MMM-YYYY" (e.g., "15-Mar-2024")
    /// * `out_time` - Expected departure time in "HH:MM" format (e.g., "14:00")
    /// * `in_date` - Expected return date in format "DD-MMM-YYYY" (e.g., "15-Mar-2024")
    /// * `in_time` - Expected return time in "HH:MM" format (e.g., "18:00")
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<String>` containing the server response message, which typically includes:
    /// - Success/failure status
    /// - Application reference number
    /// - Approval status or pending message
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - Failed to fetch student form information (`VtopError::ParseError`)
    /// - The outing date/time format is invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server rejects the application (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Notes
    ///
    /// This method automatically fetches student information (name, gender, hostel block,
    /// room number, parent contact) from VTOP before submitting the form. Times are split
    /// into hours and minutes for the VTOP API.
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Submit a general outing application for medical appointment
    /// let response = client.submit_general_outing_form(
    ///     "Apollo Hospital, Vijayawada".to_string(),
    ///     "Medical checkup".to_string(),
    ///     "15-Mar-2024".to_string(),
    ///     "14:00".to_string(),
    ///     "15-Mar-2024".to_string(),
    ///     "18:00".to_string(),
    /// ).await?;
    ///
    /// println!("Application response: {}", response);
    /// # Ok(())
    /// # }
    /// ```
    ///
    /// ```
    /// # async fn example2(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Submit for evening shopping trip
    /// let response = client.submit_general_outing_form(
    ///     "PVP Mall, Vijayawada".to_string(),
    ///     "Shopping for essentials".to_string(),
    ///     "20-Mar-2024".to_string(),
    ///     "16:00".to_string(),
    ///     "20-Mar-2024".to_string(),
    ///     "21:00".to_string(),
    /// ).await?;
    ///
    /// if response.contains("success") || response.contains("submitted") {
    ///     println!("Outing application submitted successfully");
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn submit_general_outing_form(
        &mut self,
        out_place: String,
        purpose_of_visit: String,
        outing_date: String,
        out_time: String,
        in_date: String,
        in_time: String,
    ) -> VtopResult<String> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        // Step 1: Fetch the form to get pre-filled student information
        let init_url = format!("{}/vtop/hostel/StudentGeneralOuting", self.config.base_url);
        let init_body = format!(
            "verifyMenu=true&_csrf={}&authorizedID={}&nocache={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            self.username,
            chrono::Utc::now().timestamp_millis()
        );

        let init_res = self
            .client
            .post(&init_url)
            .header("Content-Type", "application/x-www-form-urlencoded")
            .body(init_body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&init_res).await?;
        let init_text = init_res.text().await.map_err(map_response_read_error)?;

        // Parse the form to get student info
        let form_info = parser::outing_form_parser::parse_outing_form(init_text)?;

        // Step 2: Submit the form with complete data
        // Split times into hours and minutes
        let out_time_parts: Vec<&str> = out_time.split(':').collect();
        let in_time_parts: Vec<&str> = in_time.split(':').collect();

        if out_time_parts.len() != 2 || in_time_parts.len() != 2 {
            return Err(VtopError::ParseError(
                "Invalid time format. Expected HH:MM".to_string(),
            ));
        }

        let submit_url = format!("{}/vtop/hostel/saveGeneralOutingForm", self.config.base_url);
        let submit_body = format!(
            "authorizedID={}&LeaveId=&regNo={}&name={}&applicationNo={}&gender={}&hostelBlock={}&roomNo={}&placeOfVisit={}&purposeOfVisit={}&outDate={}&outTimeHr={}&outTimeMin={}&inDate={}&inTimeHr={}&inTimeMin={}&parentContactNumber={}&_csrf={}&x={}",
            urlencoding::encode(&self.username),
            urlencoding::encode(&form_info.registration_number),
            urlencoding::encode(&form_info.name),
            urlencoding::encode(&form_info.application_no),
            urlencoding::encode(&form_info.gender),
            urlencoding::encode(&form_info.hostel_block),
            urlencoding::encode(&form_info.room_number),
            urlencoding::encode(&out_place),
            urlencoding::encode(&purpose_of_visit),
            urlencoding::encode(&outing_date),
            out_time_parts[0],
            out_time_parts[1],
            urlencoding::encode(&in_date),
            in_time_parts[0],
            in_time_parts[1],
            urlencoding::encode(&form_info.parent_contact_number),
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            urlencoding::encode(&chrono::Utc::now().to_rfc2822())
        );

        let submit_res = self
            .client
            .post(&submit_url)
            .header("Content-Type", "application/x-www-form-urlencoded")
            .body(submit_body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&submit_res).await?;
        let response_text = submit_res.text().await.map_err(map_response_read_error)?;

        // Parse the HTML response to extract the success/error message
        let parsed_message = parser::outing_response_parser::parse_outing_response(response_text);
        Ok(parsed_message)
    }

    /// Submits a new weekend outing application form to VTOP.
    ///
    /// Creates a new weekend outing booking with the provided details. The application will
    /// be submitted to the hostel administration for approval. This method follows a two-step
    /// process: first fetching the student's pre-filled form data, then submitting the complete
    /// form with both user-provided and auto-populated information.
    ///
    /// # Arguments
    ///
    /// * `out_place` - Destination or place to be visited
    /// * `purpose_of_visit` - The reason for the outing (e.g., "Family visit", "Friend's place")
    /// * `outing_date` - The date of the outing in format "DD-MMM-YYYY" (e.g., "23-Mar-2024")
    /// * `out_time` - Expected departure time in "HH:MM" format (e.g., "18:00")
    /// * `contact_number` - Student's contact number during the outing
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<String>` containing the server response message, which typically includes:
    /// - Success/failure status
    /// - Booking reference number
    /// - Approval status or pending message
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - Failed to fetch student form information (`VtopError::ParseError`)
    /// - The outing date/time format is invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server rejects the application (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Notes
    ///
    /// This method automatically fetches student information (name, gender, hostel block,
    /// room number, parent contact) from VTOP before submitting the form.
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Submit a weekend outing application
    /// let response = client.submit_weekend_outing_form(
    ///     "Home, Guntur".to_string(),
    ///     "Family visit".to_string(),
    ///     "23-Mar-2024".to_string(),
    ///     "18:00".to_string(),
    ///     "9876543210".to_string(),
    /// ).await?;
    ///
    /// println!("Booking response: {}", response);
    /// # Ok(())
    /// # }
    /// ```
    ///
    /// ```
    /// # async fn example2(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Submit for friend visit
    /// let response = client.submit_weekend_outing_form(
    ///     "Friend's residence, Vijayawada".to_string(),
    ///     "Social visit".to_string(),
    ///     "30-Mar-2024".to_string(),
    ///     "16:00".to_string(),
    ///     "9123456789".to_string(),
    /// ).await?;
    ///
    /// if response.contains("success") || response.contains("booked") {
    ///     println!("Weekend outing booked successfully");
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn submit_weekend_outing_form(
        &mut self,
        out_place: String,
        purpose_of_visit: String,
        outing_date: String,
        out_time: String,
        contact_number: String,
    ) -> VtopResult<String> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        // Step 1: Fetch the form to get pre-filled student information
        let init_url = format!("{}/vtop/hostel/StudentWeekendOuting", self.config.base_url);
        let init_body = format!(
            "verifyMenu=true&_csrf={}&authorizedID={}&nocache={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            self.username,
            chrono::Utc::now().timestamp_millis()
        );

        let init_res = self
            .client
            .post(&init_url)
            .header("Content-Type", "application/x-www-form-urlencoded")
            .body(init_body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&init_res).await?;
        let init_text = init_res.text().await.map_err(map_response_read_error)?;

        // Parse the form to get student info
        let form_info = parser::outing_form_parser::parse_outing_form(init_text)?;

        // Step 2: Submit the form with complete data
        let submit_url = format!("{}/vtop/hostel/saveOutingForm", self.config.base_url);
        let submit_body = format!(
            "authorizedID={}&BookingId=&regNo={}&name={}&applicationNo={}&gender={}&hostelBlock={}&roomNo={}&outPlace={}&purposeOfVisit={}&outingDate={}&outTime={}&contactNumber={}&parentContactNumber={}&_csrf={}&x={}",
            urlencoding::encode(&self.username),
            urlencoding::encode(&form_info.registration_number),
            urlencoding::encode(&form_info.name),
            urlencoding::encode(&form_info.application_no),
            urlencoding::encode(&form_info.gender),
            urlencoding::encode(&form_info.hostel_block),
            urlencoding::encode(&form_info.room_number),
            urlencoding::encode(&out_place),
            urlencoding::encode(&purpose_of_visit),
            urlencoding::encode(&outing_date),
            urlencoding::encode(&out_time),
            urlencoding::encode(&contact_number),
            urlencoding::encode(&form_info.parent_contact_number),
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            urlencoding::encode(&chrono::Utc::now().to_rfc2822())
        );

        let submit_res = self
            .client
            .post(&submit_url)
            .header("Content-Type", "application/x-www-form-urlencoded")
            .body(submit_body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&submit_res).await?;
        let response_text = submit_res.text().await.map_err(map_response_read_error)?;

        // Parse the HTML response to extract the success/error message
        let parsed_message = parser::outing_response_parser::parse_outing_response(response_text);
        Ok(parsed_message)
    }

    /// Deletes a general outing application from VTOP.
    ///
    /// Cancels/deletes a previously submitted general outing application using its Leave ID.
    /// This is useful when a student wants to cancel their outing request before it's processed
    /// or if they need to remove an outdated application.
    ///
    /// # Arguments
    ///
    /// * `leave_id` - The unique identifier for the general outing application (e.g., "L24044195432")
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<String>` containing the server response message, which typically includes:
    /// - Success/failure status
    /// - Confirmation message about deletion
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The Leave ID doesn't exist or is invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server rejects the deletion request (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Notes
    ///
    /// - Only the student who created the outing application can delete it
    /// - Applications that have already been approved may not be deletable
    /// - The Leave ID can be obtained from the general outing reports
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Delete a general outing application
    /// let response = client.delete_general_outing("L24044195432".to_string()).await?;
    ///
    /// if response.contains("success") || response.contains("deleted") {
    ///     println!("Outing application deleted successfully");
    /// }
    /// # Ok(())
    /// # }
    /// ```
    ///
    /// ```
    /// # async fn example2(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Get outing reports and delete a specific one
    /// let reports = client.get_general_outing_reports().await?;
    /// if let Some(first_report) = reports.first() {
    ///     let leave_id = &first_report.leave_id;
    ///     let response = client.delete_general_outing(leave_id.clone()).await?;
    ///     println!("Deletion response: {}", response);
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn delete_general_outing(&mut self, leave_id: String) -> VtopResult<String> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let url = format!(
            "{}/vtop/hostel/deleteGeneralOutingInfo",
            self.config.base_url
        );
        let body = format!(
            "_csrf={}&LeaveId={}&authorizedID={}&x={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            urlencoding::encode(&leave_id),
            urlencoding::encode(&self.username),
            urlencoding::encode(&chrono::Utc::now().to_rfc2822())
        );

        let res = self
            .client
            .post(&url)
            .header(
                "Content-Type",
                "application/x-www-form-urlencoded; charset=UTF-8",
            )
            .header("X-Requested-With", "XMLHttpRequest")
            .body(body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&res).await?;
        let response_text = res.text().await.map_err(map_response_read_error)?;

        // Parse the HTML response to extract the success/error message
        let parsed_message = parser::outing_response_parser::parse_outing_response(response_text);
        Ok(parsed_message)
    }

    /// Deletes a weekend outing booking from VTOP.
    ///
    /// Cancels a previously submitted weekend outing booking. This can be used to remove
    /// a booking that is no longer needed or was created by mistake.
    ///
    /// # Arguments
    ///
    /// * `booking_id` - The booking ID of the weekend outing to delete (e.g., "W24044341477")
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<String>` containing the server response message, which typically includes:
    /// - Success/failure status
    /// - Confirmation of deletion
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The booking ID is invalid or not found
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server rejects the request (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Delete a weekend outing booking
    /// let response = client.delete_weekend_outing(
    ///     "W24044341477".to_string(),
    /// ).await?;
    ///
    /// if response.contains("success") || response.contains("deleted") {
    ///     println!("Weekend outing deleted successfully");
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn delete_weekend_outing(&mut self, booking_id: String) -> VtopResult<String> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let url = format!("{}/vtop/hostel/deleteBookingInfo", self.config.base_url);
        let body = format!(
            "_csrf={}&BookingId={}&authorizedID={}&x={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            urlencoding::encode(&booking_id),
            urlencoding::encode(&self.username),
            urlencoding::encode(&chrono::Utc::now().to_rfc2822())
        );

        let res = self
            .client
            .post(&url)
            .header(
                "Content-Type",
                "application/x-www-form-urlencoded; charset=UTF-8",
            )
            .header("X-Requested-With", "XMLHttpRequest")
            .body(body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&res).await?;
        let response_text = res.text().await.map_err(map_response_read_error)?;

        // Parse the HTML response to extract the success/error message
        let parsed_message = parser::outing_response_parser::parse_outing_response(response_text);
        Ok(parsed_message)
    }
}
