# Contributing to VITAP Student App

First off, thank you for considering contributing to the VITAP Student App! Your help is essential for keeping it great and improving the student experience at VIT-AP University.

This document provides guidelines for contributing to this project. Please read it carefully to ensure a smooth and effective contribution process.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Development Setup](#development-setup)
- [Coding Guidelines](#coding-guidelines)
  - [Flutter/Dart Style Guide](#flutterdart-style-guide)
  - [Commit Messages](#commit-messages)
- [Testing](#testing)
- [Documentation](#documentation)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## How Can I Contribute?

### Reporting Bugs

If you find a bug, please ensure the bug was not already reported by searching on GitHub under [Issues](https://github.com/Udhay-Adithya/vit_ap_student_app/issues).

If you're unable to find an open issue addressing the problem, [open a new one](https://github.com/Udhay-Adithya/vit_ap_student_app/issues/new). Be sure to include a **title and clear description**, as much relevant information as possible, and a **code sample or steps to reproduce** demonstrating the expected behavior that is not occurring.

Provide the following information:

- Your device information (Android/iOS version, device model).
- Flutter and Dart SDK versions.
- App version you're using.
- Any details about your setup that might be helpful in troubleshooting.
- Detailed steps to reproduce the bug.
- Screenshots or screen recordings if applicable.

### Suggesting Enhancements

If you have an idea for an enhancement, please first discuss the change you wish to make via a GitHub issue before making a change.

Provide the following information:

- A clear and descriptive title.
- A detailed description of the proposed enhancement.
- The motivation or use case for the enhancement.
- Any potential drawbacks or alternative solutions.
- Mockups or wireframes if applicable for UI changes.

### Pull Requests

Pull Requests (PRs) are the primary way to contribute code to this project.

1. **Fork the repository**:
    Click the "Fork" button at the top right of the [repository page](https://github.com/Udhay-Adithya/vit_ap_student_app).

2. **Clone your fork**:

    ```bash
    git clone https://github.com/your-name/vit_ap_student_app.git
    ```

3. **Create a new branch**:

    ```bash
    # For new features
    git checkout -b feature/your-feature-name
    # For bug fixes
    git checkout -b bugfix/issue-number-description
    # For UI improvements
    git checkout -b ui/improvement-description
    ```

4. **Set up your development environment**: Follow the [Development Setup](#development-setup) instructions.
5. **Make your changes**: Implement your feature or bug fix.
6. **Follow Coding Guidelines**: Ensure your code adheres to the [Coding Guidelines](#coding-guidelines).
7. **Add tests**: Write unit and widget tests for your changes.
8. **Commit your changes**: Use clear and descriptive [Commit Messages](#commit-messages).
9. **Push to your fork**: `git push origin feature/your-feature-name`.
10. **Open a Pull Request**: Go to the original repository and open a PR from your forked branch to the `main` branch of the original repository.
    - Provide a clear title and description for your PR, linking to any relevant issues.
    - Include screenshots for UI changes.
    - Ensure all automated checks (linters, tests) pass.

Project maintainers will review your PR and may request changes. Please be responsive to feedback.

## Development Setup

To set up the project for local development:

1. **Prerequisites**:
    - Flutter SDK 3.10+ ([Installation Guide](https://docs.flutter.dev/get-started/install))
    - Dart SDK (included with Flutter)
    - Rust toolchain ([Installation Guide](https://rustup.rs/))
    - Android Studio or VS Code with Flutter extensions
    - Android device/emulator (Android 6.0+) or iOS device/simulator

2. **Clone the repository** (if you haven't already forked and cloned):

    ```bash
    git clone https://github.com/your-name/vit_ap_student_app.git
    cd vit_ap_student_app
    ```

3. **Verify Flutter installation**:

    ```bash
    flutter doctor
    ```

    Resolve any issues shown by the doctor command.

4. **Install dependencies**:

    ```bash
    flutter pub get
    ```

5. **Rust setup** (if working on backend features):

    ```bash
    # Install Rust if not already installed
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source ~/.cargo/env
    
    # Verify Rust installation
    rustc --version
    cargo --version
    ```

6. **Run the application**:

    ```bash
    # First navigate to the rust folder to create a rust build
    cd rust
    cargo build --release

    # Make sure rust bindings are generated(if not do the step 7)
    # For debug mode
    flutter run
    
    # For specific platform
    flutter run -d android
    flutter run -d ios
    ```

7. **Code generation** (if applicable):

    ```bash
    # For generating model classes, routes, etc.
    dart run build_runner watch
    
    # For Rust bridge code generation
    flutter_rust_bridge_codegen generate --no-auto-upgrade-dependency
    ```

    The bridge is pinned to `flutter_rust_bridge` 2.12.0, and codegen also
    needs `cargo-expand`. Install the matching versions once:

    ```bash
    cargo install flutter_rust_bridge_codegen --version 2.12.0 --locked
    cargo install cargo-expand --locked
    ```

    Always pass `--no-auto-upgrade-dependency`. Without it, codegen bumps
    `flutter_rust_bridge` to its own version and rewrites every generated
    file. CI regenerates on every pull request and fails if the committed
    output differs.

## Coding Guidelines

### Flutter/Dart Style Guide

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide.
- Use `flutter analyze` to check for linting issues.
- Follow the existing project structure and naming conventions.
- Use meaningful variable and function names.
- Keep widgets small and focused on a single responsibility.
- Use proper state management patterns (currently using Riverpod).
- Add documentation comments for public APIs.
- Use type annotations where helpful for clarity.

### Rust Style Guide

- Follow the [Rust Style Guide](https://doc.rust-lang.org/nightly/style-guide/) and [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/).
- Use `cargo fmt` to format Rust code automatically.
- Use `cargo clippy` to check for common mistakes and improvements.
- Write comprehensive documentation for public functions and modules.
- Use meaningful variable and function names following Rust conventions (snake_case).
- Handle errors properly using `Result<T, E>` types.
- Use appropriate Rust idioms and patterns.
- Keep functions focused and avoid overly complex logic.
- Add unit tests for Rust functions using the built-in `#[cfg(test)]` attribute.

#### Rust Development Workflow

```bash
# Format Rust code
cargo fmt

# Check for linting issues
cargo clippy

# Run Rust tests
cargo test

# Build Rust code (done automatically by Flutter)
cargo build

# Generate Flutter-Rust bridge code
flutter_rust_bridge_codegen generate --no-auto-upgrade-dependency
```

### File Organization

```bash
lib/
├── core/                    # Core utilities, constants, themes
├── features/               # Feature-based organization
│   ├── feature_name/
│   │   ├── repository/     # Data access layer
│   │   ├── model/          # Data models
│   │   ├── viewmodel/      # Business logic (Riverpod providers)
│   │   └── view/           # UI components
│   │       ├── pages/      # Full screen pages
│   │       └── widgets/    # Reusable UI components
rust/
├── src/                    # Rust source code
│   ├── lib.rs             # Main library entry point
│   ├── api/               # API handling modules
│   └── utils/             # Utility functions
├── Cargo.toml             # Rust dependencies and configuration
└── target/                # Compiled Rust artifacts

rust_builder/              # Flutter-Rust bridge configuration
└── cargokit/             # Build tools for Rust integration
```

### Commit Messages

- Use the present tense ("Add feature" not "Added feature").
- Use the imperative mood ("Move button to..." not "Moves button to...").
- Limit the first line to 72 characters or less.
- Reference issues and PRs liberally.
- Consider using [Conventional Commits](https://www.conventionalcommits.org/) for structured commit messages:
  - `feat: add new timetable filtering options`
  - `fix: resolve attendance calculation bug`
  - `docs: update README with new setup instructions`
  - `refactor: improve weather service performance`
  - `test: add unit tests for profile parser`
  - `ui: improve dark theme contrast`
  - `perf: optimize image loading in gallery`
  - `rust: implement new VTOP API integration`
  - `rust: fix authentication error handling`
  - `bridge: update Flutter-Rust bridge bindings`

## Testing

### Unit Tests

- Write unit tests for business logic and data models.
- Tests should be located in the `test/` directory.
- Use the `test` package for unit testing.
- Mock external dependencies using `mockito` or similar packages.

### Widget Tests

- Write widget tests for custom widgets and complex UI components.
- Test user interactions and widget behavior.
- Ensure widgets render correctly across different screen sizes.

### Integration Tests

- Write integration tests for critical user flows.
- Test API integrations and data persistence.
- Test Flutter-Rust bridge functionality.

### Rust Tests

- Write unit tests for Rust functions and modules.
- Use the built-in Rust testing framework with `#[cfg(test)]` and `#[test]` attributes.
- Test error handling and edge cases.
- Mock external dependencies where necessary.

### Running Tests

```bash
# Run all Flutter tests
flutter test

# Run Flutter tests with coverage
flutter test --coverage

# Run specific Flutter test file
flutter test test/unit/models/student_test.dart

# Run Rust tests
cd rust && cargo test

# Run specific Rust test
cd rust && cargo test test_function_name
```

## Documentation

- Keep the `README.md` and other documentation files up-to-date with your changes.
- Add inline code documentation for complex logic.
- Update API documentation if you modify data models or services.
- Include screenshots for UI changes in your PR description.
- Update the changelog for significant changes.

## Community

Join the discussion! If you have questions or want to discuss ideas:

- Open an issue for bug reports or feature requests
- Participate in existing discussions
- Contact the maintainer at [udhayxd@gmail.com](mailto:udhayxd@gmail.com)

## Additional Notes

- This is a student-led project aimed at helping fellow VIT-AP students.
- Ensure your changes don't break existing functionality.
- Consider the impact on app performance and user experience.
- Be mindful of security implications, especially for authentication features.
- Test your changes on both Android and iOS if possible.
- When working with Rust code, ensure proper error handling and memory safety.
- Flutter-Rust bridge changes may require regenerating bindings.
- Rust compilation may take longer on first build due to dependency compilation.

Thank you for contributing to making student life at VIT-AP better!
