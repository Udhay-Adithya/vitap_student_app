use lib_vtop::api::vtop::client::auth::is_menu_unavailable;
use lib_vtop::api::vtop::vtop_errors::VtopError;

/// The real refusal, trimmed. VTOP serves this with an HTTP 200, so nothing
/// about the status says anything is wrong, and the fragment used to reach a
/// parser — which returns an empty result for markup it cannot recognise. The
/// screen then showed "no data" with no error and no log line.
const REFUSAL: &str = r#"
    <div class="modal" tabindex="-1" id="msgBox">
      <div class="modal-body">
        <span class="text-danger fw-bold h6" id="msgBoxInfoText">
          This menu is not available at present!!!
        </span>
      </div>
    </div>
"#;

#[test]
fn a_real_refusal_is_recognised() {
    assert!(is_menu_unavailable(REFUSAL));
}

#[test]
fn a_real_page_is_not() {
    assert!(!is_menu_unavailable(
        r#"<table id="AttendanceDetailDataTable"><tr><td>1</td></tr></table>"#
    ));
}

#[test]
fn an_empty_body_is_not() {
    assert!(!is_menu_unavailable(""));
}

/// VTOP writes "!!!" today. Matching them would make this hinge on punctuation
/// that is not load-bearing.
#[test]
fn the_match_does_not_depend_on_the_exclamation_marks() {
    assert!(is_menu_unavailable(
        "<span>This menu is not available at present</span>"
    ));
}

/// The UI has to be able to say something other than "empty", and to tell this
/// apart from a session problem — the causes and the fixes are different.
#[test]
fn the_error_carries_something_the_ui_can_show() {
    let err = VtopError::MenuUnavailable;
    assert!(!err.message().is_empty());
    assert_eq!(err.error_type(), "MenuUnavailable");
    assert_ne!(err.error_type(), VtopError::SessionExpired.error_type());
}
