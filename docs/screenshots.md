# CampusPilot Screenshot Directory & Visual Specifications 📸

This document outlines the visual specifications and screenshot assets for the **CampusPilot Flutter MVP**.

---

## Screenshot Matrix

| Screen Name | File Path | Status | Resolution | Description |
| ----------- | --------- | ------ | ---------- | ----------- |
| **01. Login & Auth** | `docs/screenshots/01_login.png` | `[Placeholder]` | 1080 x 2400 (Mobile) / 1920 x 1080 (Web) | Firebase Auth screen with Email/Password & Google Sign-In |
| **02. Student Profile Wizard** | `docs/screenshots/02_student_profile.png` | `[Placeholder]` | 1080 x 2400 (Mobile) / 1920 x 1080 (Web) | Multi-step onboarding form capturing college, degree, skills, and links |
| **03. Opportunity Explorer** | `docs/screenshots/03_opportunity_explorer.png` | `[Placeholder]` | 1080 x 2400 (Mobile) / 1920 x 1080 (Web) | Catalog with category chips, search bar, and Fit Score indicators |
| **04. Event Details & Match** | `docs/screenshots/04_event_details.png` | `[Placeholder]` | 1080 x 2400 (Mobile) / 1920 x 1080 (Web) | Comprehensive opportunity view with recommendation breakdown & registration action |
| **05. Skill Readiness Sprint** | `docs/screenshots/05_skill_readiness.png` | `[Placeholder]` | 1080 x 2400 (Mobile) / 1920 x 1080 (Web) | Mini-sprint questionnaire and dynamic readiness percentage score |
| **06. Preparation Path** | `docs/screenshots/06_preparation_path.png` | `[Placeholder]` | 1080 x 2400 (Mobile) / 1920 x 1080 (Web) | Milestone roadmap, curated resource cards, and checklist progress |
| **07. Profile Drawer** | `docs/screenshots/07_profile_drawer.png` | `[Placeholder]` | 1080 x 2400 (Mobile) / 1920 x 1080 (Web) | Slide-out drawer with student banner, college info, social handles, and navigation |

---

## Guidelines for Capturing Screenshots

When recording real screenshots during live demos:

1. **Flutter Web**:
   - Run: `flutter run -d chrome`
   - Use standard desktop browser window (1280 x 800) or mobile device preview (iPhone 14 / Pixel 7).
   - Ensure demo student profile is pre-filled with clean data.
2. **Android Emulator**:
   - Run: `flutter run -d emulator`
   - Use `adb exec-out screencap -p > screenshot.png` for lossless capture.
3. **Asset Organization**:
   - Save all captured images directly to `docs/screenshots/` with lowercase snake_case naming.
   - Run `pngquant` or lossless compression to keep repository size minimal.
