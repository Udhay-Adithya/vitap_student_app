# Copilot Instructions

## Project Overview

VITAP Student App is a Flutter mobile application for VIT-AP University students. It scrapes the VTOP student portal using a Rust library (via Flutter-Rust Bridge) and presents data — attendance, timetable, marks, exam schedule, profile — in a native app experience.

## Build, Test, and Lint Commands

```bash
# Install dependencies
flutter pub get

# Run the app (build Rust first on initial setup)
cd rust && cargo build --release && cd ..
flutter run

# Lint / static analysis
flutter analyze

# Run all Flutter tests
flutter test

# Run a single Flutter test file
flutter test test/widget_test.dart

# Regenerate all code (ObjectBox, Riverpod, JSON, Freezed)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
dart run build_runner watch

# Regenerate Flutter-Rust bridge bindings (run from project root)
flutter_rust_bridge_codegen generate

# Rust: format, lint, test
cd rust
cargo fmt
cargo clippy
cargo test
cargo test test_function_name   # single Rust test
```

## Architecture

### Flutter layer (`lib/`)

**Feature-based structure** — each feature lives in `lib/features/<feature>/` with four mandatory sub-layers. All cross-feature shared code lives in `lib/core/`.

Current features: `auth`, `attendance`, `timetable`, `course_page`, `digital_assignment`, `home`, `onboarding`, `account`, `vtop_webview`.

---

### Feature sub-layer guide

Follow this pattern **exactly** when creating a new feature. Every layer has a corresponding `.g.dart` generated companion; always run `build_runner` after changes.

#### `repository/`

One file per data source. Repositories are the only layer that calls VTOP (via Rust) or external HTTP APIs. They always return `Either<Failure, T>`.

**Pattern for VTOP-backed repositories:**
```dart
part 'my_remote_repository.g.dart';

@riverpod
MyRemoteRepository myRemoteRepository(Ref ref) {
  final vtopService = serviceLocator<VtopClientService>();
  return MyRemoteRepository(vtopService);
}

class MyRemoteRepository {
  final VtopClientService vtopService;
  MyRemoteRepository(this.vtopService);

  Future<Either<Failure, MyModel>> fetchData({
    required String registrationNumber,
    required String password,
    required String semSubId,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );
      final result = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchMyData(client: client, semesterId: semSubId),
      );
      return Right(myModelFromJson(result));
    } on SocketException {
      return Left(Failure('No internet connection'));
    } on VtopError catch (rustError) {
      final msg = await VtopException.getFailureMessage(rustError);
      return Left(Failure(msg));
    } on FormatException catch (e) {
      debugPrint('JSON parsing failed: ${e.toString()}');
      return Left(Failure('Invalid response format from server'));
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
      return Left(Failure('An unexpected error occurred. Please try again.'));
    }
  }
}
```

**Pattern for REST HTTP repositories** (e.g., For You feed):
```dart
@riverpod
MyRepository myRepository(Ref ref) {
  final client = serviceLocator<http.Client>();
  return MyRepository(client);
}

class MyRepository {
  final http.Client _client;
  MyRepository(this._client);

  Future<Either<Failure, MyModel>> fetchData() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/endpoint'), headers: _headers);
      if (response.statusCode == 200) {
        return Right(MyModel.fromJson(json.decode(response.body) as Map<String, dynamic>));
      }
      return Left(Failure('Request failed: ${response.statusCode}'));
    } catch (e) {
      return Left(Failure('Failed: ${e.toString()}'));
    }
  }
}
```

#### `model/`

Models used exclusively within a feature (not shared across features). If a model needs to be shared, it belongs in `lib/core/models/`.

There are two kinds of models:

**ObjectBox entity** (persisted locally — used for data that is part of the `User` aggregate):
```dart
part 'my_model.g.dart';

@Entity()
@JsonSerializable()
class MyModel {
  @Id()
  int? id;

  @JsonKey(name: 'field_name')
  final String fieldName;

  MyModel({this.id, required this.fieldName});

  factory MyModel.fromJson(Map<String, dynamic> json) => _$MyModelFromJson(json);
  Map<String, dynamic> toJson() => _$MyModelToJson(this);
}
```

**JSON-only model** (transient — not persisted, used for API response parsing):
```dart
part 'my_detail.g.dart';

List<MyDetail> myDetailFromJson(String str) =>
    List<MyDetail>.from((json.decode(str) as List).map((x) => MyDetail.fromJson(x as Map<String, dynamic>)));

@JsonSerializable()
class MyDetail {
  @JsonKey(name: 'field_name')
  final String fieldName;

  MyDetail({required this.fieldName});

  factory MyDetail.fromJson(Map<String, dynamic> json) => _$MyDetailFromJson(json);
  Map<String, dynamic> toJson() => _$MyDetailToJson(this);
}
```

