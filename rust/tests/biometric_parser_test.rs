use lib_vtop::api::vtop::parser::parse_biometric::parse_biometric_data;

/// A trimmed biometric response for one day, newest punch first, as VTOP
/// returns it. The venue names follow VTOP's scheme; times and venues are
/// replaced.
const PUNCHES: &str = r#"
<div class=" form-groups" id="getStudBioList">
  <strong id="infomsg" style="color: red;"></strong>
  <div>
  </div>
  <div style="float: left; width: 100%">
    <div class="col-sm-8" style="margin: auto; float: none;">
      <table class="table table-bordered" style="border-color: #3c8dbc;">
        <tr style="background-color: #3c8dbc; color: #fff;">
          <td><b>Sl.No</b></td>
          <td><b>Punch
              Date </b></td>
          <td><b>Punch
              Time </b></td>
          <td><b>Venue
              </b></td>
        </tr>
        <tr>
          <td align="center">1</td>
          <td>07/07/2026</td>
          <td>20:05</td>
          <td>MH1-FACE-IN-1</td>
        </tr>
        <tr>
          <td align="center">2</td>
          <td>07/07/2026</td>
          <td>16:10</td>
          <td>MH1-FACE-OUT-5</td>
        </tr>
        <tr>
          <td align="center">3</td>
          <td>07/07/2026</td>
          <td>08:41</td>
          <td>AB1-FACE-IN-2</td>
        </tr>
      </table>
    </div>
  </div>
</div>
"#;

/// What VTOP sends for a day with no punches: the same fragment, with a
/// message where the table would be.
const NO_RECORDS: &str = r#"
<div class=" form-groups" id="getStudBioList">
  <strong id="infomsg" style="color: red;"></strong>
  <div>
    <strong id="infomsg" style="color: red;">No
      Record(S) Found</strong>
  </div>
  <div style="float: left; width: 100%">
    <div class="col-sm-8" style="margin: auto; float: none;">
    </div>
  </div>
</div>
"#;

#[test]
fn test_parses_each_punch_in_the_order_vtop_sends_them() {
    let records = parse_biometric_data(PUNCHES.to_string());

    assert_eq!(records.len(), 3);
    assert_eq!(records[0].serial, "1");
    assert_eq!(records[0].date, "07/07/2026");
    assert_eq!(records[0].in_time, "20:05");
    assert_eq!(records[0].location, "MH1-FACE-IN-1");
    assert_eq!(records[2].in_time, "08:41");
}

/// VTOP reports single punches, not in/out pairs, so the paired fields stay
/// empty rather than being guessed.
#[test]
fn test_leaves_the_paired_fields_empty() {
    let records = parse_biometric_data(PUNCHES.to_string());

    assert!(records
        .iter()
        .all(|r| r.day.is_empty() && r.out_time.is_empty() && r.duration.is_empty()));
}

#[test]
fn test_day_with_no_punches_yields_nothing() {
    assert!(parse_biometric_data(NO_RECORDS.to_string()).is_empty());
}
