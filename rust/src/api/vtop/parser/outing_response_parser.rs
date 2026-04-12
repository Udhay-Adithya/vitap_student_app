use scraper::{Html, Selector};

/// Parses the HTML response from VTOP outing submission/deletion endpoints.
/// 
/// VTOP returns two types of responses:
/// 1. Weekend outing: Simple span with message like "Weekend Outing Applied Successfully"
/// 2. General outing: SweetAlert modal with h2 tag like "Leave Applied Successfully"
pub fn parse_outing_response(html: String) -> String {
    let document = Html::parse_document(&html);
    
    // First, check for error messages - look for red colored text or error spans
    if let Ok(error_selector) = Selector::parse("span[style*='color: red'], span[style*='color:red'], .error, .alert-danger") {
        for span in document.select(&error_selector) {
            let text = span.text().collect::<String>().trim().to_string();
            if !text.is_empty() {
                return format!("Error: {}", text);
            }
        }
    }
    
    // Try to find weekend outing response (span with green text that actually has content)
    if let Ok(span_selector) = Selector::parse("span.col-md-12[style*='color: green'], span.col-md-12[style*='color:green']") {
        for span in document.select(&span_selector) {
            let text = span.text().collect::<String>().trim().to_string();
            if !text.is_empty() && (
                text.contains("Successfully") || 
                text.contains("Applied") || 
                text.contains("Deleted")
            ) {
                return text;
            }
        }
    }
    
    // Try to find general outing response (SweetAlert h2)
    if let Ok(h2_selector) = Selector::parse("div.sweet-alert h2") {
        for h2 in document.select(&h2_selector) {
            let text = h2.text().collect::<String>().trim().to_string();
            if !text.is_empty() {
                return text;
            }
        }
    }
    
    // Fallback: try any h2 tag with success/error message
    if let Ok(h2_selector) = Selector::parse("h2") {
        for h2 in document.select(&h2_selector) {
            let text = h2.text().collect::<String>().trim().to_string();
            if !text.is_empty() && (
                text.contains("Successfully") || 
                text.contains("Applied") || 
                text.contains("Deleted") ||
                text.contains("Error") ||
                text.contains("Failed")
            ) {
                return text;
            }
        }
    }
    
    // Check if the response is just the form page returned (no success message)
    // This happens when the submission fails silently
    if html.contains("outingForm") && html.contains("Weekend Outing Request") {
        // The form page was returned - this likely means the submission failed
        // Check for any visible error messages in span.col-sm-12 with error styling
        if let Ok(span_selector) = Selector::parse("span.col-sm-12[style*='color'], span.col-md-12[style*='color']") {
            for span in document.select(&span_selector) {
                let text = span.text().collect::<String>().trim().to_string();
                // Skip empty spans and hidden field warnings
                if !text.is_empty() 
                    && !text.contains("disciplinary measures")
                    && !text.contains("logs will be retained")
                {
                    return format!("Error: {}", text);
                }
            }
        }
        return "Submission may have failed - form page was returned. Please check outing history to verify.".to_string();
    }
    
    // If we can't parse a clean message, return a generic error
    "Unable to parse response from server. Please check outing history to verify submission.".to_string()
}
