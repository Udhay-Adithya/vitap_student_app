# Troubleshooting

## Running out of disk space

Building this app takes a lot of disk, and most of it is the Rust library
(`lib_vtop`), not Flutter. Every CPU architecture is compiled separately, and
Rust keeps old build artifacts around after code changes and dependency
upgrades, so `build/` only ever grows until you clean it.

### Where the space goes

| Path | What it is | Safe to delete? |
|---|---|---|
| `build/` | Flutter and Rust build output. The Rust library lives in `build/lib_vtop/` and is usually the largest part. | Yes — `flutter clean`. The next build recompiles Rust from scratch, which takes several minutes. |
| `rust/target/` | Only created when you run `cargo` yourself inside `rust/` (tests, `dryrun`, `cargo build`). The app build does not use it. | Yes — `cargo clean` inside `rust/`. |
| `~/.gradle/` | Gradle's caches and downloaded Gradle versions, shared by every Android project on your machine. Old versions pile up here. | Mostly — `~/.gradle/caches/` and old versions in `~/.gradle/wrapper/dists/` are re-downloaded when needed. |
| `~/Library/Developer/Xcode/DerivedData/` | Xcode's build cache (macOS). | Yes. |
| `~/.pub-cache/`, `~/.cargo/`, `~/.rustup/` | Dart packages and Rust toolchains, shared across projects. | Leave these alone unless you know what you're removing. |

### Keeping it small

**Run on a device with `flutter run`.** Flutter tells the build which
architecture the device has, and Rust is compiled for that one only.

**Building an APK without a device? Pass `--target-platform`.** A plain
`flutter build apk --debug` compiles Rust for three architectures. Pick the one
you need:

| Device | Flag |
|---|---|
| Physical Android phone | `--target-platform android-arm64` |
| Android emulator on an Apple Silicon Mac | `--target-platform android-arm64` |
| Android emulator on an Intel/AMD machine | `--target-platform android-x64` |

```bash
flutter build apk --debug --target-platform android-arm64
```

iOS builds need nothing extra: the Rust build follows Xcode's architecture
setting, which in debug is just the device or simulator you're running on.

**Clean when it gets big.** `flutter clean` is the reset. There is no need to
do it routinely — only when you want the space back.

**Debug builds skip debug info for Rust dependencies.** `rust/Cargo.toml` keeps
full debug info for `lib_vtop` itself, so backtraces in our own code still have
line numbers, but drops it for dependencies, which is most of a debug build's
size. If you need to step into a dependency with a native debugger, remove the
`[profile.dev.package."*"]` section locally.

### Working from an external drive

The project builds fine from an external drive, which keeps `build/` off your
main disk.

- Format the drive as APFS (macOS), ext4 (Linux) or NTFS (Windows). Not exFAT
  or FAT32: the iOS build relies on symlinks, which those don't support.
- When copying an existing checkout, `.env`, `rust/.env` and Android signing
  files are not in git — copy them across too. There is no need to copy
  `build/` or `.dart_tool/`; they are regenerated.
- The shared caches above (`~/.gradle`, `~/.pub-cache`, …) stay on your main
  disk regardless.
