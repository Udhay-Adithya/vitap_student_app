use crate::api::vtop::{
    captcha_solver as captcha_parser, vtop_client::VtopClient, vtop_errors::VtopError,
    vtop_errors::VtopResult, vtop_errors::{map_reqwest_error, map_response_read_error},
};
use reqwest::{cookie::CookieStore, Url};
use scraper::{Html, Selector};
use reqwest::multipart::Form;
use serde_json::Value;

impl VtopClient {
    /// Retrieves the current session's cookies as a byte vector.
    ///
    /// Returns an error if the session is not authenticated.
    ///
    /// # Returns
    /// A vector of bytes representing the session cookies, or an error if the session has expired.
    ///
    /// # Examples
    ///
    /// ```
    /// let cookies = client.get_cookie().await?;
    /// assert!(!cookies.is_empty());
    /// ```
    #[cfg(not(target_arch = "wasm32"))]
    pub async fn get_cookie(&self) -> VtopResult<Vec<u8>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let mut data = vec![];
        let url = format!("{}/vtop", self.config.base_url);
        let k = self
            .session
            .get_cookie_store()
            .cookies(&Url::parse(&url).unwrap());
        if let Some(cookie) = k {
            data = cookie.as_bytes().to_vec();
        }
        Ok(data)
    }

    /// Helper method to check for session expiration and automatically re-authenticate if needed.
    ///
    /// # Arguments
    /// * `response` - The HTTP response to check for session expiration
    ///
    /// # Returns
    /// Returns `Ok(())` if session is valid or re-authentication succeeded.
    /// Returns `Err(VtopError::SessionExpiredRetryNeeded)` if session expired and re-authentication
    /// succeeded, indicating the calling method should retry the request.
    /// Returns other errors if authentication failed.
    pub(crate) async fn handle_session_check(&mut self, response: &reqwest::Response) -> VtopResult<()> {
        match self.session.check_session_expiration(response) {
            Ok(_) => Ok(()), // Session is valid
            Err(VtopError::SessionExpired) => {
                // Session expired, attempt re-authentication
                println!("Session expired, attempting to re-authenticate...");
                match self.login().await {
                    Ok(_) => {
                        println!("Re-authentication successful");
                        // For now, we just continue. In a future enhancement, we could
                        // implement automatic retry logic here.
                        Ok(())
                    }
                    Err(e) => {
                        println!("Re-authentication failed: {:?}", e);
                        Err(e)
                    }
                }
            }
            Err(e) => Err(e), // Other error
        }
    }

    /// Authenticates the user with the VTOP system using provided credentials.
    ///
    /// This method performs a complete login flow including:
    /// 1. Loading the initial login page to obtain session cookies
    /// 2. Extracting CSRF tokens for security
    /// 3. Solving CAPTCHA challenges automatically
    /// 4. Submitting credentials and validating the response
    /// 5. Establishing an authenticated session
    ///
    /// The method automatically retries up to 4 times if CAPTCHA verification fails,
    /// loading a fresh CAPTCHA image for each attempt.
    ///
    /// # Returns
    ///
    /// Returns `Ok(())` if authentication succeeds and a valid session is established.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The username or password is incorrect (`VtopError::InvalidCredentials`)
    /// - CAPTCHA solving fails repeatedly (`VtopError::CaptchaRequired` or `VtopError::AuthenticationFailed`)
    /// - Maximum login attempts (4) are exceeded (`VtopError::AuthenticationFailed`)
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server is unavailable (`VtopError::VtopServerError`)
    /// - CSRF token extraction fails (`VtopError::ParseError`)
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example() -> Result<(), Box<dyn std::error::Error>> {
    /// use lib_vtop::{VtopClient, VtopConfig, SessionManager};
    /// 
    /// let config = VtopConfig::default();
    /// let session = SessionManager::new();
    /// let mut client = VtopClient::with_config(
    ///     config,
    ///     session,
    ///     "21BCE1234".to_string(),
    ///     "password123".to_string()
    /// );
    /// 
    /// match client.login().await {
    ///     Ok(_) => println!("Login successful!"),
    ///     Err(e) => eprintln!("Login failed: {:?}", e),
    /// }
    /// # Ok(())
    /// # }
    /// ```
    ///
    /// # Notes
    ///
    /// - This method must be called before any other API methods that require authentication
    /// - The session remains valid until explicitly logged out or until VTOP server invalidates it
    /// - Failed login attempts may temporarily lock the account after multiple failures
    pub async fn login(&mut self) -> VtopResult<()> {
        #[allow(non_snake_case)]
        let MAX_CAP_TRY = 4;
        for i in 0..MAX_CAP_TRY {
            if i == 0 {
                self.load_login_page(true).await?;
            } else {
                self.load_login_page(false).await?;
            }

            let captcha_answer = if let Some(captcha_data) = &self.captcha_data {
                // Call the new, separated captcha solver
                captcha_parser::solve_captcha(captcha_data).await?
            } else {
                return Err(VtopError::CaptchaRequired);
            };
            match self.perform_login(&captcha_answer).await {
                Ok(_) => {
                    self.session.set_authenticated(true);
                    return Ok(());
                }
                Err(VtopError::AuthenticationFailed(msg)) if msg.contains("Invalid Captcha") => {
                    continue;
                }
                Err(e) => return Err(e),
            }
        }
        Err(VtopError::AuthenticationFailed(
            "Max login attempts exceeded".to_string(),
        ))
    }

    /// Verifies the OTP sent during login authentication.
    ///
    /// This method submits the OTP entered by the user to VTOP.
    /// If the OTP is correct, the session is finalized and the user is
    /// fully authenticated. On success, the method also loads the
    /// authenticated dashboard page and extracts session details.
    ///
    /// # Sample Response (Success)
    /// ```json
    /// {
    ///   "status": "SUCCESS",
    ///   "redirectUrl": "/vtop/content"
    /// }
    /// ```
    ///
    /// # Sample Response (Failure)
    /// ```json
    /// {
    ///   "status": "INVALID",
    ///   "message": "Invalid OTP. Please try again."
    /// }
    /// ```
    ///
    /// # Sample Response (Failure)
    /// ```json
    /// {
    ///   "status": "EXPIRED",
    ///   "message": "OTP has expired. Please resend."
    /// }
    /// ```
    ///
    /// # Returns
    /// Returns `Ok(())` if OTP verification succeeds and session is authenticated.
    ///
    /// # Errors
    /// - `LoginOtpIncorrect` → OTP is wrong
    /// - `LoginOtpExpired` → OTP expired
    /// - `AuthenticationFailed` → server or parsing error
    /// - `SessionExpired` → missing CSRF/session token
    pub async fn verify_login_otp(&mut self, otp: &str) -> VtopResult<()> {

        let csrf = self
            .session
            .get_csrf_token()
            .ok_or(VtopError::SessionExpired)?;

        let url = format!("{}/vtop/validateSecurityOtp", self.config.base_url);
        let form_data = Form::new().text("otpCode", otp.to_string()).text("_csrf", csrf);

        let response = self
            .client
            .post(url)
            .multipart(form_data)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        if !response.status().is_success() {
            return Err(VtopError::AuthenticationFailed(
                format!("Failed to verify OTP. Server responded with status: {}", response.status()),
            ));
        }

        let response_json : Value = response.json().await.map_err(map_response_read_error)?;
        let status = response_json.get("status").and_then(|v| v.as_str()).unwrap_or("STATUS_NOT_FOUND");
        let message = response_json.get("message").and_then(|v| v.as_str()).unwrap_or("MESSAGE_NOT_FOUND");

        match status {

            "SUCCESS" => {
                let redirect_url = response_json.get("redirectUrl").and_then(|v| v.as_str()).unwrap_or("URL_NOT_FOUND");
                if redirect_url == "URL_NOT_FOUND" {
                    return Err(VtopError::AuthenticationFailed("Redirect URL not found in after OTP verification".to_string()));
                }
                // println!("Success response json: {:?}", response_json);
                let content_url  = format!("{}{}", self.config.base_url, redirect_url);
                let content_response = self
                            .client
                            .get(content_url)
                            .send()
                            .await
                            .map_err(map_reqwest_error)?;
                let response_text = content_response.text().await.map_err(map_response_read_error)?;
                self.current_page = Some(response_text);
                self.extract_csrf_token()?;
                self.get_regno()?;

                self.current_page = None;
                self.captcha_data = None;

                self.session.set_authenticated(true);

                Ok(())

            },

            "INVALID" => Err(VtopError::LoginOtpIncorrect),

            "EXPIRED" => Err(VtopError::LoginOtpExpired),
            
            _ => Err(VtopError::AuthenticationFailed(format!("{}: {}", status, message)))
        }
    }

    /// Requests a new OTP to be sent for login authentication.
    ///
    /// This method triggers the VTOP server to resend the OTP to the user.
    /// It is used when the previous OTP expires or is not received.
    ///
    /// # Sample Response (Success)
    /// ```json
    /// {
    ///   "otpSentAt": "2026-04-17T23:18:03.719",
    ///   "message": "OTP sent successfully",
    ///   "status": "SUCCESS"
    /// }
    /// ```
    ///
    /// # Returns
    /// Returns `Ok(())` if OTP is successfully requested.
    ///
    /// # Errors
    /// - `AuthenticationFailed` → OTP request failed or server error
    /// - `SessionExpired` → missing CSRF/session token
    pub async fn resend_login_otp(&mut self) -> VtopResult<()> {
        let csrf = self
            .session
            .get_csrf_token()
            .ok_or(VtopError::SessionExpired)?;

        let url = format!("{}/vtop/resendSecurityOtp", self.config.base_url);
        let form_data = Form::new().text("_csrf", csrf);

        let response = self
            .client
            .post(url)
            .multipart(form_data)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        if response.status().is_success() {
            let response_json : Value = response.json().await.map_err(map_response_read_error)?;
            let status = response_json.get("status").and_then(|v| v.as_str()).unwrap_or("UNKNOWN_STATUS_FOR_RESEND_OTP");
            let message = response_json.get("message")
                            .and_then(|v| v.as_str())
                            .unwrap_or("Failed to resend OTP from server side").to_string();
            if status == "SUCCESS" {
                Ok(())
            } else {
                Err(VtopError::AuthenticationFailed(format!("{}: {}", status, message)))
            }
        } else {
            Err(VtopError::AuthenticationFailed(
                "Failed to request OTP. Please try again.".to_string(),
            ))
        }
    }

    /// Performs the actual login submission with credentials and CAPTCHA answer.
    ///
    /// This is an internal helper method that handles the HTTP POST request to submit
    /// login credentials along with the solved CAPTCHA. It processes the server response
    /// to determine if authentication was successful or if an error occurred.
    ///
    /// OTP is not always required.
    /// It is required when there is inactivity or a new IP address.
    /// After successful username, password, and captcha verification,
    /// the server may redirect to the OTP verification page (vtop/error).
    /// Sometimes, the login page (vtop/login) itself will include
    /// the "securityOtpForm" if OTP is required.
    ///
    /// # Arguments
    ///
    /// * `captcha_answer` - The solved CAPTCHA string to be submitted with credentials
    ///
    /// # Returns
    ///
    /// Returns `Ok(())` if the login submission is successful and credentials are valid.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The CAPTCHA answer is incorrect (`VtopError::AuthenticationFailed` with "Invalid Captcha")
    /// - The username or password is incorrect (`VtopError::InvalidCredentials`)
    /// - The CSRF token is missing (`VtopError::SessionExpired`)
    /// - Network request fails (`VtopError::NetworkError`)
    /// - The server returns an unexpected error (`VtopError::AuthenticationFailed`)
    /// - OTP is required for login (`VtopError::LoginOtpRequired`)
    async fn perform_login(&mut self, captcha_answer: &String) -> VtopResult<()> {
        let csrf = self
            .session
            .get_csrf_token()
            .ok_or(VtopError::SessionExpired)?;

        let login_data = format!(
            "_csrf={}&username={}&password={}&captchaStr={}",
            csrf,
            urlencoding::encode(&self.username),
            urlencoding::encode(&self.password),
            captcha_answer
        );
        let url = format!("{}/vtop/login", self.config.base_url);

        let response = self
            .client
            .post(url)
            .body(login_data)
            .send()
            .await
            .map_err(map_reqwest_error)?;
        let response_url = response.url().to_string();
        let response_text = response.text().await.map_err(map_response_read_error)?;

        if response_url.contains("error") {
            if response_text.contains("Invalid Captcha") {
                return Err(VtopError::AuthenticationFailed(
                    "Invalid Captcha".to_string(),
                ));
            } else if Self::is_otp_required(&response_text) {
                Err(VtopError::LoginOtpRequired)
            }else if response_text.contains("Invalid LoginId/Password")
                || response_text.contains("Invalid  Username/Password")
            {
                Err(VtopError::InvalidCredentials)
            } else {
                Err(VtopError::AuthenticationFailed(Self::get_login_page_error(
                    &response_text,
                )))
            }
        } else if Self::is_otp_required(&response_text) {
            Err(VtopError::LoginOtpRequired)
        } else {
            self.current_page = Some(response_text);
            self.extract_csrf_token()?;
            self.get_regno()?;

            self.current_page = None;
            self.captcha_data = None;
            Ok(())
        }
    }

    /// Loads the login page and extracts the CAPTCHA image.
    ///
    /// This internal method handles loading the VTOP login page and extracting the CAPTCHA
    /// image for solving. It can optionally load the initial page first to establish cookies,
    /// and will retry up to 8 times if the CAPTCHA image is not immediately available.
    ///
    /// # Arguments
    ///
    /// * `k` - If `true`, loads the initial VTOP page first to establish session cookies
    ///         and extract initial CSRF tokens. If `false`, skips initial page load.
    ///
    /// # Returns
    ///
    /// Returns `Ok(())` when the login page is successfully loaded and CAPTCHA is extracted.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - Failed to load initial page (`VtopError::NetworkError`)
    /// - Failed to extract CSRF token (`VtopError::ParseError`)
    /// - Network request fails (`VtopError::NetworkError`)
    /// - Server returns error status (`VtopError::VtopServerError`)
    /// - CAPTCHA image not found after maximum retries (`VtopError::CaptchaRequired`)
    async fn load_login_page(&mut self, k: bool) -> VtopResult<()> {
        if k {
            self.load_initial_page().await?;
            self.extract_csrf_token()?;
        }
        #[allow(non_snake_case)]
        let Max_RELOAD_ATTEMPTS = 8;
        let csrf = self
            .session
            .get_csrf_token()
            .ok_or(VtopError::SessionExpired)?;
        let url = format!("{}/vtop/prelogin/setup", self.config.base_url);
        let body = format!("_csrf={}&flag=VTOP", csrf);
        for _ in 0..Max_RELOAD_ATTEMPTS {
            let response = self
                .client
                .post(&url)
                .body(body.clone())
                .send()
                .await
                .map_err(map_reqwest_error)?;
            if !response.status().is_success() {
                return Err(VtopError::VtopServerError);
            }
            let text = response.text().await.map_err(map_response_read_error)?;
            if text.contains("base64,") {
                self.current_page = Some(text);
                self.extract_captcha_data()?;
                break;
            }
            println!("No captcha found Reloading the page ");
        }
        Ok(())
    }

    /// Extracts the base64-encoded CAPTCHA image data from the login page HTML.
    ///
    /// This internal method parses the HTML document to locate the CAPTCHA image element
    /// and extracts its base64-encoded source data. The CAPTCHA data is stored internally
    /// for later solving and submission.
    ///
    /// # Returns
    ///
    /// Returns `Ok(())` if CAPTCHA data is successfully extracted and stored.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The current page HTML is not available (`VtopError::ParseError`)
    /// - The CAPTCHA image element is not found in the HTML (`VtopError::CaptchaRequired`)
    /// - The image source doesn't contain base64 data (`VtopError::CaptchaRequired`)
    fn extract_captcha_data(&mut self) -> VtopResult<()> {
        let document = Html::parse_document(&self.current_page.as_ref().ok_or(
            VtopError::ParseError("Current page not found at captcha extration".into()),
        )?);
        let selector = Selector::parse("img.form-control.img-fluid.bg-light.border-0").unwrap();
        let captcha_src = document
            .select(&selector)
            .next()
            .and_then(|element| element.value().attr("src"))
            .ok_or(VtopError::CaptchaRequired)?;

        if captcha_src.contains("base64,") {
            self.captcha_data = Some(captcha_src.to_string());
        } else {
            return Err(VtopError::CaptchaRequired);
        }

        Ok(())
    }

    /// Extracts and updates the registration number from the authenticated page.
    ///
    /// After successful login, VTOP returns the user's registration number in a hidden
    /// form field. This method extracts that registration number and updates the client's
    /// stored username to ensure consistency across the session.
    ///
    /// # Returns
    ///
    /// Returns `Ok(())` if the registration number is successfully extracted and stored.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The current page HTML is not available (`VtopError::ParseError`)
    /// - The authorizedIDX hidden input field is not found (`VtopError::RegistrationParsingError`)
    fn get_regno(&mut self) -> VtopResult<()> {
        let document = Html::parse_document(&self.current_page.as_ref().ok_or(
            VtopError::ParseError("Current page not found at captcha extration".into()),
        )?);
        let selector = Selector::parse("input[type=hidden][name=authorizedIDX]").unwrap();
        let k = document
            .select(&selector)
            .next()
            .and_then(|element| element.value().attr("value").map(|value| value.to_string()))
            .ok_or(VtopError::RegistrationParsingError)?;

        self.username = k;
        Ok(())
    }

    /// Extracts the CSRF (Cross-Site Request Forgery) token from the page HTML.
    ///
    /// CSRF tokens are security tokens that VTOP uses to prevent unauthorized requests.
    /// This method locates and extracts the token from hidden form fields in the HTML
    /// and stores it in the session manager for use in subsequent requests.
    ///
    /// # Returns
    ///
    /// Returns `Ok(())` if the CSRF token is successfully extracted and stored in the session.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The current page HTML is not available (`VtopError::ParseError`)
    /// - The CSRF token input field is not found in the HTML (`VtopError::ParseError`)
    fn extract_csrf_token(&mut self) -> VtopResult<()> {
        let document = Html::parse_document(&self.current_page.as_ref().ok_or(
            VtopError::ParseError("Current page not found at csrf extration".into()),
        )?);
        let selector = Selector::parse("input[name='_csrf']").unwrap();
        let csrf_token = document
            .select(&selector)
            .next()
            .and_then(|element| element.value().attr("value"))
            .ok_or(VtopError::ParseError("CSRF token not found".to_string()))?;
        self.session.set_csrf_token(csrf_token.to_string());
        Ok(())
    }

    /// Loads the initial VTOP landing page to establish session cookies.
    ///
    /// This is the first step in the authentication flow. It makes a GET request to
    /// the VTOP landing page to establish initial session cookies and retrieve the
    /// base HTML structure needed for subsequent login steps.
    ///
    /// # Returns
    ///
    /// Returns `Ok(())` if the initial page is successfully loaded and stored.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - Network request fails (`VtopError::NetworkError`)
    /// - Server returns a non-success status code (`VtopError::VtopServerError`)
    /// - Failed to read response body (`VtopError::NetworkError`)
    async fn load_initial_page(&mut self) -> VtopResult<()> {
        let url = format!("{}/vtop/open/page", self.config.base_url);
        let response = self
            .client
            .get(url)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        if !response.status().is_success() {
            return Err(VtopError::VtopServerError);
        }
        self.current_page = Some(response.text().await.map_err(map_response_read_error)?);

        Ok(())
    }

    /// Extracts and returns error messages from the login page HTML.
    ///
    /// When login fails, VTOP displays error messages in specific HTML elements.
    /// This method parses the error page to extract these messages and return them
    /// as a descriptive error string.
    ///
    /// # Arguments
    ///
    /// * `data` - The HTML content of the error page
    ///
    /// # Returns
    ///
    /// Returns a string containing the error message extracted from the page.
    /// If no error message is found, returns "Unknown login error".
    fn get_login_page_error(data: &str) -> String {
        let ptext = r#"span.text-danger.text-center[role="alert"]"#;
        let document = Html::parse_document(data);
        let selector = Selector::parse(&ptext).unwrap();
        if let Some(element) = document.select(&selector).next() {
            let error_message = element.text().collect::<Vec<_>>().join(" ");
            error_message.trim().into()
        } else {
            "Unknown login error".into()
        }
    }

    /// Checks if authentication requires OTP by looking for a form with id="securityOtpForm" in the response.
    fn is_otp_required(data: &str) -> bool {
        let form_selector = Selector::parse(r#"form#securityOtpForm"#).unwrap();
        let document = Html::parse_document(data);
        document.select(&form_selector).next().is_some()
    }

    /// Checks if the client has an active authenticated session.
    ///
    /// This method verifies whether the current session is authenticated and valid
    /// for making API requests to VTOP. It should be called before attempting
    /// operations that require authentication.
    ///
    /// # Returns
    ///
    /// Returns `true` if the session is authenticated and active, `false` otherwise.
    ///
    /// # Examples
    ///
    /// ```
    /// # fn example(client: &mut VtopClient) {
    /// if client.is_authenticated() {
    ///     println!("Session is active");
    ///     // Proceed with authenticated operations
    /// } else {
    ///     println!("Need to login first");
    ///     // Call client.login() before making requests
    /// }
    /// # }
    /// ```
    pub fn is_authenticated(&mut self) -> bool {
        self.session.is_authenticated()
    }
}
