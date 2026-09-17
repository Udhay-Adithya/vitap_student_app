use crate::api::vtop::{
    parser, types::*, vtop_client::VtopClient, vtop_errors::map_response_read_error,
    vtop_errors::VtopError, vtop_errors::VtopResult,
};

impl VtopClient {
    /// Downloads the official payment receipt document from VTOP.
    ///
    /// Retrieves the HTML or PDF content of a payment receipt for a specific transaction.
    /// This receipt serves as proof of payment for tuition fees, hostel fees, exam fees,
    /// or other university charges. The receipt contains transaction details, payment
    /// method, timestamps, and official university acknowledgment.
    ///
    /// # Arguments
    ///
    /// * `receipt_no` - The receipt number/ID of the payment transaction (obtained from `get_payment_receipts()`)
    /// * `applno` - The application number associated with the payment transaction
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<String>` containing the receipt document as HTML/text that includes:
    /// - Receipt number and date
    /// - Student registration number and name
    /// - Payment description/purpose
    /// - Amount paid and payment method
    /// - Transaction ID and bank details
    /// - Official acknowledgment/stamp
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The provided receipt number or application number is invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```no_run
    /// # use lib_vtop::api::vtop::vtop_client::VtopClient;
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // First get the list of receipts, and the application number from the profile.
    /// let receipts = client.get_payment_receipts().await?;
    /// let profile = client.get_student_profile().await?;
    ///
    /// // Download a specific receipt
    /// if let Some(receipt) = receipts.first() {
    ///     let receipt_html = client.download_payment_receipt(
    ///         receipt.receipt_no.clone(),
    ///         profile.application_number.clone(),
    ///     ).await?;
    ///
    ///     // Save to file or display
    ///     std::fs::write("payment_receipt.html", receipt_html)?;
    ///     println!("Receipt downloaded successfully");
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn download_payment_receipt(
        &mut self,
        receipt_no: String,
        applno: String,
    ) -> VtopResult<String> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!(
            "{}/vtop/finance/dupReceiptNewP2P?receitNo={}&authorizedID={}&_csrf={}&x={}&registerNumber={}&applno={}",
            self.config.base_url,
            receipt_no,
            self.username,
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            chrono::Utc::now().to_rfc2822(),
            self.username,
            applno // This should be replaced with the actual application number if needed
        );

        let res = self.get_with_session_retry(url).await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        Ok(text)
    }

    /// Retrieves the complete history of payment receipts for the authenticated student.
    ///
    /// Fetches a list of all successful payment transactions made through VTOP. This includes
    /// tuition fees, hostel fees, examination fees, library fines, and other university charges.
    /// Each receipt record contains transaction details that can be used to download the full
    /// official receipt document.
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<PaidPaymentReceipt>>` containing a list of payment receipts with:
    /// - Receipt number (for downloading the full receipt)
    /// - Application number (transaction reference)
    /// - Payment description/category (e.g., "Tuition Fee - Semester 5")
    /// - Amount paid
    /// - Payment date and timestamp
    /// - Payment mode (Online/Card/Net Banking)
    /// - Transaction status (Paid/Success)
    /// - Semester and academic year
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
    /// ```no_run
    /// # use lib_vtop::api::vtop::vtop_client::VtopClient;
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let receipts = client.get_payment_receipts().await?;
    ///
    /// // Display payment history
    /// for receipt in &receipts {
    ///     println!("Receipt: {} | Amount: ₹{} | Date: {}",
    ///         receipt.receipt_no,
    ///         receipt.amount,
    ///         receipt.date
    ///     );
    /// }
    ///
    /// // Calculate total paid (amounts are strings, so parse them)
    /// let total: f64 = receipts.iter()
    ///     .filter_map(|r| r.amount.parse::<f64>().ok())
    ///     .sum();
    /// println!("Total paid: ₹{}", total);
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_payment_receipts(&mut self) -> VtopResult<Vec<PaidPaymentReceipt>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!("{}/vtop/p2p/getReceiptsApplno", self.config.base_url);
        let body = format!(
            "verifyMenu=true&_csrf={}&authorizedID={}&nocache=@(new Date().getTime())",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            self.username
        );

        let res = self.post_form_with_session_retry(url, body).await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        let receipts: Vec<PaidPaymentReceipt> =
            parser::payment_receipts_parser::parse_payment_receipts(text);
        Ok(receipts)
    }

    /// Retrieves all pending payment obligations for the authenticated student.
    ///
    /// Fetches a list of unpaid fees and charges that are due or overdue. This includes
    /// upcoming semester fees, hostel charges, library fines, examination fees, and other
    /// university dues. Students should regularly check this to avoid late payment penalties
    /// and ensure they can access academic services (registration, exams, results).
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<PendingPaymentReceipt>>` containing pending payments with:
    /// - Payment description/category (e.g., "Semester Fee - Fall 2024")
    /// - Amount due
    /// - Due date/deadline
    /// - Payment status (Pending/Overdue)
    /// - Payment link or transaction ID (for online payment)
    /// - Semester and academic year
    /// - Late fee penalty (if applicable)
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
    /// ```no_run
    /// # use lib_vtop::api::vtop::vtop_client::VtopClient;
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let pending = client.get_pending_payment().await?;
    ///
    /// if pending.is_empty() {
    ///     println!("No pending payments - all clear!");
    /// } else {
    ///     println!("You have {} pending payment(s):", pending.len());
    ///
    ///     for payment in &pending {
    ///         println!("- {} | Amount: ₹{} | Due: {}",
    ///             payment.fees_heads,
    ///             payment.total_amount,
    ///             payment.end_date
    ///         );
    ///     }
    ///
    ///     // Calculate total due (amounts are strings, so parse them)
    ///     let total_due: f64 = pending.iter()
    ///         .filter_map(|p| p.total_amount.parse::<f64>().ok())
    ///         .sum();
    ///     println!("\nTotal amount due: ₹{}", total_due);
    /// }
    /// # Ok(())
    /// # }
    /// ```
    ///
    /// ```no_run
    /// # use lib_vtop::api::vtop::vtop_client::VtopClient;
    /// # async fn example2(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // List the pending payments that carry a fine.
    /// let pending = client.get_pending_payment().await?;
    /// let with_fine: Vec<_> = pending.iter()
    ///     .filter(|p| p.fine != "0" && !p.fine.is_empty())
    ///     .collect();
    ///
    /// if !with_fine.is_empty() {
    ///     println!("URGENT: {} payment(s) have accrued a fine!", with_fine.len());
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_pending_payment(&mut self) -> VtopResult<Vec<PendingPaymentReceipt>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!("{}/vtop/finance/Payments", self.config.base_url);
        let body = format!(
            "verifyMenu=true&_csrf={}&authorizedID={}&nocache=@(new Date().getTime())",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            self.username
        );

        let res = self.post_form_with_session_retry(url, body).await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        let pending_payment = parser::pending_payments_parser::parse_pending_payments(text);
        Ok(pending_payment)
    }
}
