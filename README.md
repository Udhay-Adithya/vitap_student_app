
<br />
<p align="center">
    <img src="public/Final_Icon_512x512.png" width="100" height="100" style="margin-right: 60px;">
    <img src="public/vitaplogo.png" width="322" height="100">
</p>

##

<br>

<p align="center">
    <a href="https://github.com/Udhay-Adithya/vit_ap_student_app">
    <img src="https://img.shields.io/github/stars/Udhay-Adithya/vit_ap_student_app?style=social" alt="License: MIT">
    </a>
    <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
    </a>
    <img src="https://img.shields.io/badge/Version-2.3.2-blue.svg" alt="Version 2.3.2">
    <a href="https://github.com/Udhay-Adithya/vit_ap_student_app/issues">
    <img src="https://img.shields.io/github/issues/Udhay-Adithya/vit_ap_student_app" alt="License: MIT">
    </a>
    <h1 align="center">VITAP Student</h1>
    <p align="center">The VITAP Student App is a comprehensive mobile application designed to revolutionize the student experience at VIT-AP University. Built with Flutter, this app provides a seamless, user-friendly platform for students to access academic information, and stay informed.
    </p>
</p>
<br>

<p align="center">
    <a href="https://play.google.com/store/apps/details?id=com.udhay.vitapstudentapp">
        <img src="https://img.shields.io/badge/Google_Play-414141?logo=google-play&logoColor=white" alt="Get it on Google Play" height="80">
    </a>
    <a href="https://apps.apple.com/in/app/vitap-student/id6748966515">
        <img src="https://img.shields.io/badge/App_Store-0D96F6?logo=app-store&logoColor=white" alt="Get it on App Store" height="80">
    </a>
</p>
<br>

<img src="public/all_ip.png">

## 📦 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [Tech Stack](#-tech-stack)
- [API Integration](#-api-integration)
- [Performance Metrics](#-performance-metrics)
- [Security](#-security)
- [Future Roadmap](#-future-roadmap)
- [License](#-license)
- [Code of Conduct](#-code-of-conduct)
- [Contact](#-contact)

## 🚀 Features

- **🎓 Academic Data**
  - Attendance tracking
  - Detailed timetable management
  - Comprehensive profile information
  - Grade and performance insights
  - Outing requests with ease

- **⏰ Smart Notifications**
  - Class alerts
  - Exam alerts
  - Important university announcements

- **🌦️ Live Utilities**
  - Local weather updates
  - Campus event notifications
  - Quick access to useful student made tools

- **🎨 User Experience**
  - Adaptive theme modes
  - Responsive design
  - Intuitive navigation

## 💻 Installation

### Prerequisites

- Flutter SDK 3.10+
- Dart SDK
- Rust toolchain (for backend compilation)
- Android Studio or VS Code
- Android device/emulator (Android 6.0+)

### Setup Steps

1. Clone the repository

   ```bash
   git clone https://github.com/Udhay-Adithya/vit_ap_student_app.git
   cd vit_ap_student_app
   ```

2. Install Rust (if not already installed)

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source ~/.cargo/env
   ```

3. Install dependencies

   ```bash
   flutter pub get
   ```

4. Run the app

   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```bash
vitap_student_app/
│
├── assets/
│   ├── fonts/
│   ├── images/
│   ├── lottie/
│   └── weather_icons/
│
├── lib/
│   ├── core/
│   ├── features/
│   │   ├── feature/
│   │   │   └── repository/
│   │   │   └── model/
│   │   │   └── viewmodel/
│   │   │   └── view/
│   │   │       └── pages/
│   │   │       └── widgets/
│
├── rust/                 # Rust backend using flutter_rust_bridge
│   ├── src/              # Rust source code
│   ├── Cargo.toml        # Rust dependencies and configuration
│   └── target/           # Compiled Rust artifacts
│
└── rust_builder/         # Flutter-Rust bridge configuration
    └── cargokit/         # Build tools for Rust integration

```

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](/CONTRIBUTING.md) for guidelines.

## 🛠️ Tech Stack

- **Framework**: Flutter 3.24.2
- **State Management**: Riverpod
- **Backend**: Rust with `flutter_rust_bridge`
- **Network**: http
- **Persistence**: ObjectBox/Shared Preferences

## 🔌 Backend Integration

The app features a built-in Rust backend integrated via `flutter_rust_bridge`, providing:

- High-performance native processing
- Direct integration with VIT-AP VTOP
- Secure data handling and encryption
- Cross-platform compatibility

The Rust backend code is located in the `rust/` directory and handles all API communications and data processing internally.

## 🔒 Security

- **Platform-Specific Encryption**:
  - **iOS**: Keychain for secure credential storage
  - **Android**:
    - AES encryption for data protection
    - AES secret key encrypted with RSA
    - RSA key stored in Android KeyStore

## 💖 Support the Project

If you find this project helpful or interesting, consider **starring** the [GitHub repository](https://github.com/VITAP-Student-Project/vitap_student_app) — it really helps! 🌟

Donations are completely optional, but if you'd still like to show extra support:

- **Buy Me a Coffee**: [Support Project](https://www.buymeacoffee.com/udhayxdw)
- **Google Pay (GPay)**: [Donate via UPI](upi://pay?pa=udhayxd@okaxis&pn=Udhay%20Adithya&mc=0000&mode=02&purpose=00)

Your encouragement goes a long way in motivating student-led projects like this one. Thank you! 🙏

## 📄 License

Distributed under MIT License.
See `LICENSE` for more information.

## 📢 Disclaimer

> ***Note : This app is not an official application from VIT-AP University; it is developed by a fellow student for the benefit of other students. The app aims to provide a convenient tool for accessing academic information only.***

## 📧 Contact

Udhay Adithya - [udhayxd@gmail.com](mailto:udhayxd@gmail.com)

---

**Give a ⭐ to support the project!**

<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="
      https://api.star-history.com/svg?repos=VITAP-Student-Project/vitap_student_app&type=Date&theme=dark
    "
  />
  <source
    media="(prefers-color-scheme: light)"
    srcset="
      https://api.star-history.com/svg?repos=VITAP-Student-Project/vitap_student_app&type=Date
    "
  />
  <img
    alt="Star History Chart"
    src="https://api.star-history.com/svg?repos=VITAP-Student-Project/vitap_student_app&type=Date"
  />
</picture>
