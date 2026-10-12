## Description
Please include a summary of the change and which issue it fixes. Also include relevant motivation and context.

Fixes #(issue)

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Code formatting / refactoring (no behavioral changes)

## Affected Areas
- [ ] Authentication (`lib/auth_gate.dart`, `lib/screens/login_screen.dart`, `lib/screens/signup_screen.dart`)
- [ ] Student Profile (`lib/models/student_profile.dart`, `lib/screens/profile_setup_screen.dart`)
- [ ] Opportunity Discovery (`lib/screens/opportunity_explorer_screen.dart`, `lib/models/opportunity.dart`)
- [ ] Event Details (`lib/screens/event_details_screen.dart`)
- [ ] Skill Readiness Sprint (`lib/screens/skill_sprint_challenge_screen.dart`, `lib/screens/skill_sprint_result_screen.dart`)
- [ ] Preparation Path (`lib/screens/event_learning_path_screen.dart`, `lib/screens/bridge_mission_screen.dart`)
- [ ] Drawer & Navigation (`lib/widgets/profile_drawer.dart`, `lib/screens/main_shell.dart`)
- [ ] CI/CD or Repository Documentation

## How Has This Been Tested?
Please describe the tests that you ran to verify your changes.

- [ ] Run `dart format lib` (clean format)
- [ ] Run `flutter analyze` (zero issues found)
- [ ] Run `flutter test` (all tests passed)
- [ ] Tested on Chrome web (`flutter run -d chrome`)
- [ ] Tested on Android / iOS / Desktop (if applicable)

## Checklist
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings or analyzer lints
- [ ] No private secrets, credentials, or API tokens have been committed
