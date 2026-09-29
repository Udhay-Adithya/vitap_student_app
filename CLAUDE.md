# VIT-AP Student App — working notes

An independent (not university-affiliated) Flutter app that reads a student's own
VTOP data using their own credentials. Built by Udhay Adithya.

## Stack

- **Flutter + Riverpod.** Most providers use `riverpod_annotation` codegen; a few
  are plain (`bottom_nav_provider.dart`, `schedule_clock.dart`). Both are fine.
- **All VTOP data goes through the Rust bridge** (`lib_vtop` via FRB). `http` is
  used only for the weather API and `announcements.json`. So a VTOP bug is a Rust
  bug — see `docs/vtop_frontend_handoff.md`.
- **ObjectBox** for persisted domain data, **SharedPreferences** for throwaway
  local state (dismissed announcements, engagement counters). Adding a property
  to an ObjectBox entity is a schema migration on a shipping app — don't do it
  for state that doesn't deserve one.
- Codegen: `dart run build_runner build --delete-conflicting-outputs`

## How to work here

**Discuss UI changes before implementing them.** The established rhythm is:
read the actual code, describe what's wrong and why, propose, get a decision,
then build. Skipping to code on a design task is not wanted.

**Extract rules into pure, tested functions.** Anything with a real rule in it —
deadlines, version gates, due dates, prompt eligibility — lives in a plain
function with an injectable `now`, not inside a widget. See
`outing_rules.dart`, `assignment_schedule.dart`, `semantic_version.dart`,
`review_prompt_policy.dart`. Regression tests carry a comment saying what bug
they lock down.

**Verify with `flutter analyze` and `flutter test`.** There is no Android device
attached in most sessions, so device verification usually can't happen — say so
plainly rather than implying something was seen working.

**Commits:** conventional, lowercase, single line, no body, no attribution.
`feat: add persistent update card to account page`

## Design system

Established across the home, login, biometric, outing, assignment and account
screens. Follow it rather than inventing per-screen treatments.

- **Every colour comes from `ColorScheme`.** No `Colors.red/green/blue/orange` —
  they sit off the seeded cream/olive palette in light mode and glare in dark.
  Status maps to `primary` / `tertiary` / `error`, containers for fills.
- **One saturated element per screen.** If everything is loud, nothing is.
- **Radii:** 28 hero cards, 20 cards and sheets' inner blocks, 16 strips and
  inputs, stadium/999 for pills and primary buttons.
- **Inputs:** `appInputDecoration()` is the single treatment — filled, radius 16,
  floating label. Don't hand-roll `InputDecoration`.
- **Home page rhythm:** `SectionHeader.gapAbove` (28), `gapBelow` (16),
  `gutter` (16). Sections supply no top padding of their own, and no widget
  carries its own horizontal gutter.
- **Bespoke card treatments per surface, not global `CardTheme`** — theming
  cards globally repaints every card in the app.
- `StyledSheet` is this app's replacement for centre dialogs.
- Prefer `ListTile` over a hand-rolled `Row` in a fixed-height `SizedBox`; the
  latter is how rows end up top-aligned instead of centred.

## Things that will bite you

**VTOP demands an OTP per session.** `executeWithRetry` throws
`VtopError_LoginOtpRequired`, pauses, and shows a global sheet. **Never fetch on
page open** — it can demand an OTP for a page someone only glanced at. Biometric
and attendance both fetch on an explicit tap for this reason, and neither has
pull-to-refresh. This cost a 1-star review before the OTP sheet explained itself.

**The weekend outing form is only served part of the week.** Outside its window
VTOP still returns the page, with the student fields stripped. The parser reports
`OutingFormUnavailable`, carrying VTOP's own notice from the hidden `jsonBom`
input ("…from Tuesday 12:00AM to Friday 11:59PM"), and `failureFrom` passes that
notice on. The app gates the form Tue–Sat (`isWeekendOutingFormOpen`); Saturday
is there for Monday outings' deadline, not because VTOP was seen serving it.

**Timetable rows arrive in VTOP's order, not chronological.** Sort before
displaying. Empty grid cells arrive as `"-"`; `parseClassTime` returns null
rather than throwing.

**`announcements.json` is hand-edited and pushed with no validation.** Parsing is
deliberately lenient — one bad entry is skipped, unknown enums fall back, bad
dates become null. Keep it that way. See
`docs/announcements/ANNOUNCEMENT_SYSTEM_DOCS.md`.

**Upgrader:** both `UpgradeAlert` and `UpgradeCard` check `versionInfo != null`
*before* consulting `debugDisplayAlways`, so a failed store lookup can't be
forced open with a debug flag. One shared `appUpgrader` instance is used by both
surfaces — two instances means two store lookups and unshared "Later" state.

**The For You feed is cached, on purpose.** The home tab is torn down and rebuilt
on every tab switch, so an auto-disposed provider turned each one into a fetch of
a list that changes a few times a month. `ForYouViewModel` is `keepAlive`, and
`ForYouRepository` reads through a SharedPreferences cache with a 6h TTL and
`If-None-Match` revalidation. Don't make it fetch on build again. Contract and
required response headers: `docs/for_you/FOR_YOU_FEED_DOCS.md`.

**`AppConstants.forYouItemTypes` must match the API's `type` enum.** They drifted
once — the app offered `'events'` and `'other'` while the API validated against
`'event'` and no `'other'` — so every submission of those two types came back as
a 400 the form reported as a generic failure. Singular `'event'`.

**Card colours don't switch on `item.type`.** The feed can grow a type at any
time and `ColorScheme` has no role to spare for a sixth one, so type is carried
by an icon on a neutral chip (`for_you_meta.dart`); unknown types still render
rather than falling into some other type's colour.

## Product rules

**Analytics never carries PII.** Only coarse cohort (joining year, branch) derived
from the registration number prefix, with the unique digits discarded on device.
No user id. Error text is scrubbed of URLs, emails and long digit runs.
Opt-out is `UserPreferences.isAnalyticsEnabled` (nullable — null means "never
chosen" and reads as enabled).

**Support the developer must stay person-to-person.** Apple guideline 3.2.1 and
Play's peer-to-peer exception both require that the gift is optional, 100% goes
to the recipient, and **the contributor receives absolutely nothing** — no
unlocked features, no ad removal, no badge. Attach any benefit and both
exceptions evaporate into in-app purchase. Never use purchase language.

**Ask for a review only after a task that *finished*** — an outing applied, an
assignment uploaded. Never after a refresh: people refresh in order to read the
result, and a sheet lands on top of it. Gated in `review_prompt_policy.dart`.

**Answer questions where they arise.** The FAQ page is depth, not delivery —
people form a theory at the moment something surprises them and act on it. Use
`FaqLink` at the point of friction, keyed by `FaqTopic` (stable ids, never list
indices).

## Recurring bugs worth grepping for

- `onPressed: () {}` — dead handlers that ripple and do nothing
- Errors surfaced twice: a snackbar *and* an in-page error view. Pick one.
- Async actions with no loading state, especially uploads and downloads
- Unguarded `DateTime.parse` inside a `build` or an item builder
- Widgets that construct or dispose controllers during `build`
