# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.5.2] - 2026-10-10

### Changed

- The grade view loads with one request instead of two ([#77](https://github.com/Udhay-Adithya/vitap_student_app/pull/77))

### Fixed

- Your application number, name, date of birth, blood group and every proctor detail are shown again instead of coming back blank. VTOP splits labels like "APPLICATION NUMBER" across lines with a run of tabs between the words, which stopped them being matched ([#73](https://github.com/Udhay-Adithya/vitap_student_app/pull/73))
- A page no longer comes back empty after the app quietly signs you back in. When VTOP dropped the session the app re-authenticated and then read the old expired response anyway ([#74](https://github.com/Udhay-Adithya/vitap_student_app/pull/74))
- A page VTOP refuses to serve now says so, rather than showing an empty list as though you had no records ([#78](https://github.com/Udhay-Adithya/vitap_student_app/pull/78))
- A semester the app can no longer make sense of is reported, instead of showing an empty semester that looks the same as having no data ([#79](https://github.com/Udhay-Adithya/vitap_student_app/pull/79))
- Login reports what actually went wrong when VTOP never serves a captcha, instead of failing later for an unrelated reason ([#76](https://github.com/Udhay-Adithya/vitap_student_app/pull/76))
- Applying for a weekend outing outside the hours VTOP accepts them now tells you when the form opens, quoting VTOP's own notice, instead of "Unable to process server response" ([#97](https://github.com/Udhay-Adithya/vitap_student_app/pull/97))
- Signing in no longer discards everything it has just downloaded when class reminders cannot be scheduled. Your saved credentials stayed behind, so the app looked signed in while every page reported no user ([#101](https://github.com/Udhay-Adithya/vitap_student_app/pull/101))
- The capstone attendance day-wise list starts with the most recent day instead of the first day of the semester ([8ffb32d](https://github.com/Udhay-Adithya/vitap_student_app/commit/8ffb32d))
- Pull to refresh on payment receipts keeps its spinner until the receipts arrive, rather than dropping it straight away ([6680d00](https://github.com/Udhay-Adithya/vitap_student_app/commit/6680d00))

### Internal

- Pull requests are now checked automatically: `flutter analyze`, `flutter test`, `cargo fmt`, `cargo clippy` and `cargo test` ([#92](https://github.com/Udhay-Adithya/vitap_student_app/pull/92)), and a check that the committed generated code is up to date ([#98](https://github.com/Udhay-Adithya/vitap_student_app/pull/98))
- Cleared the backlog those checks would have failed on: 58 Clippy warnings ([#90](https://github.com/Udhay-Adithya/vitap_student_app/pull/90)) and 111 analyzer issues ([#91](https://github.com/Udhay-Adithya/vitap_student_app/pull/91))
- Regenerating the Flutter-Rust bindings is reproducible again; it had started rewriting 62 files from unchanged source ([#95](https://github.com/Udhay-Adithya/vitap_student_app/pull/95))
- Repository errors are mapped to messages in one tested place instead of 36 copies of the same `catch` ([#93](https://github.com/Udhay-Adithya/vitap_student_app/pull/93))
- Tests for the VTOP parsers that had none, covering attendance, marks, exam schedule, grade history, biometric, outings, faculty ([#96](https://github.com/Udhay-Adithya/vitap_student_app/pull/96)) and the course page ([#99](https://github.com/Udhay-Adithya/vitap_student_app/pull/99))
- The Rust doc examples compile and run again, which caught several that documented an API that no longer existed ([#102](https://github.com/Udhay-Adithya/vitap_student_app/pull/102))
- Tests holding the rules that had nothing enforcing them: attendance and biometric never fetching on page open, the login OTP flow, and upload loading states ([#103](https://github.com/Udhay-Adithya/vitap_student_app/pull/103))
- The JSON crossing the Rust bridge is pinned on both sides, so a renamed field fails a test instead of reaching you as "Invalid response format from server" ([#104](https://github.com/Udhay-Adithya/vitap_student_app/pull/104))
- Pointed the Rust crate metadata at a repository that exists ([#72](https://github.com/Udhay-Adithya/vitap_student_app/pull/72))

## [2.5.1] - 2026-09-03

### Fixed

- Refreshing your data no longer fails with a storage error. Rows left behind by a refresh were being deleted before the refreshed data was saved, so the save then failed trying to unlink rows that were already gone. The same fault affected the academic calendar ([389bc4d](https://github.com/Udhay-Adithya/vitap_student_app/commit/389bc4df15eaa02fe464fec5f732132fa72f536f))
- The semester picked at login is kept instead of being cleared as the account signs in, which left the account page reading "Select Semester" ([d7dd953](https://github.com/Udhay-Adithya/vitap_student_app/commit/d7dd953963ce75e5644955991ada16845a9bb7cd))

## [2.5.0] - 2026-09-03

### Added

- Capstone and SDP attendance, shown alongside your other courses on the attendance page (Thanks to [@tarun-ainampudi](https://github.com/tarun-ainampudi))([#62](https://github.com/Udhay-Adithya/vitap_student_app/pull/62))
- Academic calendar page, listing holidays, exam days, instructional days and named events for the semester ([#64](https://github.com/Udhay-Adithya/vitap_student_app/pull/64))

### Changed

- Reordered the Quick Access items ([30ab7b7](https://github.com/Udhay-Adithya/vitap_student_app/commit/30ab7b7))
- Moved the filter button next to the search bar on the For You list ([c84e45c](https://github.com/Udhay-Adithya/vitap_student_app/commit/c84e45c))
- Attendance sheet now uses the app's shared tab bar style ([b9b9030](https://github.com/Udhay-Adithya/vitap_student_app/commit/b9b9030bf27f721a4ef2341fe28f62525b9654d8))
- Reworked the colours on the capstone attendance card and sheet ([a3e3e39](https://github.com/Udhay-Adithya/vitap_student_app/commit/a3e3e39), [528afa5](https://github.com/Udhay-Adithya/vitap_student_app/commit/528afa5))

### Fixed

- Logging out now clears the account's last-synced timestamps and profile photo ([151baeb](https://github.com/Udhay-Adithya/vitap_student_app/commit/151baeb))
- Logging out now clears the home screen widget ([e95a3b7](https://github.com/Udhay-Adithya/vitap_student_app/commit/e95a3b7))
- Rows left behind in local storage by a refresh or a logout are now deleted, instead of accumulating ([#63](https://github.com/Udhay-Adithya/vitap_student_app/pull/63))

## [2.4.0] - 2026-08-25

### Added

- Usage analytics opt-out toggle in settings, so anonymous analytics can be turned off at any time ([#44](https://github.com/Udhay-Adithya/vitap_student_app/pull/44))
- Support the developer sheet, plus a dismissible card on the home page ([1214d88](https://github.com/Udhay-Adithya/vitap_student_app/commit/1214d8823d4de04173ac02710417bf1ac81d6055))
- Review prompt shown only after a task actually finishes, gated on measured engagement ([7cc7463](https://github.com/Udhay-Adithya/vitap_student_app/commit/7cc74631423d91f691b7fa1c527a545657e0de8e))
- Long press a detail on the profile page to copy it to the clipboard (Thanks to [@Ponsriram](https://github.com/Ponsriram))([#47](https://github.com/Udhay-Adithya/vitap_student_app/pull/47))
- Registration number is now scraped into the student profile ([7775e09](https://github.com/Udhay-Adithya/vitap_student_app/commit/7775e09beb107d308a39f48ad50f56f7abc93f87))
- Your VTOP photo can now be used as your profile avatar ([a66ac5d](https://github.com/Udhay-Adithya/vitap_student_app/commit/a66ac5deb258bfee3c4793e52409e3106b3aec5d))
- Mentor details moved out of the profile tabs into their own page, reachable from Quick Access ([0a1d4db](https://github.com/Udhay-Adithya/vitap_student_app/commit/0a1d4db3cac842c1d3b27f12cf7e645894a8cf76))
- Confirmation before a community tool opens in the browser ([d13535e](https://github.com/Udhay-Adithya/vitap_student_app/commit/d13535efc9b15034718d6cd89e3b16b967411b59))
- Notice stating that the app is not affiliated with the university ([cb700b9](https://github.com/Udhay-Adithya/vitap_student_app/commit/cb700b9df2d445d0db748f4b34f4436244586b4b))
- Downloads on iOS are saved through the system file dialog ([#52](https://github.com/Udhay-Adithya/vitap_student_app/pull/52))

### Changed

- Reworked the interface across the app to be more expressive and easier to use ([#42](https://github.com/Udhay-Adithya/vitap_student_app/pull/42))
- Reworked the For You feed with caching and richer item metadata ([8dafd2c](https://github.com/Udhay-Adithya/vitap_student_app/commit/8dafd2c2d9f1f9b2912234e5f6914964a596aaef), [1a1299f](https://github.com/Udhay-Adithya/vitap_student_app/commit/1a1299f5f6efa0588533e5e9fbbcd38f222101b9))
- VTOP portal is reachable again from Quick Access, reintroducing the direct login removed in 2.3.2 ([5185771](https://github.com/Udhay-Adithya/vitap_student_app/commit/51857716330464988ed17690cff9a14ded99cc40), [d7c3daf](https://github.com/Udhay-Adithya/vitap_student_app/commit/d7c3daf31dc1c0712d5817b9978d0e19d128357d), [06356f0](https://github.com/Udhay-Adithya/vitap_student_app/commit/06356f08cf0e8f37fcbfc1066d42551af607caf7))
- Tapping the avatar in the home app bar opens the profile page instead of the account page ([788918b](https://github.com/Udhay-Adithya/vitap_student_app/commit/788918b6bff1de62b9a2d732cb1c1df1f8383833))
- Tapping the home screen widget now opens the app ([497a510](https://github.com/Udhay-Adithya/vitap_student_app/commit/497a51010785ae93965f37cc46eed9726d1e79f8))
- Attendance no longer refreshes itself every 24 hours ([021ba37](https://github.com/Udhay-Adithya/vitap_student_app/commit/021ba37e94482b1d638799504f5dd703a1651ebe))
- GitHub links now point at the new repository owner ([c20eb9a](https://github.com/Udhay-Adithya/vitap_student_app/commit/c20eb9a209f1930e66f68c7041fbb3fb1432736c), [483a22b](https://github.com/Udhay-Adithya/vitap_student_app/commit/483a22bf5b2ba9a949e88b2f666b735e0967706f))
- Updated `flutter_file_dialog`, `flutter_secure_storage`, `home_widget`, `open_file_ios`, `package_info_plus`, `permission_handler_apple` and `syncfusion_flutter_pdfviewer` ahead of the Swift Package Manager and AGP 9 migrations ([9a4db79](https://github.com/Udhay-Adithya/vitap_student_app/commit/9a4db79e00aa180ae13386c7563e52b3d8293c55))

### Fixed

- Only one login OTP is sent per sign-in; opening the app could previously trigger two or three emails at once, and a correctly typed code could be rejected ([4af99cc](https://github.com/Udhay-Adithya/vitap_student_app/commit/4af99cc730fae9cdb16af45819570f0a67646ed0))
- Corrected the payment receipt parser for VTOP's new column layout ([#49](https://github.com/Udhay-Adithya/vitap_student_app/pull/49))
- Semester list now falls back to another source when the first one comes back empty ([#51](https://github.com/Udhay-Adithya/vitap_student_app/pull/51))
- A pending outing approval is treated as a successful submission rather than an error ([b8dc0eb](https://github.com/Udhay-Adithya/vitap_student_app/commit/b8dc0ebe85a7f7e912581ed5a74f2bd702e9b9c4))
- Stored credentials are required before entering the app ([32bdc95](https://github.com/Udhay-Adithya/vitap_student_app/commit/32bdc95e63d7e812890e1a0ac9a5f1632bd7a30f))
- Removed the tap-to-open action from download notifications, which did nothing ([2eefffb](https://github.com/Udhay-Adithya/vitap_student_app/commit/2eefffbf8fc55034865bc8bc1d7893a46be7bc83))

### Removed

- Unused camera and location usage descriptions on iOS ([38a6f8e](https://github.com/Udhay-Adithya/vitap_student_app/commit/38a6f8e7af890387ea986bb3afee148dd35d70d9))
- Unused Android external storage permissions ([c756005](https://github.com/Udhay-Adithya/vitap_student_app/commit/c756005c6b128c326c6e31ed3dd290ae3c118087))
- Unused assets ([96ba0e7](https://github.com/Udhay-Adithya/vitap_student_app/commit/96ba0e76d5ef6b739d333afc351475dad2606678))

## [2.3.4] - 2026-07-18

### Added

- 180-second cooldown for login OTP resend requests (Thanks to [@tarun-ainampudi](https://github.com/tarun-ainampudi))([#22](https://github.com/Udhay-Adithya/vitap_student_app/pull/22))
- AMOLED mode support, toggleable in settings ([#29](https://github.com/Udhay-Adithya/vitap_student_app/pull/29))
- Predictive back transitions for Android ([ac0be46](https://github.com/Udhay-Adithya/vitap_student_app/commit/ac0be4683989e78d9862b7e342f146ed571b271c))
- New Lemonade theme ([8f8b564](https://github.com/Udhay-Adithya/vitap_student_app/commit/8f8b564f41a27cac60e7764da430b607c2d6ecfb))
- Demo Login option so App Store reviewers (and demos) can evaluate the app without a real VTOP account ([#37](https://github.com/Udhay-Adithya/vitap_student_app/pull/37))

### Changed

- Updated Gradle distribution version to 8.14 ([9508487](https://github.com/Udhay-Adithya/vitap_student_app/commit/950848727c584fec6df2ab4fc23b74d7102d1177))
- Enabled `OnBackInvokedCallback` in AndroidManifest to support predictive back on Android ([ac0be46](https://github.com/Udhay-Adithya/vitap_student_app/commit/ac0be4683989e78d9862b7e342f146ed571b271c))

### Fixed

- Fixed wrong weather icon asset paths and missing weather icons ([6cbb711](https://github.com/Udhay-Adithya/vitap_student_app/commit/6cbb711))
- Fixed timetable parsing issue for Fall 2026-27 semester ([#34](https://github.com/Udhay-Adithya/vitap_student_app/pull/34))
- Fixed last synced timer to only update when a refresh actually succeeds ([#35](https://github.com/Udhay-Adithya/vitap_student_app/pull/35))
- Fixed OTP keyboard not reopening in the login OTP sheet when switching apps to retrieve the OTP and returning ([#35](https://github.com/Udhay-Adithya/vitap_student_app/pull/35))

## [2.3.3] - 2026-04-22

### Fixed

- Migrated TLS backend from `native-tls` (OpenSSL) to pure-Rust `rustls` to fix Android cross-compilation failure
- Replaced broken `rustls-platform-verifier` custom cert loading with a manually configured `ClientConfig` that includes Mozilla's trusted root store and the pinned VTOP Sectigo intermediate CA, restoring proper TLS certificate verification

## [2.3.2] - 2026-04-21

### Added

- Detailed account-locked instruction sheet shown when incorrect password is entered and the account is locked
- Pull-to-refresh support on timetable, attendance, marks, exam schedule, and payment pages
- OTP-based two-factor authentication support (Thanks to [@tarun-ainampudi](https://github.com/tarun-ainampudi))([#21](https://github.com/Udhay-Adithya/vitap_student_app/pull/21))
- Faculty page re-introduced

### Changed

- Outing and exam schedule pages now use a unified tab bar style for visual consistency
- Wiredash feedback prompt frequency increased from 30 to 60 days
- Migrated iOS app lifecycle to UIScene
- Updated Rust dependencies

### Fixed

- Fixed contributors sheet failing to load intermittently
- Fixed pending payments always appearing empty due to a parsing issue (Thanks to [@tarun-ainampudi](https://github.com/tarun-ainampudi))([#16](https://github.com/Udhay-Adithya/vitap_student_app/pull/16))
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
- Digital Assignments feature with upload, update, and download assignment support(Thanks to [@tarun-ainampudi](https://github.com/tarun-ainampudi))([#11](https://github.com/Udhay-Adithya/vitap_student_app/pull/11))
- Changelog page in the app
- App contributors credits bottom sheet in the app footer

### Fixed

- Fixed For You section card height
- Fixed Google Analytics on Android which was accidentally removed
- Fixed TLS certificate issue by adding certificates to the trust store(Thanks to [@synaptic-gg](https://github.com/synaptic-gg))([#13](https://github.com/Udhay-Adithya/vitap_student_app/pull/13))
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
- Fixed VTOP web view SSL certificate issue (Thanks to [@synaptic-gg](https://github.com/synaptic-gg))([#10](https://github.com/Udhay-Adithya/vitap_student_app/pull/10))

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