#### `viewmodel/`

Business logic layer. Uses Riverpod with code generation (`@riverpod`). ViewModels retrieve credentials from `CurrentUserNotifier`, call the repository, and call `userNotifier.updateUser()` to persist results back to ObjectBox.

```dart
part 'my_viewmodel.g.dart';

@riverpod
class MyViewModel extends _$MyViewModel {
  late MyRemoteRepository _repository;

  @override
  AsyncValue<MyModel>? build() {
    _repository = ref.watch(myRemoteRepositoryProvider);
    return null;  // null = idle (not yet fetched)
  }

  Future<void> refresh({bool silentRefresh = false}) async {
    if (!silentRefresh) state = const AsyncValue.loading();

    final user = ref.read(currentUserProvider);
    final credentials = await ref.read(currentUserProvider.notifier).getSavedCredentials();
    if (credentials == null) {
      state = AsyncValue.error('User not found. Please Logout and Login.', StackTrace.current);
      return;
    }

    final res = await _repository.fetchData(
      registrationNumber: credentials.registrationNumber,
      password: credentials.password,
      semSubId: credentials.semSubId,
    );

    if (res case Left(value: final failure)) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else if (res case Right(value: final data)) {
      state = AsyncValue.data(data);
      if (user != null) {
        await ref.read(currentUserProvider.notifier).updateUser(
          user.copyWith(myField: data),
        );
      }
    }
  }
}
```

#### `view/pages/` and `view/widgets/`

- `pages/` — full-screen `ConsumerWidget` or `ConsumerStatefulWidget` routed to from the nav bar or other pages.
- `widgets/` — smaller reusable components, each focused on a single piece of UI.

Pages watch the viewmodel state and pattern-match on `AsyncValue`:
```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myViewModelProvider);
    return switch (state) {
      null => const _IdleView(),
      AsyncLoading() => const CircularProgressIndicator(),
      AsyncError(:final error) => Text(error.toString()),
      AsyncData(:final value) => _DataView(data: value),
    };
  }
}
```

---

### Rust layer (`rust/`)

The `rust/` directory is a standalone Cargo crate (`lib_vtop`) that handles all VTOP portal interaction. It is compiled to a native library and called from Dart via Flutter-Rust Bridge. **Never manually edit `lib/src/rust/` — those are generated bindings.**

```
rust/src/
├── lib.rs                        # Crate root: pub mod api; mod frb_generated;
├── frb_generated.rs              # Auto-generated bridge glue — do not edit
├── dryrun.rs                     # Binary target for local testing without Flutter
└── api/
    ├── mod.rs                    # Exposes: simple, vtop, vtop_get_client
    ├── simple.rs                 # Trivial bridge health-check functions
    ├── vtop_get_client.rs        # Public #[frb] async fns called by Dart repositories
    │                             # (fetch_all_data, fetch_attendance, fetch_semesters, …)
    └── vtop/
        ├── mod.rs                # Re-exports all sub-modules
        ├── vtop_client.rs        # VtopClient struct — holds reqwest::Client + config + session
        ├── vtop_config.rs        # VtopConfig (base_url, timeout) + VtopClientBuilder
        ├── vtop_errors.rs        # VtopError enum (#[frb(non_opaque)]) + message()/errorType() methods
        ├── session_manager.rs    # Cookie jar + authentication state
        ├── captcha_solver.rs     # ML-based captcha OCR (bitmap + neural-net weights)
        ├── captcha/
        │   ├── bitmaps.json      # Character bitmap templates
        │   └── weights.json      # Neural-net weights for captcha solving
        ├── client/               # VtopClient method implementations (one file per domain)
        │   ├── auth.rs           # login(), get_cookie(), handle_session_check()
        │   ├── academic.rs       # get_attendance(), get_timetable(), get_exam_schedule(), get_marks()
        │   ├── profile.rs        # get_student_profile()
        │   ├── course_page.rs    # get_course_page(), get_digital_assignments()
        │   ├── faculty.rs        # search_faculty(), get_faculty_details()
        │   ├── hostel.rs         # outing submission, outing history
        │   ├── payment.rs        # get_payment_receipts(), get_pending_payments()
        │   ├── biometric.rs      # get_biometric_attendance()
        │   └── builder.rs        # Additional builder helpers
        ├── parser/               # HTML parsers (one file per data type, uses scraper crate)
        │   ├── attendance_parser.rs
        │   ├── timetable_parser.rs
        │   ├── profile_parser.rs
        │   ├── marks_parser.rs
        │   ├── exam_schedule_parser.rs
        │   ├── grade_history_parser.rs
        │   ├── course_page_parser.rs
        │   ├── digital_assignment_parser.rs
        │   └── …
        └── types/                # Serde-serializable data structs (mirrored as Dart models)
            ├── attendance.rs
            ├── timetable.rs
            ├── student_profile.rs
            ├── semester.rs
            ├── comprehensive_data.rs   # Returned by fetch_all_data
            └── …
```

