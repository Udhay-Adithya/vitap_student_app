use crate::api::vtop::client::auth::read_body;
use crate::api::vtop::vtop_config::validate_semester_id;
use crate::api::vtop::{
    parser,
    types::*,
    vtop_client::VtopClient,
    vtop_errors::VtopError,
    vtop_errors::VtopResult,
    vtop_errors::{map_reqwest_error, map_response_read_error},
};
use chrono::Utc;
use reqwest::multipart::Form;
use reqwest::multipart::Part;

impl VtopClient {
    /// Retrieves the list of available semesters for the authenticated student.
    ///
    /// This method fetches all semester data including semester IDs, names, and other metadata
    /// that can be used to query semester-specific information like timetables, attendance, and marks.
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<SemesterData>` containing:
    /// - A list of all available semesters with their IDs and descriptions
    /// - Current semester information
    /// - Semester enrollment details
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The CSRF token is missing or invalid (`VtopError::SessionExpired`)
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # use lib_vtop::api::vtop::vtop_client::VtopClient;
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let semester_data = client.get_semesters().await?;
    /// for semester in semester_data.semesters {
    ///     println!("Semester: {} (ID: {})", semester.name, semester.id);
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_semesters(&mut self) -> VtopResult<SemesterData> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        // The semester dropdown appears on several pages, but they are not
        // equally reliable:
        //   - The timetable page lists only the semesters the student actually
        //     has a timetable for. That is the nicest list to show, but it is
        //     empty for freshers (and others) before their timetable is set up,
        //     which surfaced as "No semesters available" at login.
        //   - The marks and exam-schedule pages render the full institutional
        //     semester list server-side, so their dropdown is populated for
        //     anyone who can log in, regardless of their own records.
        //
        // Try the timetable first for the better list, then fall back to the
        // fuller pages so login never dead-ends on an empty semester list.
        const SEMESTER_PAGES: [&str; 3] = [
            "academics/common/StudentTimeTable",
            "examinations/StudentMarkView",
            "examinations/StudExamSchedule",
        ];

        let mut last = SemesterData {
            semesters: Vec::new(),
            update_time: 0,
        };
        for page in SEMESTER_PAGES {
            let data = self.fetch_semesters_from(page).await?;
            if !data.semesters.is_empty() {
                return Ok(data);
            }
            last = data;
        }

        // Every source was empty; return the (empty) last result so the caller
        // can show its "try again later" message rather than an error.
        Ok(last)
    }

    /// Loads a VTOP page and parses its `semesterSubId` dropdown into a
    /// [`SemesterData`]. Used by [`Self::get_semesters`] for each fallback page.
    async fn fetch_semesters_from(&mut self, page_path: &str) -> VtopResult<SemesterData> {
        let url = format!("{}/vtop/{}", self.config.base_url, page_path);
        let body = format!(
            "verifyMenu=true&authorizedID={}&_csrf={}&nocache=@(new Date().getTime())",
            self.username,
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
        );
        let res = self.post_form_with_session_retry(url, body).await?;

        let text = read_body(res).await?;
        Ok(parser::semested_id_parser::parse_semid_from_timetable(text))
    }

    /// Retrieves the complete timetable for a specific semester.
    ///
    /// Fetches the weekly class schedule including course details, timings, venues,
    /// faculty information, and class types (Theory/Lab/Tutorial) for the specified semester.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester (obtained from `get_semesters()`)
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Timetable>` containing:
    /// - Weekly schedule organized by days and time slots
    /// - Course codes, names, and types
    /// - Venue and room information
    /// - Faculty names assigned to each course
    /// - Slot timings and duration
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The provided semester ID is invalid or not found
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # use lib_vtop::api::vtop::vtop_client::VtopClient;
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let semesters = client.get_semesters().await?;
    /// if let Some(current_sem) = semesters.semesters.first() {
    ///     let timetable = client.get_timetable(&current_sem.id).await?;
    ///     println!("Monday classes: {:?}", timetable.monday);
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_timetable(&mut self, semester_id: &str) -> VtopResult<Timetable> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        validate_semester_id(semester_id)?;
        let url = format!("{}/vtop/processViewTimeTable", self.config.base_url);
        let body = format!(
            "_csrf={}&semesterSubId={}&authorizedID={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            semester_id,
            self.username
        );
        let res = self.post_form_with_session_retry(url, body).await?;
        let text = read_body(res).await?;
        Ok(parser::timetable_parser::parse_timetable(text))
    }

    /// Retrieves the attendance summary for all courses in a specific semester.
    ///
    /// Fetches attendance statistics for each registered course including total classes,
    /// attended classes, and attendance percentage. This provides an overview of attendance
    /// across all courses without detailed session-by-session breakdown.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester (obtained from `get_semesters()`)
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<AttendanceRecord>>` containing a vector of attendance records where each record includes:
    /// - Course code and name
    /// - Course type (Theory/Lab/Tutorial)
    /// - Total number of classes conducted
    /// - Number of classes attended
    /// - Attendance percentage
    /// - Faculty name
    /// - Slot information
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The provided semester ID is invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # use lib_vtop::api::vtop::vtop_client::VtopClient;
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let attendance = client.get_attendance("AP2026272").await?;
    /// for record in attendance {
    ///     println!(
    ///         "{}: {}% ({}/{})",
    ///         record.course_name,
    ///         record.attendance_percentage,
    ///         record.attended_classes,
    ///         record.total_classes
    ///     );
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_attendance(&mut self, semester_id: &str) -> VtopResult<Vec<AttendanceRecord>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        validate_semester_id(semester_id)?;
        let url = format!("{}/vtop/processViewStudentAttendance", self.config.base_url);
        let body = format!(
            "_csrf={}&semesterSubId={}&authorizedID={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            semester_id,
            self.username
        );
        let res = self.post_form_with_session_retry(url, body).await?;
        let text = read_body(res).await?;
        Ok(parser::attendance_parser::parse_attendance(text))
    }

    /// Retrieves detailed attendance records for a specific course.
    ///
    /// Fetches session-by-session attendance details for a particular course, including
    /// individual class dates, timings, attendance status, and any remarks. This provides
    /// a granular view of attendance beyond the summary statistics.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester
    /// * `course_id` - The course code (e.g., "CSE1001", "MAT2001")
    /// * `course_type` - The type of course ("Theory", "Lab", "Embedded Theory", "Embedded Lab", etc.)
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<AttendanceDetailRecord>>` containing detailed attendance information:
    /// - Date and time of each class session
    /// - Attendance status (Present/Absent/OD/Medical Leave)
    /// - Session number and slot information
    /// - Faculty who took the class
    /// - Any remarks or notes for the session
    /// - Topic covered in the session
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The provided semester ID, course ID, or course type is invalid
    /// - The student is not registered for the specified course
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # use lib_vtop::api::vtop::vtop_client::VtopClient;
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // The course id and type code come from a `get_attendance` record.
    /// let details = client
    ///     .get_attendance_detail("AP2026272", "AM_CSE3009_00200", "ETH")
    ///     .await?;
    ///
    /// for session in details {
    ///     println!(
    ///         "{} {} | {} | {}",
    ///         session.date, session.slot, session.status, session.remark
    ///     );
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_attendance_detail(
        &mut self,
        semester_id: &str,
        course_id: &str,
        course_type: &str,
    ) -> VtopResult<Vec<AttendanceDetailRecord>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        validate_semester_id(semester_id)?;
        let url = format!("{}/vtop/processViewAttendanceDetail", self.config.base_url);
        let timestamp = Utc::now().format("%a, %d %b %Y %H:%M:%S GMT").to_string();
        let body = format!(
            "_csrf={}&semesterSubId={}&registerNumber={}&courseId={}&courseType={}&authorizedID={}&x={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            semester_id,
            self.username,
            course_id,
            course_type,
            self.username,
            timestamp
        );
        let res = self.post_form_with_session_retry(url, body).await?;
        let text = read_body(res).await?;
        Ok(parser::attendance_parser::parse_full_attendance(text))
    }
    /// Retrieves the capstone/SDP attendance for a semester.
    ///
    /// This is not per-course attendance: it covers the single capstone or SDP
    /// registration a final-year student has, and VTOP tracks it as a daily
    /// punch rather than as classes attended out of classes held.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester.
    ///
    /// # Returns
    ///
    /// Returns `Ok(None)` when the response carries no attendance summary,
    /// which is what a student with no capstone registration gets. Otherwise
    /// returns the registration details, the present/on-duty/absent tally and
    /// the day-by-day punch calendar, all of which arrive in this one response.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    pub async fn get_capstone_attendance(
        &mut self,
        semester_id: &str,
    ) -> VtopResult<Option<CapstoneAttendance>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        validate_semester_id(semester_id)?;
        let url = format!("{}/vtop/processSdpAttendance", self.config.base_url);
        let timestamp = Utc::now().format("%a, %d %b %Y %H:%M:%S GMT").to_string();
        let body = format!(
            "_csrf={}&semesterSubId={}&regNo={}&authorizedID={}&x={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            semester_id,
            self.username,
            self.username,
            timestamp
        );
        let res = self.post_form_with_session_retry(url, body).await?;
        let text = read_body(res).await?;
        Ok(parser::capstone_attendance_parser::parse_capstone_attendance(text))
    }

    /// Retrieves course attendance and, when the student has one, the
    /// capstone/SDP attendance alongside it.
    ///
    /// The attendance page itself says whether a capstone exists — it renders a
    /// "View CAPSTONE/SDP Attendance" button only for students who have one —
    /// so the second request is made only when that button is present.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester.
    ///
    /// # Returns
    ///
    /// Returns the course records and the capstone attendance, the latter being
    /// `None` for the majority of students who have no capstone registration.
    ///
    /// # Errors
    ///
    /// Fails under the same conditions as [`Self::get_attendance`]. A failure
    /// while fetching the capstone is *not* one of them: the course records are
    /// already parsed and correct at that point, so a capstone failure degrades
    /// to `None` rather than losing the whole page.
    pub async fn get_attendance_with_capstone(
        &mut self,
        semester_id: &str,
    ) -> VtopResult<(Vec<AttendanceRecord>, Option<CapstoneAttendance>)> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        validate_semester_id(semester_id)?;
        let url = format!("{}/vtop/processViewStudentAttendance", self.config.base_url);
        let body = format!(
            "_csrf={}&semesterSubId={}&authorizedID={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            semester_id,
            self.username
        );
        let res = self.post_form_with_session_retry(url, body).await?;
        let text = read_body(res).await?;

        let has_capstone = parser::attendance_parser::has_capstone_attendance(&text);
        let records = parser::attendance_parser::parse_attendance(text);

        let capstone = if has_capstone {
            // Course attendance is already parsed and correct; do not let a
            // capstone failure take it down with it.
            self.get_capstone_attendance(semester_id)
                .await
                .unwrap_or(None)
        } else {
            None
        };

        Ok((records, capstone))
    }

    /// Retrieves marks and assessment scores for all courses in a specific semester.
    ///
    /// Fetches detailed marks information including CAT (Continuous Assessment Test) scores,
    /// assignment marks, quiz scores, and final assessment marks for each registered course.
    /// This provides comprehensive academic performance data for the semester.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester (obtained from `get_semesters()`)
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<Marks>>` containing marks information for each course:
    /// - Course code, name, and credits
    /// - CAT 1, CAT 2, and other periodic test scores
    /// - Assignment and quiz marks
    /// - Digital assignment scores
    /// - Final assessment marks
    /// - Total marks obtained and maximum marks
    /// - Grade status and evaluation status
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The provided semester ID is invalid
    /// - Marks have not been published for the semester
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # use lib_vtop::api::vtop::vtop_client::VtopClient;
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let marks = client.get_marks("AP2026272").await?;
    /// for course in marks {
    ///     println!("{} - {}", course.course_code, course.course_title);
    ///     // Each assessment VTOP has published for the course.
    ///     for assessment in course.details {
    ///         println!(
    ///             "  {}: {}/{}",
    ///             assessment.mark_title, assessment.scored_mark, assessment.max_mark
    ///         );
    ///     }
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_marks(&mut self, semester_id: &str) -> VtopResult<Vec<Marks>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        validate_semester_id(semester_id)?;
        let url = format!(
            "{}/vtop/examinations/doStudentMarkView",
            self.config.base_url
        );
        let authorizedid_v = self.username.clone();
        let semestersubid_v = semester_id.to_string();
        let res = self
            .post_multipart_with_session_retry(url, |csrf| {
                Form::new()
                    .text("authorizedID", authorizedid_v.clone())
                    .text("semesterSubId", semestersubid_v.clone())
                    .text("_csrf", csrf.to_string())
            })
            .await?;

        let text = read_body(res).await?;

        Ok(parser::marks_parser::parse_marks(text))
    }

    /// Retrieves the examination schedule for all courses in a specific semester.
    ///
    /// Fetches comprehensive exam schedule information including exam dates, timings,
    /// venues, exam types, and seating arrangements for all registered courses in the semester.
    /// This helps students plan and prepare for upcoming examinations.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester (obtained from `get_semesters()`)
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<PerExamScheduleRecord>>` containing exam details for each course:
    /// - Course code and name
    /// - Exam type (CAT-1, CAT-2, FAT, Mid-term, End-term, etc.)
    /// - Exam date and time
    /// - Duration of the examination
    /// - Exam venue and room number
    /// - Seating arrangement details (row, column, seat number)
    /// - Slot information
    /// - Any special instructions or requirements
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The provided semester ID is invalid
    /// - Exam schedule has not been published yet
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    /// - Session expires during the request and re-authentication fails
    ///
    /// # Examples
    ///
    /// ```
    /// # use lib_vtop::api::vtop::vtop_client::VtopClient;
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let schedule = client.get_exam_schedule("AP2026272").await?;
    /// // Grouped per exam — CAT1, CAT2, FAT — each with its own courses.
    /// for exam in schedule {
    ///     println!("{}", exam.exam_type);
    ///     for course in exam.subjects {
    ///         println!(
    ///             "  {} on {} at {}",
    ///             course.course_name, course.exam_date, course.exam_time
    ///         );
    ///         // Both read "-" until seats are allocated.
    ///         println!("  Venue: {}, Seat: {}", course.venue, course.seat_number);
    ///     }
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_exam_schedule(
        &mut self,
        semester_id: &str,
    ) -> VtopResult<Vec<PerExamScheduleRecord>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        validate_semester_id(semester_id)?;
        let url = format!(
            "{}/vtop/examinations/doSearchExamScheduleForStudent",
            self.config.base_url
        );
        let authorizedid_v = self.username.clone();
        let semestersubid_v = semester_id.to_string();
        let res = self
            .post_multipart_with_session_retry(url, |csrf| {
                Form::new()
                    .text("authorizedID", authorizedid_v.clone())
                    .text("semesterSubId", semestersubid_v.clone())
                    .text("_csrf", csrf.to_string())
            })
            .await?;
        let text = read_body(res).await?;
        Ok(parser::exam_schedule_parser::parse_schedule(text))
    }

    /// Retrieves the digital assignments for all courses in a specific semester.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The unique identifier for the semester (obtained from `get_semesters()`)
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<DigitalAssignments>>` containing a vector of digital assignments
    /// where each assignment includes course code, title, type, faculty name, class ID, and
    /// a list of assignment details (title, due date, submission status, marks).
    pub async fn get_all_digital_assignments(
        &mut self,
        semester_id: &str,
    ) -> VtopResult<Vec<DigitalAssignments>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        validate_semester_id(semester_id)?;
        let url = format!(
            "{}/vtop/examinations/doDigitalAssignment",
            self.config.base_url
        );
        let authorizedid_v = self.username.clone();
        let semestersubid_v = semester_id.to_string();
        let res = self
            .post_multipart_with_session_retry(url, |csrf| {
                Form::new()
                    .text("authorizedID", authorizedid_v.clone())
                    .text("semesterSubId", semestersubid_v.clone())
                    .text("_csrf", csrf.to_string())
            })
            .await?;
        let text = read_body(res).await?;
        let mut assignments = parser::digital_assignment_parser::parse_all_assignments(text);
        for assignment in &mut assignments {
            assignment.details = self
                .get_per_course_dassignments(&assignment.class_id)
                .await?;
        }
        Ok(assignments)
    }

    /// Retrieves the digital assignments for a specific course.
    ///
    /// # Arguments
    ///
    /// * `class_id` - The unique identifier for the class (obtained from `get_all_digital_assignments()`)
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<AssignmentRecordEach>>` containing assignment details including
    /// serial number, title, due date, submission status, marks, and weightage.
    pub async fn get_per_course_dassignments(
        &mut self,
        class_id: &str,
    ) -> VtopResult<Vec<AssignmentRecordEach>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!(
            "{}/vtop/examinations/processDigitalAssignment",
            self.config.base_url
        );
        let timestamp = Utc::now().format("%a, %d %b %Y %H:%M:%S GMT").to_string();
        let body = format!(
            "authorizedID={}&x={}&classId={}&_csrf={}",
            self.username,
            urlencoding::encode(&timestamp),
            class_id,
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
        );
        let res = self.post_form_with_session_retry(url, body).await?;
        let text = read_body(res).await?;
        Ok(parser::digital_assignment_parser::parse_per_course_dassignments(text))
    }

    /// Retrieves the PDF bytes of a digital assignment or question paper.
    ///
    /// The PDF is fetched the same way as a hostel leave pass.
    ///
    /// Question paper download URL format:
    ///
    /// ```text
    /// examinations/doDownloadQuestion/{Experiment-1 || DA01 || AST01}/{classId}
    ///     ?authorizedID=2XBCEXXXXX
    ///     &_csrf=XXXX-baba-XXXX-a95e-b1937c33c4XXc
    ///     &x=Sun,%2025%20Jan%202026%2004:24:59%20GMT
    /// ```
    ///
    /// Digital assignment download URL format (the timestamp is URL-encoded):
    ///
    /// ```text
    /// examinations/downloadSTudentDA/{Experiment-1 || DA01 || AST01}/{classId}
    ///     ?authorizedID=2XBCEXXXXX
    ///     &_csrf=XXXX-baba-XXXX-a95e-b1937c33c4XXc
    ///     &x=Sun,%2025%20Jan%202026%2004:24:59%20GMT
    /// ```
    ///
    /// # Arguments
    ///
    /// * `da_qp_download_url` - The download URL of the digital assignment or question paper.
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<u8>>` containing the PDF bytes.
    pub async fn get_da_or_qp_pdf(&mut self, da_qp_download_url: String) -> VtopResult<Vec<u8>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }
        let url = format!(
            "{}/vtop/{}?authorizedID={}&_csrf={}&x={}",
            self.config.base_url,
            da_qp_download_url,
            self.username,
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            urlencoding::encode(&chrono::Utc::now().to_rfc2822())
        );

        let res = self.get_with_session_retry(url).await?;

        let bytes = res.bytes().await.map_err(map_response_read_error)?;
        Ok(bytes.to_vec())
    }

    pub async fn process_upload_course_dassignment(
        &mut self,
        class_id: &str,
        mode: &str,
    ) -> VtopResult<Vec<Vec<String>>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        // This method call is required due to a server-side restriction, not to retrieve any information.
        // Without calling `examinations/processDigitalAssignment` with this specific `class_id` in the request body,
        // the server will not accept upload requests.
        let pre_request_url = format!(
            "{}/vtop/examinations/processDigitalAssignment",
            self.config.base_url
        );
        let mut timestamp = Utc::now().format("%a, %d %b %Y %H:%M:%S GMT").to_string();
        let pre_request_body = format!(
            "authorizedID={}&x={}&classId={}&_csrf={}",
            self.username,
            urlencoding::encode(&timestamp),
            class_id,
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
        );
        self.client
            .post(pre_request_url)
            .body(pre_request_body)
            .send()
            .await
            .map_err(map_reqwest_error)?;
        // self.get_per_course_dassignments(class_id).await?;
        // Proceed to upload after the above call.

        let url = format!(
            "{}/vtop/examinations/processDigitalAssignmentUpload",
            self.config.base_url
        );
        timestamp = Utc::now().format("%a, %d %b %Y %H:%M:%S GMT").to_string();
        let body = format!(
            "authorizedID={}&x={}&classId={}&mode={}&_csrf={}",
            self.username,
            urlencoding::encode(&timestamp),
            class_id,
            mode,
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
        );
        let res = self.post_form_with_session_retry(url, body).await?;
        let text = read_body(res).await?;
        Ok(parser::digital_assignment_parser::parse_process_upload_assignment_response(text))
    }

    pub async fn upload_course_dassignment(
        &mut self,
        class_id: &str,
        mode: &str,
        file_name: String,
        file_bytes: Vec<u8>,
    ) -> VtopResult<String> {
        if file_name.is_empty() || file_bytes.is_empty() {
            return Err(VtopError::DigitalAssignmentFileNotFound);
        }
        if !(file_name.ends_with(".pdf")
            || file_name.ends_with(".docx")
            || file_name.ends_with(".doc")
            || file_name.ends_with(".xls")
            || file_name.ends_with(".xlsx"))
        {
            return Err(VtopError::DigitalAssignmentFileTypeNotSupported);
        }
        if file_bytes.len() > 4 * 1024 * 1024 {
            return Err(VtopError::DigitalAssignmentFileSizeExceeded);
        }

        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let process_vectors = self
            .process_upload_course_dassignment(class_id, mode)
            .await?;
        let upload_url = format!(
            "{}/vtop/examinations/doDAssignmentUploadMethod",
            self.config.base_url
        );
        let mut upload_form = Form::new().text("authorizedID", self.username.clone());
        for (code, opt) in process_vectors[0].iter().zip(&process_vectors[1]) {
            upload_form = upload_form.text("code", code.clone());
            upload_form = upload_form.text("opt", opt.clone());
        }
        let mime = match file_name.rsplit('.').next().unwrap_or("") {
            "pdf" => "application/pdf",
            "doc" => "application/msword",
            "docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "xls" => "application/vnd.ms-excel",
            "xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            _ => "application/octet-stream",
        };
        let file_part = Part::bytes(file_bytes)
            .file_name(file_name)
            .mime_str(mime)
            .unwrap();
        upload_form = upload_form
            .part("studDaUpload", file_part)
            .text(
                "_csrf",
                self.session
                    .get_csrf_token()
                    .ok_or(VtopError::SessionExpired)?,
            )
            .text("classId", class_id.to_string())
            .text("mCode", mode.to_string());
        let res = self
            .client
            .post(upload_url)
            .multipart(upload_form)
            .send()
            .await
            .map_err(map_reqwest_error)?;
        // Check for session expiration and auto re-authenticate if needed
        self.handle_session_check(&res).await?;
        let text = read_body(res).await?;
        let result = parser::digital_assignment_parser::parse_upload_assignment_response(text);
        if result == "OTP Required" {
            // Callback for OTP verification
            // OTP input is required from the user
            // The error `VtopError::DigitalAssignmentUploadOtpRequired` should be handled.
            // When the `DigitalAssignmentUploadOtpRequired` error occurs,
            // a call should be made to `upload_course_dassignment_otp` with the user-provided OTP.
            Err(VtopError::DigitalAssignmentUploadOtpRequired)
        } else {
            Ok(result)
        }
    }

    pub async fn upload_course_dassignment_otp(&mut self, otp_email: &str) -> VtopResult<String> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let url = format!(
            "{}/vtop/examinations/doDAssignmentOtpUpload",
            self.config.base_url
        );
        // Deliberately not retried after a re-login: this submits an OTP, and
        // replaying a write risks sending it twice. An expired session stays an
        // error here, which is the safe outcome.
        let form = Form::new()
            .text("authorizedID", self.username.clone())
            .text("otpEmail", otp_email.to_string())
            .text(
                "_csrf",
                self.session
                    .get_csrf_token()
                    .ok_or(VtopError::SessionExpired)?,
            );

        let res = self
            .client
            .post(url)
            .multipart(form)
            .send()
            .await
            .map_err(map_reqwest_error)?;
        self.handle_session_check(&res).await?;

        let text = read_body(res).await?;
        let result = parser::digital_assignment_parser::parse_upload_assignment_response(text);
        if result == "Invalid OTP. Please try again." {
            // OTP was incorrect.
            // Need to call again upload_course_dassignment_otp with correct OTP.
            Err(VtopError::DigitalAssignmentUploadIncorrectOtp)
        } else {
            Ok(result)
        }
    }
}
