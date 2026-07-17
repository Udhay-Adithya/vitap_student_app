use lib_vtop::api::vtop::parser::timetable_parser::parse_timetable;

/// A trimmed slice of a real Fall 2026-27 VTOP timetable page, kept inline so the
/// test carries no external fixture (and never bloats the shared library).
///
/// It preserves the exact grid layout that exposed the bug:
///   * the course tbody has the CSE4007 Embedded Theory + Embedded Lab rows,
///   * the grid tbody has all four header rows (THEORY Start/End, LAB Start/End)
///     at full width so column indices line up like the real page, plus the FRI
///     THEORY/LAB day pair.
///
/// The theory rows and lab rows carry DIFFERENT timings, so a lab slot that reads
/// its time from the theory row lands on a "-" / wrong value — the exact defect.
fn sample_html() -> String {
    r#"<!DOCTYPE html><html><body><table>
  <tbody>
    <tr><td>2</td><td>General (Semester)</td><td>CSE4007 - Digital Image Processing ( Embedded Theory )</td><td>3 0 0 0 3.0</td><td>-</td><td>Regular</td><td>AP2026272000042</td><td><p>A1+TA1 - </p><p>G17-AB-2</p></td><td>Sucharitha M - SENSE</td></tr>
    <tr><td>3</td><td>General (Semester)</td><td>CSE4007 - Digital Image Processing ( Embedded Lab )</td><td>0 0 2 0 1.0</td><td>-</td><td>Regular</td><td>AP2026272000235</td><td><p>L23+L24 - </p><p>114-AB-2</p></td><td>Sucharitha M - SENSE</td></tr>
  </tbody>
  <tbody>
    <tr><td>THEORY</td><td>Start</td><td>08:00</td><td>09:00</td><td>09:01</td><td>10:00</td><td>10:01</td><td>11:00</td><td>11:01</td><td>12:00</td><td>12:01</td><td>-</td><td>Lunch</td><td>14:00</td><td>14:01</td><td>15:00</td><td>15:01</td><td>16:00</td><td>16:01</td><td>17:00</td><td>17:01</td><td>18:00</td><td>-</td></tr>
    <tr><td>End</td><td>08:50</td><td>09:50</td><td>09:51</td><td>10:50</td><td>10:51</td><td>11:50</td><td>11:51</td><td>12:50</td><td>12:51</td><td>-</td><td>Lunch</td><td>14:50</td><td>14:51</td><td>15:50</td><td>15:51</td><td>16:50</td><td>16:51</td><td>17:50</td><td>17:51</td><td>18:50</td><td>-</td></tr>
    <tr><td>LAB</td><td>Start</td><td>08:00</td><td>08:50</td><td>08:51</td><td>09:50</td><td>09:51</td><td>10:40</td><td>10:41</td><td>11:40</td><td>11:41</td><td>12:30</td><td>Lunch</td><td>14:00</td><td>14:01</td><td>14:50</td><td>14:51</td><td>15:50</td><td>15:51</td><td>16:40</td><td>16:41</td><td>17:40</td><td>18:30</td></tr>
    <tr><td>End</td><td>08:50</td><td>09:40</td><td>09:41</td><td>10:40</td><td>10:41</td><td>11:30</td><td>11:31</td><td>12:30</td><td>12:31</td><td>13:10</td><td>Lunch</td><td>14:50</td><td>14:51</td><td>15:40</td><td>15:41</td><td>16:40</td><td>16:41</td><td>17:30</td><td>17:31</td><td>18:30</td><td>19:10</td></tr>
    <tr><td>FRI</td><td>THEORY</td><td>TCC1</td><td>TB1</td><td>-</td><td>TA1-CSE4007-ETH-G17-AB-2-ALL</td><td>-</td><td>F1</td><td>-</td><td>TE1</td><td>SD2</td><td>-</td><td>Lunch</td><td>C2</td><td>-</td><td>TB2</td><td>-</td><td>TA2</td><td>-</td><td>F2</td><td>-</td><td>TEE2</td><td>-</td></tr>
    <tr><td>LAB</td><td>L19</td><td>L20</td><td>--</td><td>L21</td><td>--</td><td>L22</td><td>--</td><td>L23-CSE4007-ELA-114-AB-2-ALL</td><td>--</td><td>L24-CSE4007-ELA-114-AB-2-ALL</td><td>Lunch</td><td>L49</td><td>--</td><td>L50</td><td>--</td><td>L51</td><td>--</td><td>L52</td><td>--</td><td>L53</td><td>L54</td></tr>
  </tbody>
</table></body></html>"#
    .to_string()
}

#[test]
fn theory_and_lab_slots_use_their_own_timings() {
    let tt = parse_timetable(sample_html());

    let friday = &tt.friday;
    assert_eq!(
        friday.len(),
        2,
        "expected one theory + one lab class on Friday"
    );

    // Theory class TA1 (grid column 4) -> theory timings 10:00 / 10:50.
    let theory = friday
        .iter()
        .find(|c| c.course_type == "ETH")
        .expect("theory class missing");
    assert_eq!(theory.start_time, "10:00");
    assert_eq!(theory.end_time, "10:50");

    // Lab class L23+L24 (grid columns 8 & 10) -> LAB timings 11:40 / 13:10.
    // Before the fix this reused the theory row (12:00 / "-") and produced the
    // broken "-" / "-" class shown on the home screen.
    let lab = friday
        .iter()
        .find(|c| c.course_type == "ELA")
        .expect("lab class missing");
    assert_eq!(lab.start_time, "11:40");
    assert_eq!(lab.end_time, "13:10");
    assert_ne!(lab.start_time, "-");
    assert_ne!(lab.end_time, "-");

    // The two consecutive lab periods collapse into a single class...
    assert_eq!(lab.slot, "L23+L24 -");
    // ...and the slot string carries no stray newline from the multi-line cell.
    assert!(
        !lab.slot.contains('\n'),
        "slot should not contain a newline"
    );
    assert_eq!(lab.venue, "114-AB-2");
    assert_eq!(lab.faculty, "Sucharitha M");
}
