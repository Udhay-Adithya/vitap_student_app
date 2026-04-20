use std::sync::Arc;

#[cfg(not(target_arch = "wasm32"))]
use reqwest::cookie::Jar;
pub use reqwest::Response;

use crate::api::vtop::vtop_errors::{VtopError, VtopResult};

#[derive(Debug)]

pub struct SessionManager {
    csrf_token: Option<String>,
    #[cfg(not(target_arch = "wasm32"))]
    cookie_store: Arc<Jar>,
    is_authenticated: bool,
}

impl SessionManager {
    pub fn new() -> Self {
        #[cfg(not(target_arch = "wasm32"))]
        let jar = Jar::default();
        #[cfg(not(target_arch = "wasm32"))]
        let cookie_store = Arc::new(jar);
        Self {
            csrf_token: None,
            #[cfg(not(target_arch = "wasm32"))]
            cookie_store,
            is_authenticated: false,
        }
    }

    pub fn set_csrf_token(&mut self, token: String) {
        self.csrf_token = Some(token);
    }

    pub fn get_csrf_token(&self) -> Option<String> {
        self.csrf_token.clone()
    }
    #[cfg(not(target_arch = "wasm32"))]
    pub fn get_cookie_store(&self) -> Arc<Jar> {
        self.cookie_store.clone()
    }

    pub fn set_authenticated(&mut self, authenticated: bool) {
        self.is_authenticated = authenticated;
    }

    pub fn is_authenticated(&self) -> bool {
        self.is_authenticated
    }

    pub fn clear(&mut self) {
        self.csrf_token = None;
        self.is_authenticated = false;
    }

    pub fn set_csrf_from_external(&mut self, token: String) {
        self.csrf_token = Some(token);
    }

    /// Checks if a response indicates session expiration and handles it.
    ///
    /// # Arguments
    /// * `response` - The HTTP response to check
    ///
    /// # Returns
    /// Returns `Ok(())` if session is still valid, or `Err(VtopError::SessionExpired)` if expired
    pub fn check_session_expiration(&mut self, response: &Response) -> VtopResult<()> {
        if !response.status().is_success() || response.url().to_string().contains("login") {
            self.set_authenticated(false);
            return Err(VtopError::SessionExpired);
        }
        Ok(())
    }

    //  pub fn set_cookie_from_external(&mut self, token: String) {
    //     self.csrf_token = Some(token);

    // }
}
