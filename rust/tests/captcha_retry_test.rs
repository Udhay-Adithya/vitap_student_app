use lib_vtop::api::vtop::vtop_config::MAX_CAPTCHA_RELOAD_ATTEMPTS;
use lib_vtop::api::vtop::vtop_errors::VtopError;

/// VTOP serves the login page without its captcha image fairly often, so the
/// reload is normal. Exhausting it is not, and used to return `Ok(())` — the
/// caller was told the page had loaded and the login went on with no captcha,
/// failing later for an unrelated-looking reason.
#[test]
fn the_reload_budget_is_a_sane_number() {
    assert!(
        (2..=16).contains(&MAX_CAPTCHA_RELOAD_ATTEMPTS),
        "a budget of {MAX_CAPTCHA_RELOAD_ATTEMPTS} is either too few to absorb \
         a flaky page or enough to hammer the portal"
    );
}

/// The error the exhausted loop now returns has to survive the trip to Dart,
/// so both its message and its code must be populated.
#[test]
fn captcha_required_reaches_the_ui_with_something_to_show() {
    let err = VtopError::CaptchaRequired;

    let message = err.message();
    assert!(!message.is_empty());
    assert!(
        message.to_lowercase().contains("captcha"),
        "the message should name the captcha, got {message:?}"
    );

    assert_eq!(err.error_type(), "CaptchaRequired");
}

/// A distinct code matters: this is what tells the app to offer a retry rather
/// than treating it as bad credentials.
#[test]
fn captcha_required_is_not_confused_with_a_login_failure() {
    assert_ne!(
        VtopError::CaptchaRequired.error_type(),
        VtopError::SessionExpired.error_type()
    );
}
