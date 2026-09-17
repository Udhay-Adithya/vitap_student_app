use serde::{Deserialize, Serialize};

use super::{session_manager::SessionManager, vtop_client::VtopClient};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VtopConfig {
    pub base_url: String,
    pub timeout_seconds: u64,
    pub user_agent: String,
}

/// User-Agent used when the caller does not supply one.
///
/// VTOP binds a session to the User-Agent that created it, so this has to be a
/// single stable string rather than something chosen per session: anything
/// reusing the session out of process — the in-app VTOP WebView — must be able
/// to send the identical value. It also has to look like a browser someone
/// could plausibly be using. This previously came from `fake_user_agent`, which
/// handed out a different string every session, including malformed relics like
/// a Firefox 3.5 / Opera 10.53 hybrid on Windows XP.
///
/// Callers that know the real device should pass its User-Agent instead; this
/// is the fallback for tools and tests.
/// How many times to reload the login page waiting for its captcha image.
///
/// VTOP serves the login page without the captcha fairly often, especially
/// under load, so a retry is normal rather than exceptional. Exhausting these
/// is a real failure and returns `VtopError::CaptchaRequired`.
pub const MAX_CAPTCHA_RELOAD_ATTEMPTS: usize = 8;

pub const DEFAULT_USER_AGENT: &str = "Mozilla/5.0 (Linux; Android 14; Pixel 7) \
AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36";

impl Default for VtopConfig {
    fn default() -> Self {
        let base_url = "https://vtop.vitap.ac.in".to_string();
        #[cfg(target_arch = "wasm32")]
        {}

        Self {
            base_url: base_url,
            timeout_seconds: 30,
            user_agent: DEFAULT_USER_AGENT.to_string(),
        }
    }
}

pub struct VtopClientBuilder {
    config: VtopConfig,
    session: SessionManager,
}

impl VtopClientBuilder {
    pub fn new() -> Self {
        Self {
            config: VtopConfig::default(),
            session: SessionManager::new(),
        }
    }

    pub fn timeout(mut self, seconds: u64) -> Self {
        self.config.timeout_seconds = seconds;
        self
    }

    /// Identify as this browser for every request on the session.
    ///
    /// Blank input is ignored so a caller that failed to read its own device
    /// falls back to [`DEFAULT_USER_AGENT`] rather than sending an empty header.
    pub fn user_agent(mut self, user_agent: String) -> Self {
        if !user_agent.trim().is_empty() {
            self.config.user_agent = user_agent;
        }
        self
    }

    pub fn build(self, username: String, password: String) -> VtopClient {
        VtopClient::with_config(self.config, self.session, username.to_uppercase(), password)
    }
}
