use crate::api::vtop::{
    parser::course_page_parser,
    types::course_page::*,
    vtop_client::VtopClient,
    vtop_errors::VtopError,
    vtop_errors::VtopResult,
    vtop_errors::{map_reqwest_error, map_response_read_error},
};
use chrono::Utc;

impl VtopClient {
    /// Initializes the Course Page view and returns semester options.
    ///
    /// This method navigates to the Course Page section and returns the initial page.
    /// This should be called first before accessing course page functionality.
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<String>` containing the HTML of the course page.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    pub async fn init_course_page(&mut self) -> VtopResult<String> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let url = format!(
            "{}/vtop/academics/common/StudentCoursePage",
            self.config.base_url
        );

        let body = format!(
            "verifyMenu=true&authorizedID={}&_csrf={}&nocache=@(new Date().getTime())",
            self.username,
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
        );

        let res = self
            .client
            .post(url)
            .body(body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&res).await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        Ok(text)
    }

    /// Retrieves the list of courses available for a specific semester.
    ///
    /// Fetches all courses registered by the student for the given semester that
    /// have course page content (materials, lectures, etc.).
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The semester identifier (e.g., "AP2025264")
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<CoursesResponse>` containing:
    /// - List of courses with their IDs, codes, titles, and types
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The semester ID is invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let courses = client.get_courses_for_course_page("AP2025264").await?;
    /// for course in courses.courses {
    ///     println!("{} - {} ({})", course.course_code, course.course_title, course.course_type);
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_courses_for_course_page(
        &mut self,
        semester_id: &str,
    ) -> VtopResult<CoursesResponse> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let url = format!("{}/vtop/getCourseForCoursePage", self.config.base_url);

        let body = format!(
            "_csrf={}&paramReturnId=getCourseForCoursePage&semSubId={}&authorizedID={}&x={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            semester_id,
            self.username,
            Utc::now().to_rfc2822()
        );

