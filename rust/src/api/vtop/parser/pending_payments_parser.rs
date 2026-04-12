use crate::api::vtop::types::PendingPaymentReceipt;
use scraper::{Html, Selector};

/// Parses pending payment details from an HTML string.
///
/// Extracts rows from a specific table in the HTML and returns a vector of `PendingPayment` structs,
/// each populated with serial number, fee preference number, fee heads, end date, amount, fine,
/// total amount, and a fixed payment status of "Unpaid".
///
/// # Examples
///
/// ```
/// let html = r#"
/// <table class="table table-bordered table-responsive table-hover">
///   <tr>
///     <th>S.No</th><th>FPrefNo</th><th>Fees Heads</th><th>End Date</th>
///     <th>Amount</th><th>Fine</th><th>Total Amount</th><th>Status</th>
///   </tr>
///   <tr>
///     <td>1</td><td>12345</td><td>Tuition</td><td>2024-06-30</td>
///     <td>10000</td><td>0</td><td>10000</td><td>Unpaid</td>
///   </tr>
/// </table>
/// "#;
/// let payments = parse_pending_payments(html.to_string());
/// assert_eq!(payments.len(), 1);
/// assert_eq!(payments[0].payment_status, "Unpaid");
/// ```
pub fn parse_pending_payments(html: String) -> Vec<PendingPaymentReceipt> {
    let doc = Html::parse_document(&html);
    let mut results = Vec::new();

    // Find the main table with pending payments
    let table_selector =
        Selector::parse("table.table.table-bordered.table-responsive.table-hover").unwrap();
    if let Some(table) = doc.select(&table_selector).next() {
        let row_selector = Selector::parse("tr").unwrap();
        // Use "th, td" instead of "td" only because VTOP serves two header formats:
        //   1. Pre-rendered (logged-in) page: header cells are plain <td> styled bold.
        //   2. Thymeleaf template fallback: header cells are proper <th> elements.
        // Selecting only "td" leaves all *_index variables at -1 when <th> is used,
        // so every field would silently return "NA" even though the table is present.
        //
        // Known failure case: if VTOP ever changes a header label (e.g. "SL.NO" to
        // "S.NO"), the match arm won't fire and that column index stays at -1.
        // All affected fields will return "NA" without a panic — which is the
        // intended safe-degradation behaviour, but the caller should treat a
        // result where s_no == "NA" as a schema-mismatch signal.
        let cell_selector = Selector::parse("th, td").unwrap();

        for var in table.select(&row_selector).take(1) {
            let tds: Vec<_> = var.select(&cell_selector).collect();
            let (
                mut s_no_index,
                mut fprefno_index,
                mut fees_heads_index,
                mut end_date_index,
                mut amount_index,
                mut fine_index,
                mut total_amount_index,
            ) = (-1, -1, -1, -1, -1, -1, -1);

            for (i, header) in tds.iter().enumerate() {
                let header_text = header.text().collect::<String>().trim().to_lowercase();
                match header_text.as_str() {
                    "sl.no" => s_no_index = i as isize,
                    "fprefno" => fprefno_index = i as isize,
                    "fees heads" => fees_heads_index = i as isize,
                    "end date" => end_date_index = i as isize,
                    "amount" => amount_index = i as isize,
                    "fine" => fine_index = i as isize,
                    "advance amount" => {}
                    "total amount" => total_amount_index = i as isize,
                    _ => {}
                }
            }

            for row in table.select(&row_selector).skip(1) {
                let tds: Vec<_> = row.select(&cell_selector).collect();
                if !tds.is_empty() {
                    // Safe cell extractor: guards against two failure modes:
                    //   1. index < 0  — column was never found in the header row
                    //      (usize::try_from returns Err for negative values).
                    //   2. index >= tds.len() — data row has fewer cells than the
                    //      header (e.g. a colspan, a missing <td>, or a future schema
                    //      change where VTOP adds a new column only to the header).
                    //      Example: header has 8 cols, but a data row has 5 cells and
                    //      total_amount_index == 7 → without the bounds check this
                    //      would panic with an index-out-of-bounds at runtime.
                    //
                    // Both error paths return "NA" so the struct is still
                    // constructed and callers can detect missing data.
                    let get_cell_text = |index: isize| {
                        usize::try_from(index)
                            .ok()
                            .filter(|&idx| idx < tds.len())
                            .map(|idx| tds[idx].text().collect::<String>().trim().to_string())
                            .unwrap_or_else(|| "NA".to_string())
                    };

                    let s_no = get_cell_text(s_no_index);
                    let fprefno = get_cell_text(fprefno_index);
                    let fees_heads = get_cell_text(fees_heads_index);
                    let end_date = get_cell_text(end_date_index);
                    let amount = get_cell_text(amount_index);
                    let fine = get_cell_text(fine_index);
                    let total_amount = get_cell_text(total_amount_index);

                    // Payment status is always "Unpaid" for pending payments
                    results.push(PendingPaymentReceipt {
                        s_no,
                        fprefno,
                        fees_heads,
                        end_date,
                        amount,
                        fine,
                        //advance_amount,
                        total_amount,
                        payment_status: "Unpaid".to_string(),
                    });
                }
            }
        }
    }

    results
}
