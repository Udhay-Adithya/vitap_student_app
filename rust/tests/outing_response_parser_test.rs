use lib_vtop::api::vtop::parser::outing_response_parser::parse_outing_response;

    #[test]
    fn test_parse_weekend_outing_success() {
        let html = r#"<span class="col-md-12" style="font-size: 20px; color: green; text-align: center;">Weekend Outing Applied Successfully</span>"#;
        let result = parse_outing_response(html.to_string());
        assert_eq!(result, "Weekend Outing Applied Successfully");
    }

    #[test]
    fn test_parse_general_outing_success() {
        let html = r#"<div class="sweet-alert"><h2>Leave Applied Successfully</h2></div>"#;
        let result = parse_outing_response(html.to_string());
        assert_eq!(result, "Leave Applied Successfully");
    }

    #[test]
    fn test_parse_delete_success() {
        let html = r#"<span class="col-md-12" style="color: green;">Weekend Outing Deleted Successfully</span>"#;
        let result = parse_outing_response(html.to_string());
        assert_eq!(result, "Weekend Outing Deleted Successfully");
    }
    
    #[test]
    fn test_parse_form_page_returned() {
        // When form page is returned, it means submission likely failed
        let html = r#"<html><body><form id="outingForm"><h3>Weekend Outing Request</h3></form></body></html>"#;
        let result = parse_outing_response(html.to_string());
        assert!(result.contains("failed") || result.contains("verify"));
    }
    
    #[test]
    fn test_parse_error_message() {
        let html = r#"<span style="color: red;">Already applied for this date</span>"#;
        let result = parse_outing_response(html.to_string());
        assert!(result.contains("Error:"));
    }
