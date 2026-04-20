use crate::api::vtop::{
    parser,
    types::*,
    vtop_client::VtopClient,
    vtop_errors::VtopError,
    vtop_errors::VtopResult,
    vtop_errors::{map_reqwest_error, map_response_read_error},
};

impl VtopClient {
    /// Retrieves biometric attendance records for a specific date.
    ///
    /// Fetches the student's biometric entry/exit records from the campus biometric system
    /// for the specified date. This includes timestamps of when the student entered and
    /// exited the campus premises, useful for tracking attendance and time spent on campus.
    ///
    /// # Arguments
    ///
    /// * `date` - The date for which to fetch biometric records, in the format "DD-MMM-YYYY"
    ///            (e.g., "15-Oct-2024")
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<BiometricRecord>>` containing a list of biometric records:
    /// - Entry timestamp (date and time of campus entry)
    /// - Exit timestamp (date and time of campus exit)
    /// - Location/gate information
    /// - Duration spent on campus
    /// - Any remarks or notes
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The provided date format is invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let records = client.get_biometric_data("15-Oct-2024".to_string()).await?;
    /// for record in records {
    ///     println!("Entry: {}, Exit: {}",
    ///         record.entry_time,
    ///         record.exit_time
    ///     );
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_biometric_data(&mut self, date: String) -> VtopResult<Vec<BiometricRecord>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!("{}/vtop/getStudBioHistory", self.config.base_url);
        let body = format!(
            "_csrf={}&fromDate={}&authorizedID={}&x={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            date,
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
        // Using println! instead of print! for better formatting

        Ok(parser::parse_biometric::parse_biometric_data(text))
    }
}
