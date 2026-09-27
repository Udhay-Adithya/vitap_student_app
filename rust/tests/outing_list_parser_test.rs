use lib_vtop::api::vtop::parser::hostel::general_outing_parser::parse_hostel_leave;
use lib_vtop::api::vtop::parser::hostel::weekend_outing_parser::parse_weekend_outing;

/// VTOP indents its markup with tabs and wraps the status text mid-phrase, so
/// a status cell's text really is "Outing\n\t\t\t…Request Accepted". The
/// fixtures below splice this in to keep that whitespace byte-for-byte: the
/// parser drops tabs and turns the newline into a space, and whether a weekend
/// outpass can be downloaded hangs on the result matching exactly.
const WRAP: &str = "\n\t\t\t\t\t\t\t\t\t\t";

/// A trimmed general outing page: the header row (`th` cells), a pending
/// request with no outpass, and an accepted one whose outpass link carries the
/// leave id. Places, dates and ids are replaced.
fn general_outing_page() -> String {
    format!(
        r#"
<table id="BookingRequests">
  <tr>
    <th>S.No</th>
    <th>Registration Number</th>
    <th>Place Of Visit</th>
    <th>Purpose Of Visit</th>
    <th>From Date</th>
    <th>From Time</th>
    <th>To Date</th>
    <th>To Time</th>
    <th>Action</th>
    <th>Status</th>
    <th>Download OutPass</th>
  </tr>
  <tr>
    <td>1</td>
    <td>23BCE0001</td>
    <td>Vijayawada </td>
    <td>Shopping </td>
    <td>2025-01-12 00:00:00.0</td>
    <td>12:00 PM</td>
    <td>2025-01-12 00:00:00.0</td>
    <td>07:00 PM</td>
    <td>
    </td>
    <td>
      <span>   <span{WRAP}style="color: red;">Waiting for{WRAP}Warden's Approval</span>
      </span>
    </td>
    <td>
    </td>
  </tr>
  <tr>
    <td>2</td>
    <td>23BCE0001</td>
    <td>Chennai</td>
    <td>Family Function</td>
    <td>2024-09-06 00:00:00.0</td>
    <td>04:00 PM</td>
    <td>2024-09-10 00:00:00.0</td>
    <td>04:00 PM</td>
    <td>
    </td>
    <td>
      <span>   <span{WRAP}style="color: green;">Leave{WRAP}Request Accepted</span>
      </span>
    </td>
    <td>
      <span> <a href="javascript:void(0);" class="btn btn-primary btn-success"
          onclick="vtopDownload(this.getAttribute('data-url'))" data-url="/vtop/hostel/downloadLeavePass/L2000001"> <span><i
              class="bi bi-cloud-arrow-down-fill"></i></span>
        </a>
      </span>
    </td>
  </tr>
</table>
"#
    )
}

/// A trimmed weekend outing page in the eleven-column layout VTOP serves
/// today: an accepted request with a current-style id, a pending one, and an
/// accepted one from 2023 with an older id format.
fn weekend_outing_page() -> String {
    format!(
        r#"
<table id="BookingRequests">
  <tr>
    <th>S.No</th>
    <th>Registration Number</th>
    <th>Hostel Block</th>
    <th>Room Number</th>
    <th>Place Of Visit</th>
    <th>Purpose Of Visit</th>
    <th>Time</th>
    <th>Date</th>
    <th>Action</th>
    <th>Status</th>
    <th>Download OutPass</th>
  </tr>
  <tr>
    <td>1</td>
    <td>23BCE0001</td>
    <td>MH-1</td>
    <td>101</td>
    <td>Vijayawada</td>
    <td>Shopping</td>
    <td>10:30 AM- 4:30PM</td>
    <td>2026-07-26</td>
    <td>
    </td>
    <td>
      <span>  <span style="color: green;">Outing{WRAP}Request Accepted</span>
      </span>
    </td>
    <td>
      <span>
        <a href="javascript:void(0);" class="btn btn-primary btn-success"
          onclick="vtopDownload(this.getAttribute('data-leave-url'))" data-leave-url="/vtop/hostel/downloadOutingForm/W26000000001">
          <span class="glyphicon glyphicon-download-alt">&nbsp;Download</span>
        </a>
      </span>
    </td>
  </tr>
  <tr>
    <td>2</td>
    <td>23BCE0001</td>
    <td>MH-1</td>
    <td>101</td>
    <td>Guntur</td>
    <td>Movie</td>
    <td>11:30 AM- 5:30PM</td>
    <td>2026-08-02</td>
    <td>
    </td>
    <td>
      <span>  <span style="color: red;">Waiting for{WRAP}Warden's Approval</span>
      </span>
    </td>
    <td>
    </td>
  </tr>
  <tr>
    <td>3</td>
    <td>23BCE0001</td>
    <td>MH-4</td>
    <td>202</td>
    <td>Vijayawada</td>
    <td>To buy essentials</td>
    <td>9:30 AM- 3:30PM</td>
    <td>2023-11-05</td>
    <td>
    </td>
    <td>
      <span>  <span style="color: green;">Outing{WRAP}Request Accepted</span>
      </span>
    </td>
    <td>
      <span>
        <a href="javascript:void(0);" class="btn btn-primary btn-success"
          onclick="vtopDownload(this.getAttribute('data-leave-url'))" data-leave-url="/vtop/hostel/downloadOutingForm/2023WL0000001">
          <span class="glyphicon glyphicon-download-alt">&nbsp;Download</span>
        </a>
      </span>
    </td>
  </tr>
</table>
"#
    )
}

