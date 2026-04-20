use crate::api::vtop::{
    types::{
        ComprehensiveDataResponse, FacultyDetails, GetFaculty, GradeHistory, Marks, SemesterData,
    },
    vtop_client::{VtopClient, VtopError},
    vtop_config::VtopClientBuilder,
};

#[flutter_rust_bridge::frb(sync)]
pub fn get_vtop_client(username: String, password: String) -> VtopClient {
    VtopClientBuilder::new().build(username, password)
}

#[flutter_rust_bridge::frb()]
pub async fn vtop_client_login(client: &mut VtopClient) -> Result<(), VtopError> {
    client.login().await
}
#[flutter_rust_bridge::frb()]
pub async fn fetch_semesters(client: &mut VtopClient) -> Result<SemesterData, VtopError> {
    client.get_semesters().await
}

/// Fetches comprehensive student data including profile, attendance, timetable,
/// exam schedule, grade history, and marks for a specific semester.
///
/// This function consolidates multiple API calls into a single request, providing
/// all essential student data in one response structure.
///
/// # Returns
/// A serialized JSON string containing all student data on success, or a `VtopError` on failure.
#[flutter_rust_bridge::frb()]
pub async fn fetch_all_data(
    client: &mut VtopClient,
    semester_id: String,
) -> Result<String, VtopError> {
    // Fetch all data sequentially due to Rust borrowing rules
    let profile = client.get_student_profile().await?;
    let attendance = client.get_attendance(&semester_id).await?;
    let timetable = client.get_timetable(&semester_id).await?;
    let exam_schedule = client.get_exam_schedule(&semester_id).await?;
    let marks = client.get_marks(&semester_id).await?;

    let comprehensive_data = ComprehensiveDataResponse {
        profile,
        attendance,
        timetable,
        exam_schedule,
        marks,
    };

    serde_json::to_string(&comprehensive_data).map_err(|e| {
        VtopError::ParseError(format!("Failed to serialize comprehensive data: {}", e))
    })
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_attendance(
    client: &mut VtopClient,
    semester_id: String,
) -> Result<String, VtopError> {
    let attendance_records = client.get_attendance(&semester_id).await?;
    serde_json::to_string(&attendance_records)
        .map_err(|e| VtopError::ParseError(format!("Failed to serialize attendance data: {}", e)))
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_attendance_detail(
    client: &mut VtopClient,
    semester_id: String,
    course_id: String,
    course_type: String,
) -> Result<String, VtopError> {
    let attendance_detail_records = client
        .get_attendance_detail(&semester_id, &course_id, &course_type)
        .await?;
    serde_json::to_string(&attendance_detail_records).map_err(|e| {
        VtopError::ParseError(format!(
            "Failed to serialize detailed attendance data: {}",
            e
        ))
    })
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_timetable(
    client: &mut VtopClient,
    semester_id: String,
) -> Result<String, VtopError> {
    let timetable = client.get_timetable(&semester_id).await?;
    serde_json::to_string(&timetable)
        .map_err(|e| VtopError::ParseError(format!("Failed to serialize timetable data: {}", e)))
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_marks(
    client: &mut VtopClient,
    semester_id: String,
) -> Result<String, VtopError> {
    let marks_record: Vec<Marks> = client.get_marks(&semester_id).await?;
    serde_json::to_string(&marks_record)
        .map_err(|e| VtopError::ParseError(format!("Failed to serialize marks data: {}", e)))
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_exam_shedule(
    client: &mut VtopClient,
    semester_id: String,
) -> Result<String, VtopError> {
    let exam_schedule_records = client.get_exam_schedule(&semester_id).await?;
    serde_json::to_string(&exam_schedule_records).map_err(|e| {
        VtopError::ParseError(format!("Failed to serialize exam schedule data: {}", e))
    })
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_cookies(client: &mut VtopClient) -> Result<Vec<u8>, VtopError> {
    client.get_cookie().await.clone()
}

#[flutter_rust_bridge::frb()]
pub fn fetch_csrf_token(client: &VtopClient) -> Option<String> {
    client.session.get_csrf_token()
}

#[flutter_rust_bridge::frb()]
pub fn fetch_username(client: &VtopClient) -> String {
    client.username.clone()
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_is_auth(client: &mut VtopClient) -> bool {
    client.is_authenticated().clone()
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_biometric_data(
    client: &mut VtopClient,
    date: String,
) -> Result<String, VtopError> {
    let biometric_records = client.get_biometric_data(date).await?;
    serde_json::to_string(&biometric_records)
        .map_err(|e| VtopError::ParseError(format!("Failed to serialize biometric data: {}", e)))
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_faculty_search(
    client: &mut VtopClient,
    search_term: String,
) -> Result<GetFaculty, VtopError> {
    client.get_faculty_search(search_term).await
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_faculty_data(
    client: &mut VtopClient,
    emp_id: String,
) -> Result<FacultyDetails, VtopError> {
    client.get_faculty_data(emp_id).await
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_all_faculty(client: &mut VtopClient) -> Result<String, VtopError> {
    let faculty_list = client.get_all_faculty().await?;
    serde_json::to_string(&faculty_list)
        .map_err(|e| VtopError::ParseError(format!("Failed to serialize faculty list: {}", e)))
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_weekend_outing_reports(client: &mut VtopClient) -> Result<String, VtopError> {
    let weekend_outing_records = client.get_weekend_outing_reports().await?;
    serde_json::to_string(&weekend_outing_records).map_err(|e| {
        VtopError::ParseError(format!("Failed to serialize weekend outing data: {}", e))
    })
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_weekend_outing_pdf(
    client: &mut VtopClient,
    booking_id: String,
) -> Result<Vec<u8>, VtopError> {
    client.get_hostel_outing_pdf(booking_id).await
}

#[flutter_rust_bridge::frb()]
pub async fn submit_general_outing_form(
    client: &mut VtopClient,
    out_place: String,
    purpose_of_visit: String,
    outing_date: String,
    out_time: String,
    in_date: String,
    in_time: String,
) -> Result<String, VtopError> {
    client
        .submit_general_outing_form(
            out_place,
            purpose_of_visit,
            outing_date,
            out_time,
            in_date,
            in_time,
        )
        .await
}

#[flutter_rust_bridge::frb()]
pub async fn submit_weekend_outing_form(
    client: &mut VtopClient,
    out_place: String,
    purpose_of_visit: String,
    outing_date: String,
    out_time: String,
    contact_number: String,
) -> Result<String, VtopError> {
    client
        .submit_weekend_outing_form(
            out_place,
            purpose_of_visit,
            outing_date,
            out_time,
            contact_number,
        )
        .await
}

#[flutter_rust_bridge::frb()]
pub async fn delete_general_outing(
    client: &mut VtopClient,
    leave_id: String,
) -> Result<String, VtopError> {
    client.delete_general_outing(leave_id).await
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_general_outing_reports(client: &mut VtopClient) -> Result<String, VtopError> {
    let general_outing_reports = client.get_general_outing_reports().await?;
    serde_json::to_string(&general_outing_reports).map_err(|e| {
        VtopError::ParseError(format!("Failed to serialize weekend outing data: {}", e))
    })
}

/// Downloads the PDF report for a specific hostel leave request.
///
/// Returns the PDF file as a byte vector if successful, or a `VtopError` on failure.
///
/// # Examples
///
/// ```
/// let pdf_bytes = leave_report_download(&mut client, "LEAVE123".to_string()).await?;
/// assert!(!pdf_bytes.is_empty());
/// ```
#[flutter_rust_bridge::frb()]
pub async fn fetch_general_outing_pdf(
    client: &mut VtopClient,
    leave_id: String,
) -> Result<Vec<u8>, VtopError> {
    client.get_general_outing_pdf(leave_id).await
}

/// Deletes a weekend outing booking from VTOP.
///
/// Cancels a previously submitted weekend outing booking.
///
/// # Examples
///
/// ```
/// let response = delete_weekend_outing(&mut client, "W24044341477".to_string()).await?;
/// ```
#[flutter_rust_bridge::frb()]
pub async fn delete_weekend_outing(
    client: &mut VtopClient,
    booking_id: String,
) -> Result<String, VtopError> {
    client.delete_weekend_outing(booking_id).await
}

/// Retrieves the complete student profile for the authenticated user.
///
/// Returns a `StudentProfile` containing detailed profile information on success, or a `VtopError` if the operation fails.
///
/// # Examples
///
/// ```
/// let mut client = get_vtop_client("username".to_string(), "password".to_string());
/// let profile = student_profile(&mut client).await.unwrap();
/// assert_eq!(profile.name, "John Doe");
/// ```
#[flutter_rust_bridge::frb()]
pub async fn fetch_student_profile(client: &mut VtopClient) -> Result<String, VtopError> {
    let student_prof = client.get_student_profile().await?;
    serde_json::to_string(&student_prof).map_err(|e| {
        VtopError::ParseError(format!("Failed to serialize student profile data: {}", e))
    })
}

/// Retrieves the student's overall grade history and detailed course-wise grade records.
///
/// Returns a `GradeHistory` struct containing the student's grade history summary and course grade histories.
///
/// # Examples
///
/// ```
/// let grade_history = fetch_grade_history(&mut client).await.unwrap();
/// assert!(!grade_history.courses.is_empty());
/// ```
#[flutter_rust_bridge::frb()]
pub async fn fetch_grade_history(client: &mut VtopClient) -> Result<GradeHistory, VtopError> {
    client.get_grade_history().await
}

/// Retrieves a list of pending payments for the student.
///
/// Returns a vector of `PendingPaymentReceipt` records on success, or a `VtopError` if the operation fails.
///
/// # Examples
///
/// ```
/// let payments = student_pending_payments(&mut client).await?;
/// assert!(!payments.is_empty() || payments.is_empty());
/// ```
#[flutter_rust_bridge::frb()]
pub async fn fetch_pending_payments(client: &mut VtopClient) -> Result<String, VtopError> {
    let pending_payment_records = client.get_pending_payment().await?;
    serde_json::to_string(&pending_payment_records).map_err(|e| {
        VtopError::ParseError(format!("Failed to serialize pending payments data: {}", e))
    })
}

#[flutter_rust_bridge::frb()]
pub async fn fetch_payment_receipts(client: &mut VtopClient) -> Result<String, VtopError> {
    let payment_receipts_record = client.get_payment_receipts().await?;
    serde_json::to_string(&payment_receipts_record).map_err(|e| {
        VtopError::ParseError(format!("Failed to serialize pending payments data: {}", e))
    })
}

/// Downloads a specific payment receipt as a PDF file.
#[flutter_rust_bridge::frb()]
pub async fn student_payment_receipt_download(
    client: &mut VtopClient,
    receipt_no: String,
    applno: String,
) -> Result<String, VtopError> {
    client.download_payment_receipt(receipt_no, applno).await
}

// ============================================================================
// Course Page Functions
// ============================================================================

/// Initializes the Course Page view.
///
/// This should be called first before accessing course page functionality.
///
/// # Examples
///
/// ```
/// let html = init_course_page(&mut client).await?;
/// ```
#[flutter_rust_bridge::frb()]
pub async fn init_course_page(client: &mut VtopClient) -> Result<String, VtopError> {
    client.init_course_page().await
}

/// Retrieves the list of courses available for a specific semester on the course page.
///
/// # Examples
///
/// ```
/// let courses = fetch_courses_for_course_page(&mut client, "AP2025264".to_string()).await?;
/// for course in courses.courses {
///     println!("{} - {}", course.course_code, course.course_title);
/// }
/// ```
#[flutter_rust_bridge::frb()]
pub async fn fetch_courses_for_course_page(
    client: &mut VtopClient,
    semester_id: String,
) -> Result<String, VtopError> {
    let courses_response = client.get_courses_for_course_page(&semester_id).await?;
    serde_json::to_string(&courses_response)
        .map_err(|e| VtopError::ParseError(format!("Failed to serialize courses data: {}", e)))
}

/// Retrieves slot and class information for a specific course.
///
/// # Examples
///
/// ```
/// let slots = fetch_slots_for_course_page(&mut client, "AP2025264".to_string(), "AP2025264000394".to_string()).await?;
/// for entry in slots.class_entries {
///     println!("{} - {} ({})", entry.course_code, entry.slot, entry.erp_id);
/// }
/// ```
#[flutter_rust_bridge::frb()]
pub async fn fetch_slots_for_course_page(
    client: &mut VtopClient,
    semester_id: String,
    class_id: String,
) -> Result<String, VtopError> {
    let slots_response = client
        .get_slots_for_course_page(&semester_id, &class_id)
        .await?;
    serde_json::to_string(&slots_response)
        .map_err(|e| VtopError::ParseError(format!("Failed to serialize slots data: {}", e)))
}

/// Retrieves the detailed course page with all lectures and materials.
///
/// This fetches the complete course page including lecture schedule, topics,
/// and downloadable reference materials for each lecture.
///
/// # Examples
///
/// ```
/// let detail = fetch_course_detail(&mut client, "AP2025264".to_string(), "70735".to_string(), "AP2025264000442".to_string()).await?;
/// ```
#[flutter_rust_bridge::frb()]
pub async fn fetch_course_detail(
    client: &mut VtopClient,
    semester_id: String,
    erp_id: String,
    class_id: String,
) -> Result<String, VtopError> {
    let course_detail = client
        .get_course_detail(&semester_id, &erp_id, &class_id)
        .await?;
    serde_json::to_string(&course_detail)
        .map_err(|e| VtopError::ParseError(format!("Failed to serialize course detail: {}", e)))
}

/// Downloads course material (PDF, document, etc.) from the course page.
///
/// The download path should be obtained from the course detail response
/// (e.g., from `ReferenceMaterial.download_path`).
///
/// # Examples
///
/// ```
/// let bytes = download_course_material(&mut client, "downloadPdf/AP2025264/AP2025264000442/19/10-12-2025".to_string()).await?;
/// std::fs::write("material.pdf", bytes)?;
/// ```
#[flutter_rust_bridge::frb()]
pub async fn download_course_material(
    client: &mut VtopClient,
    download_path: String,
) -> Result<Vec<u8>, VtopError> {
    client.download_course_material(&download_path).await
}

/// Downloads all materials for a course as a ZIP archive.
///
/// # Examples
///
/// ```
/// let bytes = download_all_course_materials(&mut client, "academics/common/allCourseMeterialDownload/1/1/AP2025264/AP2025264000442".to_string()).await?;
/// std::fs::write("all_materials.zip", bytes)?;
/// ```
#[flutter_rust_bridge::frb()]
pub async fn download_all_course_materials(
    client: &mut VtopClient,
    download_path: String,
) -> Result<Vec<u8>, VtopError> {
    client.download_all_course_materials(&download_path).await
}

/// Downloads the course syllabus document.
///
/// # Examples
///
/// ```
/// let bytes = download_course_syllabus(&mut client, "AM_CSE2009_00110".to_string(), "ETH".to_string()).await?;
/// std::fs::write("syllabus.pdf", bytes)?;
/// ```
#[flutter_rust_bridge::frb()]
pub async fn download_course_syllabus(
    client: &mut VtopClient,
    course_id: String,
    course_type: String,
) -> Result<Vec<u8>, VtopError> {
    client
        .download_course_syllabus(&course_id, &course_type)
        .await
}

/// Downloads the course plan as an Excel file.
///
/// # Examples
///
/// ```
/// let bytes = download_course_plan_excel(&mut client, "AP2025264".to_string(), "AP2025264000442".to_string()).await?;
/// std::fs::write("course_plan.xlsx", bytes)?;
/// ```
#[flutter_rust_bridge::frb()]
pub async fn download_course_plan_excel(
    client: &mut VtopClient,
    semester_id: String,
    class_id: String,
) -> Result<Vec<u8>, VtopError> {
    client
        .download_course_plan_excel(&semester_id, &class_id)
        .await
}
///Fetch all digital assignments for a specific semester.

#[flutter_rust_bridge::frb()]
pub async fn fetch_digital_assignments(
    client: &mut VtopClient,
    semester_id: String,
) -> Result<String, VtopError> {
    let digital_assignment_records = client.get_all_digital_assignments(&semester_id).await?;
    serde_json::to_string(&digital_assignment_records).map_err(|e| {
        VtopError::ParseError(format!(
            "Failed to serialize digital assignments data: {}",
            e
        ))
    })
}

#[flutter_rust_bridge::frb()]
pub async fn upload_digital_assignment(
    client: &mut VtopClient,
    class_id: String,
    mode: String,
    file_name: String,
    file_bytes: Vec<u8>,
) -> Result<String, VtopError> {
    let upload_dassignment = client
        .upload_course_dassignment(&class_id, &mode, file_name, file_bytes)
        .await?;
    return Ok(upload_dassignment);
}

#[flutter_rust_bridge::frb()]
pub async fn upload_digital_assignment_with_otp(
    client: &mut VtopClient,
    otp_email: String,
) -> Result<String, VtopError> {
    let upload_dassignment = client.upload_course_dassignment_otp(&otp_email).await?;
    return Ok(upload_dassignment);
}

/// Downloads a digital assignment file (question paper or submitted document).
///
/// The download URL format differs from course material downloads:
///   - Question paper: `examinations/doDownloadQuestion/{code}/{classId}`
///   - Submitted DA:   `examinations/downloadSTudentDA/{code}/{classId}`
///
/// # Examples
///
/// ```
/// let bytes = download_digital_assignment(&mut client, "examinations/doDownloadQuestion/Experiment-1/AP2025264000697".to_string()).await?;
/// std::fs::write("question_paper.pdf", bytes)?;
/// ```
#[flutter_rust_bridge::frb()]
pub async fn download_digital_assignment(
    client: &mut VtopClient,
    download_url: String,
) -> Result<Vec<u8>, VtopError> {
    client.get_da_or_qp_pdf(download_url).await
}

#[flutter_rust_bridge::frb()]
pub async fn handle_login_otp(client: &mut VtopClient, otp_code: String) -> Result<(), VtopError> {
    client.verify_login_otp(&otp_code).await
}

#[flutter_rust_bridge::frb()]
pub async fn handle_login_otp_resend(client: &mut VtopClient) -> Result<(), VtopError> {
    client.resend_login_otp().await
}
