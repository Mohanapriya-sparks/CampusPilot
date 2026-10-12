# Contributing to CampusPilot 🚀

Thank you for your interest in contributing to **CampusPilot**! CampusPilot is an open-source personalized student opportunity discovery MVP designed to help college students bridge skill gaps and discover hackathons, workshops, open-source programs, and competitions tailored to their profiles.

We welcome community contributions, bug reports, feature suggestions, and documentation improvements.

---

## Code of Conduct

We are committed to providing a welcoming, inclusive, and harassment-free environment for everyone. Please be respectful, constructive, and collaborative in all discussions and code reviews.

---

## How Can You Contribute?

1. **Reporting Bugs**: Check existing issues first. If your issue is new, open a bug report using the GitHub issue template with reproduction steps.
2. **Suggesting Enhancements**: Propose ideas for matching heuristics, new opportunity categories, UI/UX polish, or integration ideas.
3. **Submitting Pull Requests**: Implement bug fixes, features, or documentation improvements.

---

## Development Setup

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version `>=3.3.0 <4.0.0`, tested on Flutter `3.24.5` / Dart `3.5.4`)
- Chrome browser (for Flutter Web development)
- Android Studio / VS Code with Flutter extension
- Firebase account (optional for local mock testing; required for live auth)

### Getting Started

1. **Fork the repository** on GitHub.
2. **Clone your fork locally**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/CampusPilot.git
   cd CampusPilot
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run code quality checks**:
   ```bash
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   flutter test
   ```
5. **Run the app locally**:
   ```bash
   # Launch on Chrome
   flutter run -d chrome

   # Or on connected Android device / emulator
   flutter run
   ```

---

## Branching & Commit Guidelines

- Create a feature branch from `main`:
  ```bash
  git checkout -b feature/opportunity-filter-enhancement
  ```
  or for bug fixes:
  ```bash
  git checkout -b fix/profile-drawer-overflow
  ```
- Write clear, conventional commit messages:
  - `feat: add category filter for open source programs`
  - `fix: resolve drawer subtitle text overflow on small viewports`
  - `docs: improve Firebase setup instructions in README`
  - `test: add unit tests for opportunity fit score calculation`

---

## Code Quality Standards

Before submitting a Pull Request, ensure that:

1. `dart format lib` has been executed to adhere to official Dart formatting rules.
2. `flutter analyze` produces **zero errors and zero warnings**.
3. `flutter test` passes successfully.
4. No secrets, credentials, or private keys are added to version control.
5. All new widgets and services maintain clean separation of concerns.

---

## Submitting a Pull Request (PR)

1. Push your branch to your GitHub fork:
   ```bash
   git push origin feature/your-feature-name
   ```
2. Open a Pull Request targeting the `main` branch of `Mohanapriya-sparks/CampusPilot`.
3. Complete the pull request template describing the changes, motivation, and verification steps.
4. Respond to feedback during review. Once approved and CI passes, your contribution will be merged!

---

Thank you for helping empower students worldwide through CampusPilot! 🎓