#[test]
fn test_general_reads_every_column_of_a_request() {
    let records = parse_hostel_leave(general_outing_page());

    assert_eq!(records.len(), 2);
    let pending = &records[0];
    assert_eq!(pending.serial, "1");
    assert_eq!(pending.registration_number, "23BCE0001");
    assert_eq!(pending.place_of_visit, "Vijayawada");
    assert_eq!(pending.purpose_of_visit, "Shopping");
    assert_eq!(pending.from_date, "2025-01-12 00:00:00.0");
    assert_eq!(pending.from_time, "12:00 PM");
    assert_eq!(pending.to_date, "2025-01-12 00:00:00.0");
    assert_eq!(pending.to_time, "07:00 PM");
}

#[test]
fn test_general_status_is_read_as_one_line() {
    let records = parse_hostel_leave(general_outing_page());

    assert_eq!(records[0].status, "Waiting for Warden's Approval");
    assert_eq!(records[1].status, "Leave Request Accepted");
}

#[test]
fn test_general_leave_id_comes_from_the_outpass_link() {
    let records = parse_hostel_leave(general_outing_page());

    assert!(!records[0].can_download);
    assert_eq!(records[0].leave_id, "");
    assert!(records[1].can_download);
    assert_eq!(records[1].leave_id, "L2000001");
}

#[test]
fn test_weekend_reads_every_column_of_a_request() {
    let records = parse_weekend_outing(weekend_outing_page());

    assert_eq!(records.len(), 3);
    let first = &records[0];
    assert_eq!(first.serial, "1");
    assert_eq!(first.registration_number, "23BCE0001");
    assert_eq!(first.hostel_block, "MH-1");
    assert_eq!(first.room_number, "101");
    assert_eq!(first.place_of_visit, "Vijayawada");
    assert_eq!(first.purpose_of_visit, "Shopping");
    assert_eq!(first.time, "10:30 AM- 4:30PM");
    assert_eq!(first.date, "2026-07-26");
    assert_eq!(first.status, "Outing Request Accepted");
}

/// The eleven-column layout has no contact number columns. Reading them by the
/// fourteen-column positions would put the date and status in their place.
#[test]
fn test_weekend_eleven_column_layout_has_no_contact_numbers() {
    let records = parse_weekend_outing(weekend_outing_page());

    assert!(records
        .iter()
        .all(|r| r.contact_number.is_empty() && r.parent_contact_number.is_empty()));
}

/// Only an accepted request offers an outpass, and the check compares the
/// status text exactly — so it only works if the tab-wrapped status comes out
/// as "Outing Request Accepted".
#[test]
fn test_weekend_outpass_is_offered_only_for_accepted_requests() {
    let records = parse_weekend_outing(weekend_outing_page());

    assert!(records[0].can_download);
    assert_eq!(records[0].booking_id, "W26000000001");
    assert!(!records[1].can_download);
    assert_eq!(records[1].booking_id, "");
}

#[test]
fn test_weekend_keeps_the_older_booking_id_format() {
    let records = parse_weekend_outing(weekend_outing_page());

    assert!(records[2].can_download);
    assert_eq!(records[2].booking_id, "2023WL0000001");
}

#[test]
fn test_page_without_the_requests_table_yields_nothing() {
    let no_table = "<div id=\"main-section\"><form id=\"outingForm\"></form></div>";

    assert!(parse_hostel_leave(no_table.to_string()).is_empty());
    assert!(parse_weekend_outing(no_table.to_string()).is_empty());
}
