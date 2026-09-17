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
/// Rejects a semester id that is not the shape VTOP uses.
///
/// Every id the portal served on 2026-09-17 was `AP` followed by seven digits:
/// AP2026272, AP2025264, AP2024252, AP2023243 and so on.
///
/// This catches a typo, an empty string, or a semester *name* passed where an
/// id was meant. It deliberately cannot catch an id that is well formed but
/// simply wrong — `AP9999999` passes — because nothing offline can know which
/// ids are real. That matters because **VTOP does not reject an unknown id**:
/// it answers with a normal, empty result, so a stale id from a previous term
/// shows an empty semester rather than an error. Picking a real one from
/// `get_semesters` stays the caller's job.
pub(crate) fn validate_semester_id(
    semester_id: &str,
) -> crate::api::vtop::vtop_errors::VtopResult<()> {
    let (prefix, digits) = semester_id.split_at(semester_id.len().min(2));
    if prefix == "AP" && digits.len() == 7 && digits.bytes().all(|b| b.is_ascii_digit()) {
        return Ok(());
    }
    Err(crate::api::vtop::vtop_errors::VtopError::InvalidSemesterId)
}

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

#[cfg(test)]
mod semester_id_tests {
    use super::validate_semester_id;

    /// Every id VTOP served on 2026-09-17, from a live semester list.
    const REAL: [&str; 8] = [
        "AP2026272",
        "AP2025264",
        "AP2025262",
        "AP2024258",
        "AP2024254",
        "AP2024252",
        "AP2023247",
        "AP2023243",
    ];

    #[test]
    fn every_id_vtop_actually_served_is_accepted() {
        for id in REAL {
            assert!(validate_semester_id(id).is_ok(), "{id} should be accepted");
        }
    }

    #[test]
    fn a_malformed_id_is_refused() {
        for bad in [
            "",           // empty
            "NOPE9999",   // the id I probed VTOP with
            "AP202627",   // six digits
            "AP20262722", // eight digits
            "ap2026272",  // lower case
            "AP2026272 ", // trailing space, the kind a config file adds
            " AP2026272",
            "VL2026272",             // another campus's prefix
            "AP20262A2",             // a letter among the digits
            "Fall Semester 2026-27", // the name rather than the id
            "AP",                    // prefix only
            "A",                     // shorter than the prefix
        ] {
            assert!(
                validate_semester_id(bad).is_err(),
                "{bad:?} should be refused"
            );
        }
    }

    /// Well formed but not a real semester. Nothing offline can know that, and
    /// guessing would reject ids from a term we have not seen — so this passes,
    /// and VTOP answers it with an empty result. That is the documented limit
    /// of this check, not an oversight.
    #[test]
    fn a_well_formed_but_unknown_id_is_deliberately_allowed() {
        assert!(validate_semester_id("AP9999999").is_ok());
    }

    /// A short string must not panic on the split.
    #[test]
    fn a_string_shorter_than_the_prefix_does_not_panic() {
        assert!(validate_semester_id("A").is_err());
        assert!(validate_semester_id("").is_err());
    }
}
