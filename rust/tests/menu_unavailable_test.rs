use lib_vtop::api::vtop::vtop_errors::VtopError;

/// The UI has to be able to say something other than "empty", and to tell a
/// refusal apart from a session problem — the causes and the fixes differ.
///
/// The detection itself is tested next to the predicate in `client/auth.rs`,
/// which stays crate-private so it does not end up on the Dart API surface.
#[test]
fn the_error_carries_something_the_ui_can_show() {
    let err = VtopError::MenuUnavailable;
    assert!(!err.message().is_empty());
    assert_eq!(err.error_type(), "MenuUnavailable");
    assert_ne!(err.error_type(), VtopError::SessionExpired.error_type());
}
