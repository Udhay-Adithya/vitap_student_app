use crate::api::vtop::client::auth::read_body;
use crate::api::vtop::{
    parser, types::*, vtop_client::VtopClient, vtop_errors::VtopError, vtop_errors::VtopResult,
};

impl VtopClient {
    /// Retrieves the student's biometric punches for a specific date.
    ///
    /// # Arguments
    ///
    /// * `date` - The day to fetch, as `dd/MM/yyyy` (e.g. `"25/09/2026"`). VTOP
    ///   does not reject any other format: it answers "No Record(S) Found",
    ///   which is indistinguishable from a day without punches.
    ///
    /// # Returns
    ///
    /// One `BiometricRecord` per punch, newest first, carrying its serial,
    /// date, time (`in_time`) and venue (`location`). VTOP reports single
    /// punches rather than in/out pairs, so `day`, `out_time` and `duration`
    /// are empty. A day without punches gives an empty list.
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
    /// let records = client.get_biometric_data("25/09/2026".to_string()).await?;
    /// for record in records {
    ///     println!("{} at {}", record.in_time, record.location);
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

        let res = self.post_form_with_session_retry(url, body).await?;

        let text = read_body(res).await?;
        // Using println! instead of print! for better formatting

        Ok(parser::parse_biometric::parse_biometric_data(text))
    }
}
