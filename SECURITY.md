# Security Policy 🔒

## Supported Versions

Only the latest release and the current `main` branch receive active security updates.

| Version | Supported          |
| ------- | ------------------ |
| 2.0.x   | :white_check_mark: |
| < 2.0.0 | :x:                |

---

## Reporting a Vulnerability

The CampusPilot maintainers take privacy and application security seriously. If you discover a security vulnerability, please do **NOT** open a public issue.

Instead, please report it privately:

1. **Email**: Reach out to the maintainer at `sagana6002@gmail.com` with the subject prefix `[SECURITY VULNERABILITY] CampusPilot`.
2. **Details to include**:
   - Detailed description of the vulnerability.
   - Steps to reproduce or proof-of-concept code.
   - Impact assessment on student data or authentication integrity.
   - Recommended remediation if known.

### Response Time
- **Acknowledgment**: Within 48 hours.
- **Assessment & Status Update**: Within 5 business days.
- **Fix & Public Advisory**: Once a patch is developed and thoroughly tested.

---

## Security Best Practices in CampusPilot

- **Zero Secret Commits**: Private credentials, Firebase Service Account tokens, OAuth client secrets, and environment tokens must **never** be committed to version control.
- **Client Configuration vs. Server Secrets**: Only public Firebase client options intended for the Flutter client (`firebase_options.dart`) are kept in the client codebase. All sensitive API keys or administrative operations belong strictly in isolated backend services.
- **Student Data Privacy**: Student profile records (college, degree, contact details, resume links) must be scoped by authenticated Firebase UID and protected with appropriate Firestore Security Rules.
