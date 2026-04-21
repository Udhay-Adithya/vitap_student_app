# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.3] - 2026-04-22

### Fixed

- Migrated TLS backend from `native-tls` (OpenSSL) to pure-Rust `rustls` to fix Android cross-compilation failure
- Replaced broken `rustls-platform-verifier` custom cert loading with a manually configured `ClientConfig` that includes Mozilla's trusted root store and the pinned VTOP Sectigo intermediate CA, restoring proper TLS certificate verification

## [2.3.2] - 2026-04-21

### Added

- Detailed account-locked instruction sheet shown when incorrect password is entered and the account is locked
- Pull-to-refresh support on timetable, attendance, marks, exam schedule, and payment pages
- OTP-based two-factor authentication support (Thanks to [@tarun-ainampudi](https://github.com/tarun-ainampudi))([#21](https://github.com/VITAP-Student-Project/vitap_student_app/pull/21))
- Faculty page re-introduced

### Changed

- Outing and exam schedule pages now use a unified tab bar style for visual consistency
- Wiredash feedback prompt frequency increased from 30 to 60 days
- Migrated iOS app lifecycle to UIScene
- Updated Rust dependencies

### Fixed

- Fixed contributors sheet failing to load intermittently
- Fixed pending payments always appearing empty due to a parsing issue (Thanks to [@tarun-ainampudi](https://github.com/tarun-ainampudi))([#16](https://github.com/VITAP-Student-Project/vitap_student_app/pull/16))
- Scoped SSL certificate bypass to the VTOP domain only, reducing the certificate trust surface
- Added HTML attribute escaping in the webview form builder to prevent injection via dynamic values

### Removed

- Direct VTOP login feature temporarily removed

## [2.3.1] - 2026-03-05

### Changed

- Onboarding image size is now dynamic based on device height
- Replaced Supabase with a custom backend for managing the For You section
- Exam schedule now auto-refreshes when the page is opened
- Reduced Cocoa theme intensity

### Added

- Download notifications for course and assignment materials with tap-to-open support
- Digital Assignments feature with upload, update, and download assignment support(Thanks to [@tarun-ainampudi](https://github.com/tarun-ainampudi))([#11](https://github.com/VITAP-Student-Project/vitap_student_app/pull/11))
- Changelog page in the app
- App contributors credits bottom sheet in the app footer

### Fixed

- Fixed For You section card height
- Fixed Google Analytics on Android which was accidentally removed
- Fixed TLS certificate issue by adding certificates to the trust store(Thanks to [@synaptic-gg](https://github.com/synaptic-gg))([#13](https://github.com/VITAP-Student-Project/vitap_student_app/pull/13))
- Added percentage symbol to deficit attendance percentage display

### Removed

- Unused university WiFi implementation from the Rust layer
- Unused bypass WiFi FAQ entry
- Remaining university and hostel WiFi related features
- Faculty Page

## [2.3.0] - 2026-01-22

### Added

- New Course page with course material downloading support
- A serial number column in the detailed attendance table

### Removed

- Campus Wi-Fi implementation

## [2.2.3] - 2026-01-18

### Changed

- App data is now cleared on uninstall

### Added

- Projects component marks tab in marks page

### Fixed

- Fixed day-wise attendance view not working in attendance page
- Fixed scroll issue in outing tabs
- Fixed VTOP web view SSL certificate issue (Thanks to [@synaptic-gg](https://github.com/synaptic-gg))([#10](https://github.com/VITAP-Student-Project/vitap_student_app/pull/10))

### Removed

- Hostel WiFi implementation as Sophos login is no longer required

## [2.2.2] - 2025-12-13

### Changed

- Improved error handling across the app
- Improved outing UI with field validators instead of snackbars
- Capitalize first letter in weekend outing fields

### Added

- Mentor details tab in profile page

### Fixed

- Fixed weekend outing not getting applied
- Fixed attendance page error due to removal of CAT1/CAT2 attendance column in VTOP
- Fixed in-app update not working
- Fixed TLS/SSL certificate issue with VTOP
- Fixed font scale slider

### Removed

- Bypass option for weekend outings

## [2.2.0] - 2025-12-11

### Changed

- Exam Schedule page now defaults to sorting by upcoming exam date
- Outing reports page now defaults to sorting by date
- Replaced date of birth with semester name in profile (semester names are now cached)
- Improved outing reports page UI
- Silent refresh of attendance data in the background

### Added

- New Settings page with comprehensive app configuration options
- Four new app themes: Cocal, Nightfall, Sakura, and Vaporwave
- Fallback 20-minute timer for home screen widget before switching to next class
- Reset notification option in settings page
- Developer debug settings section in settings page
- About page
- Button in home page to open VTOP directly from app
- Download notifications for outing report PDFs to open files directly
- Cached outing receipts for faster access
- Search bar in outing reports page
- Seat number display in Exam Schedule
- Attendance debar status indicator in attendance page
- Attendance warning for courses below 75%
- Filters for lab and theory courses in marks and attendance page

### Fixed

- Fixed CTA button in For You pages which was previously unclickable
- Fixed iOS Home Screen Widget always showing "No Upcoming class"
- Fixed download location for outing report PDFs
- Fixed issue with weekend parser during weekends that prevented downloading outing reports
- Fixed hostel wifi error messages to be more user-friendly
- Fixed typo in uv index warning description

## [2.1.6] - 2025-08-29

### Changed

- Updated username validation to allow spaces in registration numbers

### Added

- "Report an Issue" button to login page for better user support

### Fixed

- Fixed semester selection error where users would see generic "error" message after selecting semester and pressing continue

## [2.1.5] - 2025-08-28

### Changed

- Day-wise attendance tab now instantly displays day wise data
- Day-wise attendance now displays On-duty in blue color
- Made refresh button more user friendly across all pages
- Reduced timeout time for university wifi and hostel wifi

### Added

- Emergency announcement feature in the homepage
- University wifi user limit bypass instruction
- Share button in Grade History page to share grades
- AWS website to For You section
- External CGPA Calculator support

### Fixed

- Biometrics log page fix where biometric data not available instantly for the present day
- Loss of user data due to VTOP client session expiration
- Restored full screen (status bar on top and bottom) for iOS devices
- Attendance day-wise not displayed for few courses due to incorrect course type

## [2.1.4] - 2025-08-02

### Added

- Smart Wifi feature
- Faculty name display in home page classes view
- Slot information in timetable view
- PDF viewer for outing documents
- Improved app-wide analytics

### Fixed

- Missing course names for some courses
- Downloaded outing PDF visibility in files app for iOS and Android
- Local data duplication issue
- iPhone home screen widget functionality

## [2.1.3] - 2025-07-24

### Changed

- Minor ui and performance improvements

### Fixed

- Issue with data not stored locally in some cases.

## [2.1.2] - 2025-07-20

### Fixed

- Incorrect faculty names in timetable

## [2.1.1] - 2025-07-20

### Changed

- Reduced response time by 40%
- Improved FAQ Page questions
- Enhanced developer footer by fetching dev profile pic from github
- User login flow

### Added

- Add search button and filter in Grade history page
- Add [@sanjay7178](https://github.com/sanjay7178) to the developer footer
- Add Weekend/General Outing Page with support to download outing reports

### Removed

- Mentor page for now from quick access.

## [2.1.0] - 2025-07-18

### Changed

- Integrate rust library 'lib_vtop' to parse data locally

### Added

- Added day wise attendance detailed view to attendance page
- Added course wise grade history page
- Added support for new semester

### Fixed

- Fixed issue with attendance page being empty in some cases
- Fixed an with login due to pfp not available
- Fixed issue with feedback pop up not being closed

## [2.0.6] - 2025-06-20

### Changed

- minor updates in hostel wifi page

### Added

- Added tooltip for Sync option in account page

### Fixed

- Fixed issue with profile picture not being persisted after app being closed.
- Fixed an with timetable notifications where timeslot is shown instead of time delay

---

## [2.0.5] - 2025-06-19

### Changed

- Navigating with the bottom nav bar now always takes back to the Home screen to prevent accidental app exits.
- Increased timeout duration for better performance on slower connections.
- Updated backend URL for improved stability and faster responses.

### Added

- Added support for in-app update prompts
- New sync reminder dialog — get prompted to sync after changing semester.
- Added support for custom profile pictures

---

## [2.0.4] - 2025-06-08

### Changed

- Improved clarity of error messages

### Fixed

- Fixed issue with class timetable notification not expanding properly

### Added

- Added a helpful tip for using Privacy Mode
- Added tooltip for Privacy Mode

---

## [2.0.3] - 2025-06-01

### Changed

- Improved exam schedule page ui
- Sort daily schedule in timetable page

### Added

- Add Manage Credentials Page
- Add payment receipts and pending payments page

---

## [2.0.2] - 2025-06-01

### Added

- Add between attendnace percentage
- add support for short and long semesters

### Changed

- Remove registration number validation for now
- Improved exam schedule page ui

---

## [2.0.0] - 2025-05-30

### Changed

- Migrate entire app to MVVM Pattern

---

## [0.2.3] - 2025-05-27

### Changed

- Timetable parser to not include any global variables

---

## [0.2.0] - 2025-05-24

### Added

- Initial release: Attendance, Timetable, Exam Schedule, Profile, Weekend and General Outing