**Key Rust conventions:**
- All functions called from Dart must be in `api/vtop_get_client.rs` and annotated with `#[flutter_rust_bridge::frb()]` (async) or `#[flutter_rust_bridge::frb(sync)]`.
- `VtopError` is `#[frb(non_opaque)]` so Dart can pattern-match on variants.
- Error handling uses `VtopResult<T>` = `Result<T, VtopError>`. Map `reqwest` errors using `map_reqwest_error` / `map_response_read_error` helpers.
- HTML is parsed with the `scraper` crate (`Html::parse_document`, `Selector::parse`).
- The captcha solver uses a bitmap dictionary + a simple neural network (weights baked in at compile time via `include_str!`). Do not replace it without updating both `bitmaps.json` and `weights.json`.
- Use `cargo fmt` + `cargo clippy` before committing Rust changes.
- Integration tests live in `rust/tests/` (e.g., `digital_assignment_parser_test.rs`).

**Adding a new VTOP endpoint:**
1. Add parser in `rust/src/api/vtop/parser/<name>_parser.rs`.
2. Add data struct in `rust/src/api/vtop/types/<name>.rs` (derive `Serialize`, `Deserialize`).
3. Add client method in the appropriate `rust/src/api/vtop/client/*.rs`.
4. Expose a `#[frb]` async fn in `rust/src/api/vtop_get_client.rs`.
5. Run `flutter_rust_bridge_codegen generate` to regenerate `lib/src/rust/`.
6. Add the Dart repository/viewmodel following the feature sub-layer guide above.

---

### Data persistence

- **ObjectBox** (`lib/objectbox.g.dart`, `lib/objectbox-model.json`) — local on-device database for `User` and all related entities. The `Store` is registered in GetIt.
- **FlutterSecureStorage** — stores VTOP credentials (reg number, password, semester ID) via `SecureStorageService`.
- **SharedPreferences** — user preferences (theme, font scale, notification settings) via `UserPreferencesNotifier`.

### Dependency injection

**GetIt** service locator, initialized in `lib/init_dependencies.dart`. The `serviceLocator` instance is exported from that file and used directly in repositories and providers. Services registered at startup: `FlutterSecureStorage`, `SecureStorageService`, `VtopClientService`, `ConnectionChecker`, `Store` (ObjectBox), `http.Client`, `IOClient`.

### State management

**Riverpod** with code generation. All providers use `@riverpod` annotation and a corresponding `.g.dart` generated file. Long-lived providers use `@Riverpod(keepAlive: true)` (e.g., `CurrentUserNotifier`, `ScheduleHomeWidgetNotifier`).

---

## For You Feed

The "For You" feed (`lib/features/home/`) is a community content feed backed by an independent REST API (not VTOP). It is separate from all VTOP scraping.

- **Base URL**: `ServerConstants.forYouApiBaseUrl`
- **Auth**: `X-API-Key` header using `FOR_YOU_API_KEY` from `.env`
- **HTTP client**: uses the plain `http.Client` from GetIt (not the SSL-bypass `IOClient`)
- **Approval gate**: only items with `is_approved == true` are shown to users
- **Like tracking**: likes are tracked per-session only (in-memory `LikedItemsSession` provider), so they reset on app restart — by design
- **Filtering/sorting**: done locally in `ForYouViewModel` on the cached `_allItems` list; no extra API calls
- **Submission**: users can submit new items via `POST /items`; submitted items are invisible until an admin approves them

The repository (`ForYouRepository`) handles raw HTTP. The viewmodel (`ForYouViewModel`) owns the item list and derived providers (`featuredItems`, `forYouTypes`, `ForYouSubmit`) are computed from it using `ref.watch`.

---

## Notification Scheduling

Notifications are managed entirely by `NotificationService` (a static class — no instantiation needed). It uses `flutter_local_notifications` with timezone-aware scheduling (always `Asia/Kolkata`).

**Three notification groups** with dedicated Android channel IDs:
| Channel | `groupKey` | Purpose |
|---|---|---|
| `timetable_reminders` | `com.vitap.class_reminders` | Weekly recurring class reminders |
| `exam_reminders` | `com.vitap.exam_reminders` | One-shot pre-exam reminders |
| `file_downloads` | `com.vitap.downloads` | Download complete + progress |

