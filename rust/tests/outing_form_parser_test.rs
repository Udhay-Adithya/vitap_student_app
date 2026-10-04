use lib_vtop::api::vtop::parser::outing_form_parser::parse_outing_form;
use lib_vtop::api::vtop::vtop_errors::VtopError;

/// The student block of the general outing form: read-only inputs VTOP fills
/// in, which the app sends back when applying. Identity is replaced. The page
/// has no parent contact field.
const GENERAL_FORM: &str = r#"
<form class="form-horizontal" id="outingForm" name="outingForm" autocomplete="off">
  <input type="hidden" name="authorizedID" id="authorizedID" value="23BCE0001" />
  <input type="hidden" name="LeaveId" id="LeaveId" value="" />
  <input type="hidden" id="success" value="" />
  <input type="hidden" id="jsonBom" value="" />
  <input class="form-control read-only-input"
    value="23BCE0001" id="regNo" name="regNo"
    readonly />
  <input class="form-control read-only-input"
    value="TEST STUDENT" id="name" name="name" readonly />
  <input class="form-control read-only-input"
    value="2023000001" id="applicationNo"
    name="applicationNo" readonly />
  <input class="form-control read-only-input"
    value="OTHER" id="gender" name="gender" readonly />
  <input class="form-control read-only-input"
    value="MH-1" id="hostelBlock"
    name="hostelBlock" readonly />
  <input class="form-control read-only-input"
    value="101" id="roomNo" name="roomNo" readonly />
  <input class="form-control" value="" id="placeOfVisit" name="placeOfVisit" required maxlength="20" />
  <input class="form-control" value="" id="purposeOfVisit" name="purposeOfVisit" required maxlength="20" />
  <input class="form-control" type="text" id="outDate" name="outDate" placeholder="Select Out Date" required readonly />
  <input class="form-control" type="text" id="inDate" name="inDate" placeholder="Select To Date" required readonly />
</form>
"#;

/// The weekend outing form as VTOP serves it outside its window, captured on a
/// Sunday. Every student field is gone; what is left is the hidden inputs, one
/// of which carries VTOP's own explanation.
const WEEKEND_FORM_OUTSIDE_WINDOW: &str = r#"
<form class="form-horizontal" id="outingForm" name="outingForm" autocomplete="off">
  <input type="hidden" name="authorizedID" id="authorizedID" value="23BCE0001" />
  <input type="hidden" name="BookingId" id="BookingId" value="" />
  <input type="hidden" id="success" value="" />
  <input type="hidden" id="jsonBom" value="You are eligible to fill this form from Tuesday 12:00AM to Friday 11:59PM" />
  <input class="form-control" type="text" id="outTime" name="outTime" readonly />
</form>
"#;

#[test]
fn test_reads_the_prefilled_student_fields() {
    let info = parse_outing_form(GENERAL_FORM.to_string()).unwrap();

    assert_eq!(info.registration_number, "23BCE0001");
    assert_eq!(info.name, "TEST STUDENT");
    assert_eq!(info.application_no, "2023000001");
    assert_eq!(info.gender, "OTHER");
    assert_eq!(info.hostel_block, "MH-1");
    assert_eq!(info.room_number, "101");
}

#[test]
fn test_parent_contact_is_empty_when_the_form_has_no_such_field() {
    let info = parse_outing_form(GENERAL_FORM.to_string()).unwrap();

    assert_eq!(info.parent_contact_number, "");
}

/// Outside its window VTOP still answers with a normal page, just without the
/// student fields. This used to come back as a `ParseError`, which the app
/// showed as "Unable to process server response" — while its handler for this
/// case listened for `RegistrationParsingError`, which only login raises.
#[test]
fn test_weekend_form_served_outside_its_window_is_unavailable() {
    let result = parse_outing_form(WEEKEND_FORM_OUTSIDE_WINDOW.to_string());

    assert!(matches!(result, Err(VtopError::OutingFormUnavailable(_))));
}

/// VTOP says when the form opens; passing that on beats any window the app
/// could state, since the app's idea of the window is what just proved wrong.
#[test]
fn test_unavailable_form_carries_vtops_own_notice() {
    let Err(VtopError::OutingFormUnavailable(notice)) =
        parse_outing_form(WEEKEND_FORM_OUTSIDE_WINDOW.to_string())
    else {
        panic!("expected OutingFormUnavailable");
    };

    assert_eq!(
        notice,
        "You are eligible to fill this form from Tuesday 12:00AM to Friday 11:59PM"
    );
}

#[test]
fn test_unavailable_form_without_a_notice_carries_an_empty_one() {
    let without_notice = WEEKEND_FORM_OUTSIDE_WINDOW.replace(
        "You are eligible to fill this form from Tuesday 12:00AM to Friday 11:59PM",
        "",
    );

    let result = parse_outing_form(without_notice);

    assert!(matches!(result, Err(VtopError::OutingFormUnavailable(n)) if n.is_empty()));
}
