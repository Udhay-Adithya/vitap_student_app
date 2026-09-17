use lib_vtop::api::vtop::session_manager::SessionManager;

/// Builds a `reqwest::Response` with the given status, without a network call.
///
/// The URL cannot be set this way — it comes from the request — so these cover
/// the status arm of the check. The "redirected to /login" arm needs a real
/// request and is left to the live path.
fn response(status: u16) -> reqwest::Response {
    reqwest::Response::from(http::Response::builder().status(status).body("").unwrap())
}

/// An expired CSRF token does not redirect to the login page: VTOP's stack
/// refuses the request before it is routed, and Tomcat answers with a bare 404.
/// Retrying after a re-login hangs off this being recognised as an expiry.
#[test]
fn a_404_is_treated_as_an_expired_session() {
    let mut session = SessionManager::new();
    session.set_authenticated(true);

    assert!(session.check_session_expiration(&response(404)).is_err());
    assert!(
        !session.is_authenticated(),
        "an expiry must clear the authenticated flag, or the next call skips the login"
    );
}

#[test]
fn a_server_error_is_also_treated_as_an_expired_session() {
    let mut session = SessionManager::new();
    session.set_authenticated(true);

    assert!(session.check_session_expiration(&response(500)).is_err());
}

#[test]
fn a_normal_response_leaves_the_session_alone() {
    let mut session = SessionManager::new();
    session.set_authenticated(true);

    assert!(session.check_session_expiration(&response(200)).is_ok());
    assert!(session.is_authenticated());
}

/// VTOP answers a refused request with a 200 and a "menu is not available"
/// body, so the status alone cannot tell that apart. It is not a session
/// problem and must not trigger a re-login; detecting it is tracked separately.
#[test]
fn a_200_is_never_an_expiry_whatever_the_body_says() {
    let mut session = SessionManager::new();
    session.set_authenticated(true);

    assert!(session.check_session_expiration(&response(200)).is_ok());
    assert!(session.is_authenticated());
}