**Scheduling flow:**
- Both `scheduleTimetableNotifications()` and `scheduleExamNotifications()` are called in `CurrentUserNotifier.loginUser()` and `updateUser()` — they automatically reschedule whenever user data changes.
- Timetable notifications repeat weekly using `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime` with `AndroidScheduleMode.inexact`.
- Exam notifications are one-shot (`AndroidScheduleMode.exactAllowWhileIdle`) and are skipped if the calculated notification time is already in the past.
- The delay before class/exam start is read from `UserPreferences` (`timetableNotificationDelay`, `examScheduleNotificationDelay`).
- Both are gated by `UserPreferences.isTimetableNotificationsEnabled` / `isExamScheduleNotificationEnabled`.

**Download notifications** follow a two-step pattern:
1. Call `showDownloadProgressIndeterminate()` before the network request — returns a `notificationId`.
2. Call `showDownloadCompleteNotification()` (or `updateDownloadProgress()`) when done.
Use the `DownloadType` enum to set consistent titles/emojis across all download types.

**Android grouping**: multiple download notifications are automatically bundled using a group summary notification (`_showDownloadGroupSummary()`). Class and exam groups use the same mechanism.

Notification tap handler (`_onNotificationTap`) opens downloaded files via `open_file` using the file path stored in the notification payload.

---

## Home Widget Integration

The home widget (`UpcomingClassWidget`) shows the next upcoming class on the device's home screen. It is powered by `ScheduleHomeWidgetNotifier` (`@Riverpod(keepAlive: true)`).

**Data flow:**
1. On app start, `MyApp.build()` calls `ref.read(scheduleHomeWidgetProvider.notifier).initializeTimetable()`.
2. `initializeTimetable()` reads `currentUserProvider`, JSON-encodes the timetable, writes it to `HomeWidget.saveWidgetData<String>('timetable', ...)`, then calls `HomeWidget.updateWidget(name: 'UpcomingClassWidget')`.
3. The native widget (Android + iOS) reads the `timetable` key from the shared app group storage.
4. iOS requires the App Group ID `group.com.udhay.vitapstudentapp` (set via `HomeWidget.setAppGroupId(...)` in `initDependencies()`).

**When to call `forceRefresh()`**: after a successful data refresh in any viewmodel that updates timetable data. This ensures the home screen widget reflects the latest class schedule without requiring an app restart.

**Clearing widget data**: call `clearTimetable()` on logout.

---

## Key Conventions

### Code generation
Every model, provider, or entity with annotations has an auto-generated `.g.dart` (or `.freezed.dart`) companion. **After modifying annotated classes, always re-run `build_runner`.** Generated files are excluded from analysis.

### Error handling
Repositories return `Either<Failure, T>` from `fpdart`. Errors from Rust arrive as `VtopError` and must be converted with `VtopException.getFailureMessage()`. Pattern match the result:
```dart
if (res case Left(value: final failure)) { /* handle error */ }
else if (res case Right(value: final data)) { /* use data */ }
```

### VTOP session management
`VtopClientService` is a singleton managing a single VTOP client session. Sessions expire after 15 minutes; service proactively refreshes at 14 minutes. Always use `executeWithRetry()` in repositories — never call `getVtopClient()` directly from a viewmodel. The `IOClient` in GetIt bypasses SSL verification (VTOP uses a self-signed certificate).

### Linting rules enforced
- `prefer_single_quotes` — always single quotes for strings
- `require_trailing_commas` — trailing commas on all multi-line argument lists
- `avoid_print` — use `debugPrint()` instead
- `strict-casts` and `strict-inference` enabled

### Dart style
- Providers in `viewmodel/` use the class-based `@riverpod` Notifier pattern — not function providers
- Models that are persisted in ObjectBox AND deserialized from Rust JSON carry both `@Entity()` and `@JsonSerializable()` on the same class (see `lib/core/models/attendance.dart`)
- User preferences and settings are always read via Riverpod providers — never read directly from `SharedPreferences` in widgets

### Environment
A `.env` file (not committed) must exist in the project root. See `.env.example`:
- `WIREDASH_SECRET_KEY` — feedback SDK key
- `FOR_YOU_API_KEY` — community feed API key
- `VTOP_USERNAME` / `VTOP_PASSWORD` — used only by the Rust `dryrun` binary for local testing

### Commit message format (Conventional Commits)
`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `ui:`, `perf:`, `rust:`, `bridge:`

### Branch naming
`feature/<name>`, `bugfix/<issue-number>-<description>`, `ui/<description>`