        let res = self
            .client
            .post(url)
            .body(body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&res).await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        Ok(course_page_parser::parse_courses_for_course_page(text))
    }

    /// Retrieves slot and class information for a specific course.
    ///
    /// Fetches available time slots and class entries for a selected course,
    /// including faculty information and class IDs needed for viewing course details.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The semester identifier (e.g., "AP2025264")
    /// * `class_id` - The course class identifier (e.g., "AP2025264000394")
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<SlotsResponse>` containing:
    /// - List of available slots
    /// - List of class entries with faculty and timing information
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The semester ID or class ID is invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let slots = client.get_slots_for_course_page("AP2025264", "AP2025264000394").await?;
    /// for entry in slots.class_entries {
    ///     println!("{} - {} - {}", entry.course_code, entry.slot, entry.faculty);
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_slots_for_course_page(
        &mut self,
        semester_id: &str,
        class_id: &str,
    ) -> VtopResult<SlotsResponse> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let url = format!("{}/vtop/getSlotIdForCoursePage", self.config.base_url);

        let body = format!(
            "_csrf={}&classId={}&praType=source&paramReturnId=getSlotIdForCoursePage&semSubId={}&authorizedID={}&x={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            class_id,
            semester_id,
            self.username,
            Utc::now().to_rfc2822()
        );

        let res = self
            .client
            .post(url)
            .body(body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&res).await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        Ok(course_page_parser::parse_slots_for_course_page(
            text,
            semester_id,
        ))
    }

    /// Retrieves the detailed course page with all lectures and materials.
    ///
    /// Fetches the complete course page including lecture schedule, topics,
    /// and downloadable reference materials for each lecture.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The semester identifier (e.g., "AP2025264")
    /// * `erp_id` - The faculty ERP ID (e.g., "70735")
    /// * `class_id` - The class identifier (e.g., "AP2025264000442")
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<CoursePageDetail>` containing:
    /// - Course information (code, title, faculty, slot, etc.)
    /// - Download paths for syllabus and all materials
    /// - List of lectures with their topics and attached materials
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The provided IDs are invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let detail = client.get_course_detail("AP2025264", "70735", "AP2025264000442").await?;
    /// println!("Course: {} - {}", detail.course_info.course_code, detail.course_info.course_title);
    /// for lecture in detail.lectures {
    ///     println!("  {} - {}", lecture.date, lecture.topic);
    ///     for material in lecture.reference_materials {
    ///         println!("    Material: {}", material.label);
    ///     }
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn get_course_detail(
        &mut self,
        semester_id: &str,
        erp_id: &str,
        class_id: &str,
    ) -> VtopResult<CoursePageDetail> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let url = format!(
            "{}/vtop/processViewStudentCourseDetail",
            self.config.base_url
        );

        let body = format!(
            "_csrf={}&semSubId={}&erpId={}&classId={}&authorizedID={}&x={}",
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            semester_id,
            erp_id,
            class_id,
            self.username,
            Utc::now().to_rfc2822()
        );

        let res = self
            .client
            .post(url)
            .body(body)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&res).await?;

        let text = res.text().await.map_err(map_response_read_error)?;
        Ok(course_page_parser::parse_course_detail_page(text))
    }

    /// Downloads course material (PDF, document, etc.) from the course page.
    ///
    /// Downloads a specific reference material attached to a lecture or
    /// general course materials. The download path should be obtained
    /// from `ReferenceMaterial.download_path` or the course page detail.
    ///
    /// # Arguments
    ///
    /// * `download_path` - The material download path (e.g., "downloadPdf/AP2025264/AP2025264000442/19/10-12-2025")
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<u8>>` containing the file as a byte vector that can be:
    /// - Saved to disk
    /// - Displayed in a PDF viewer
    /// - Shared or printed
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The download path is invalid or the material doesn't exist
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// // Get course detail first
    /// let detail = client.get_course_detail("AP2025264", "70735", "AP2025264000442").await?;
    ///
    /// // Download a specific lecture material
    /// if let Some(lecture) = detail.lectures.first() {
    ///     if let Some(material) = lecture.reference_materials.first() {
    ///         let bytes = client.download_course_material(&material.download_path).await?;
    ///         std::fs::write("material.pdf", bytes)?;
    ///         println!("Material downloaded successfully");
    ///     }
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn download_course_material(&mut self, download_path: &str) -> VtopResult<Vec<u8>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let url = format!(
            "{}/vtop/{}?authorizedID={}&_csrf={}&x={}",
            self.config.base_url,
            download_path,
            self.username,
            self.session
                .get_csrf_token()
                .ok_or(VtopError::SessionExpired)?,
            Utc::now().to_rfc2822()
        );

        let res = self
            .client
            .get(url)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&res).await?;

        let bytes = res.bytes().await.map_err(map_response_read_error)?;
        Ok(bytes.to_vec())
    }

    /// Downloads all materials for a course as a ZIP archive.
    ///
    /// Downloads all reference materials attached to a course in a single ZIP file.
    /// The download path can be found in `CoursePageDetail.download_all_path`.
    ///
    /// # Arguments
    ///
    /// * `download_path` - The bulk download path (e.g., "academics/common/allCourseMeterialDownload/1/1/AP2025264/AP2025264000442")
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<u8>>` containing the ZIP file as a byte vector.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The download path is invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    ///
    /// # Examples
    ///
    /// ```
    /// # async fn example(client: &mut VtopClient) -> Result<(), Box<dyn std::error::Error>> {
    /// let detail = client.get_course_detail("AP2025264", "70735", "AP2025264000442").await?;
    ///
    /// if let Some(download_path) = detail.download_all_path {
    ///     let bytes = client.download_all_course_materials(&download_path).await?;
    ///     std::fs::write("all_materials.zip", bytes)?;
    ///     println!("All materials downloaded");
    /// }
    /// # Ok(())
    /// # }
    /// ```
    pub async fn download_all_course_materials(
        &mut self,
        download_path: &str,
    ) -> VtopResult<Vec<u8>> {
        // This uses the same mechanism as download_course_material
        self.download_course_material(download_path).await
    }

    /// Downloads the course syllabus document.
    ///
    /// Downloads the official syllabus for the course. The download path
    /// can be found in `CoursePageDetail.syllabus_download_path`.
    ///
    /// # Arguments
    ///
    /// * `course_id` - The course ID (e.g., "AM_CSE2009_00110")
    /// * `course_type` - The course type (e.g., "ETH")
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<u8>>` containing the syllabus document as bytes.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The course ID or type is invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    pub async fn download_course_syllabus(
        &mut self,
        course_id: &str,
        course_type: &str,
    ) -> VtopResult<Vec<u8>> {
        let download_path = format!("courseSyllabusDownload/{}/{}", course_id, course_type);
        self.download_course_material(&download_path).await
    }

    /// Downloads the course plan as an Excel file.
    ///
    /// Downloads the complete course plan including lecture schedule in Excel format.
    ///
    /// # Arguments
    ///
    /// * `semester_id` - The semester identifier
    /// * `class_id` - The class identifier
    ///
    /// # Returns
    ///
    /// Returns a `VtopResult<Vec<u8>>` containing the Excel file as bytes.
    ///
    /// # Errors
    ///
    /// This function will return an error if:
    /// - The session is not authenticated (`VtopError::SessionExpired`)
    /// - The IDs are invalid
    /// - Network communication fails (`VtopError::NetworkError`)
    /// - The VTOP server returns an error response (`VtopError::VtopServerError`)
    pub async fn download_course_plan_excel(
        &mut self,
        semester_id: &str,
        class_id: &str,
    ) -> VtopResult<Vec<u8>> {
        if !self.session.is_authenticated() {
            return Err(VtopError::SessionExpired);
        }

        let url = format!(
            "{}/vtop/academics/common/CoursePlanExcelDownload?semesterSubId={}&classId={}&authorizedID={}&x={}",
            self.config.base_url,
            semester_id,
            class_id,
            self.username,
            Utc::now().to_rfc2822()
        );

        let res = self
            .client
            .get(url)
            .send()
            .await
            .map_err(map_reqwest_error)?;

        self.handle_session_check(&res).await?;

        let bytes = res.bytes().await.map_err(map_response_read_error)?;
        Ok(bytes.to_vec())
    }
}
