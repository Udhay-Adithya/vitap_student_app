use lib_vtop::api::vtop::vtop_errors::VtopError;

/// The UI has to be able to say something useful, and to tell this apart from a
/// session problem — the fix is to pick a different semester, not to log in.
///
/// The validator itself is crate-private and tested next to it in
/// `vtop_config.rs`, so it does not end up on the Dart API surface.
#[test]
fn the_error_carries_something_the_ui_can_show() {
    let err = VtopError::InvalidSemesterId;
    assert!(!err.message().is_empty());
    assert!(
        err.message().to_lowercase().contains("semester"),
        "the message should name the semester, got {:?}",
        err.message()
    );
    assert_eq!(err.error_type(), "InvalidSemesterId");
    assert_ne!(err.error_type(), VtopError::SessionExpired.error_type());
}
