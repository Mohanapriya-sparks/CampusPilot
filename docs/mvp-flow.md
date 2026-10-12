# CampusPilot MVP User Journey & Screen Flow 🗺️

This document describes the end-to-end user experience, screen transitions, and state management flow for the **CampusPilot MVP**.

---

## 1. Journey Map

```mermaid
sequenceDiagram
    autonumber
    actor Student as College Student
    participant Gate as AuthGate
    participant Auth as Login / Signup
    participant Profile as Profile Wizard
    participant Explorer as Opportunity Explorer
    participant Details as Event Details
    participant Sprint as Skill Sprint
    participant Prep as Prep Path
    participant Drawer as Profile Drawer

    Student->>Gate: Opens Application
    Gate->>Auth: User not signed in
    Student->>Auth: Signs up / Logs in via Email or Google
    Auth->>Gate: Firebase Auth Token verified
    Gate->>Profile: Checks if profile exists (First time)
    Student->>Profile: Completes 7-step profile setup
    Profile->>Explorer: Redirects to Opportunities Catalog
    Student->>Explorer: Filters by Hackathon / Open Source
    Student->>Explorer: Enters search keyword "Flutter"
    Explorer->>Details: Taps on Opportunity Card
    Student->>Details: Views Fit % & Recommendation Explanation
    Student->>Details: Saves event to Bookmarks
    Student->>Details: Clicks "Check Skill Readiness"
    Details->>Sprint: Launches Skill Sprint Challenge
    Student->>Sprint: Completes interactive quiz sprint
    Sprint->>Prep: Displays Readiness Score & Skill Gaps
    Student->>Prep: Explores step-by-step learning milestones
    Student->>Drawer: Opens side drawer from top bar
    Drawer->>Explorer: Navigates back or signs out
```

---

## 2. Screen-by-Screen Flow Breakdown

### Step 1: Authentication (`LoginScreen` / `SignupScreen`)
- **Purpose**: Secure student identity and namespace all local records.
- **Features**:
  - Email and password authentication with form validation.
  - Google Sign-In button for rapid one-tap authentication.
  - Seamless toggle between Log In and Create Account.
  - Error banner handling (invalid credentials, weak passwords, connection issues).

### Step 2: Student Profile Setup (`ProfileSetupScreen`)
- **Purpose**: Collect the foundational data needed for personalized opportunity matching.
- **Progressive Sections**:
  1. **Personal Information**: Full Name, Contact info, Graduation year.
  2. **Academic Details**: College / University name, Degree (B.Tech, B.Sc, BCA, MCA), Department / Major.
  3. **Technical Skills**: Interactive multi-select tags (Python, Flutter, React, Machine Learning, Docker, SQL, etc.).
  4. **Interests**: Domains of excitement (Artificial Intelligence, Web3, Cloud, Cybersecurity, Open Source).
  5. **Preferred Opportunity Types**: Hackathons, Hands-on Workshops, Open Source programs, Competitions, Campus Meetups.
  6. **Professional Links**: GitHub profile link and LinkedIn profile link for external portfolio discovery.
  7. **Review & Save**: Summary verification before writing to local storage and app state.

### Step 3: Opportunity Explorer (`OpportunityExplorerScreen`)
- **Purpose**: Unified feed of curated student opportunities.
- **Key Capabilities**:
  - **Live Search Bar**: Real-time filtering across titles, organizers, and required technologies.
  - **Category Pills**: Quick category switching between `All`, `Hackathons`, `Workshops`, `Open Source`, and `Competitions`.
  - **Fit Percentage Badge**: Highlighting how strongly each opportunity aligns with the student's registered skills.
  - **Mode Indicator**: Badges displaying whether the event is `Online`, `Offline`, or `Hybrid`.

### Step 4: Opportunity Details (`EventDetailsScreen`)
- **Purpose**: Comprehensive event information and decision support.
- **Details Presented**:
  - Event title, organizing body, and event banner.
  - Timeline (Registration deadline, event start date).
  - Mode, location venue, and entry fee.
  - Full description, eligibility criteria, and required technologies.
  - **Match Analysis**: Visual gauge showing the exact match percentage and explanation of which skills matched.
  - **Action Controls**:
    - "Save Event" toggle (bookmarks for later review).
    - "Register Now" button (launches official registration URL via `url_launcher`).
    - "Check Readiness" button (launches the skill sprint).

### Step 5: Skill Readiness Sprint (`SkillSprintChallengeScreen` & `SkillSprintResultScreen`)
- **Purpose**: Give students immediate feedback on their readiness before competing.
- **Features**:
  - Mini sprint challenge with 3–5 targeted questions on prerequisites.
  - Instant scoring with a dynamic readiness meter.
  - Clear identification of skill strengths and missing gap areas.

### Step 6: Personalized Preparation Path (`EventLearningPathScreen` & `BridgeMissionScreen`)
- **Purpose**: Turn discovered gaps into an actionable study and building plan.
- **Features**:
  - Step-by-step milestones (e.g., Step 1: Git basics, Step 2: API integration, Step 3: Project submission).
  - Curated resource cards linking to documentation, video guides, and starter repositories.
  - Interactive checkboxes to monitor completion progress.
  - Dedicated open-source readiness workflow for first-time contributors.

### Step 7: Profile Drawer & Settings (`ProfileDrawer`)
- **Purpose**: Centralized navigation and profile overview.
- **Drawer Elements**:
  - Student avatar with initials.
  - Name, college, degree, and academic year.
  - Quick clickable links to student's GitHub and LinkedIn profiles.
  - Navigation menu:
    - `My Profile` (opens profile editor)
    - `Saved Events` (displays bookmarked opportunities)
    - `Open Source Path` (dedicated open source contributor pathway)
    - `Skill Readiness` (readiness benchmarking dashboard)
    - `Settings`
    - `Logout` (clears in-memory session and terminates Firebase credentials)
