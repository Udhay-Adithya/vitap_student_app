## Type of Change

<!-- Check all that apply -->

- [ ] `feat` — new feature
- [ ] `fix` — bug fix
- [ ] `ui` — UI / layout change (include screenshots)
- [ ] `refactor` — code change with no behaviour difference
- [ ] `perf` — performance improvement
- [ ] `test` — adding or updating tests
- [ ] `docs` — documentation only
- [ ] `rust` — Rust / VTOP scraping changes
- [ ] `bridge` — Flutter-Rust bridge bindings regenerated

## Related Issue

Closes #<!-- issue number -->

## Description

<!-- What does this PR do? Why is this change needed? -->

## Changes Made

<!-- Bullet-point summary of what changed and where -->

-

## Screenshots / Recording

<!-- Required for any UI change. Drag and drop here. Delete this section if not applicable. -->

| Before | After |
|--------|-------|
|        |       |

## Checklist

### Flutter

- [ ] `flutter analyze` passes with no new warnings
- [ ] `flutter test` passes
- [ ] Ran `dart run build_runner build --delete-conflicting-outputs` (required if any model, provider, or ObjectBox entity was added or modified)
- [ ] No new `debugPrint` calls left in production paths that should be removed

### Rust (skip if no Rust changes)

- [ ] `cargo fmt` run inside `rust/`
- [ ] `cargo clippy` passes with no new warnings inside `rust/`
- [ ] `cargo test` passes inside `rust/`
- [ ] Ran `flutter_rust_bridge_codegen generate` and committed the updated `lib/src/rust/` bindings (required if any `#[frb]` function signature changed)

### Testing

- [ ] Tested on Android
- [ ] Tested on iOS *(or noted why not applicable)*
- [ ] Existing features unaffected by this change

### Licensing

- [ ] I agree to the terms in [Licensing of Contributions](https://github.com/Udhay-Adithya/vitap_student_app/blob/main/CONTRIBUTING.md#licensing-of-contributions), including the extra license grant to the maintainer
