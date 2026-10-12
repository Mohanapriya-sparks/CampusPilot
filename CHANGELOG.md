# Changelog 📋

All notable changes to the **CampusPilot** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2026-10-12

### Added
- **Authentication Flow**:
  - Firebase Authentication integration with Email/Password and Google sign-in scaffolding.
  - Persistent auth session gating (`AuthGate`) supporting auto-login and session cleanup.
- **Student Profile Management**:
  - Comprehensive student profile model capturing College, Degree, Department, Year, Technical Skills, Domain Interests, Preferred Opportunity Types, GitHub, and LinkedIn links.
  - Profile setup with multi-step validation and editing capabilities.
  - Scoped local persistence using `SharedPreferences` keyed by Firebase UID.
- **Opportunity Explorer**:
  - Multi-category opportunity discovery feed (Hackathons, Workshops, Open Source, Competitions, Student Events).
  - Search query filtering across titles, organizers, descriptions, and required skills.
  - Dynamic category chip selection with real-time result count indicators.
  - Rule-based opportunity fit scoring percentage calculation based on student skills and target opportunity requirements.
- **Opportunity Details Screen**:
  - Complete event metadata display: organizer, dates, location, attendance mode (Online/Offline/Hybrid), entry fee, eligibility, and descriptions.
  - Personal Fit Score breakdown with transparent recommendation explanations.
  - Bookmarking and Saved Events functionality with immediate persistence.
  - External URL launcher integration for registration links.
- **Skill Readiness Sprint**:
  - Interactive skill-gap identification and mini-challenge sprint.
  - Dynamic readiness scoring gauge and personalized feedback.
- **Preparation Path & Open Source Flow**:
  - Tailored preparation milestones with step progress tracking.
  - Curated learning resource cards and checklist progress saving.
  - Dedicated open-source onboarding sequence for first-time student contributors.
- **Profile Drawer & Navigation**:
  - Modern sliding drawer with custom student avatar, college metadata, social quick-links, and navigation shortcuts.
  - Direct routes to My Profile, Saved Events, Open Source Path, Skill Readiness, Settings, and Secure Sign-out.
- **Engineering & CI/CD**:
  - Clean GitHub Actions workflow (`flutter_ci.yml`) for automated formatting, linting, analysis, and test suites.
  - Comprehensive documentation covering architecture, MVP user flows, and screenshot specifications.
  - Safe `.gitignore` and `.env.example` configurations.

### Changed
- Standardized typography and unified warm underrated color palette (`AppColors`) across all screens.
- Upgraded FlutterFire dependencies and cleaned analysis lints for 100% compliance.
