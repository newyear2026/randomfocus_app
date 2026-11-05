# RandomFocus

RandomFocus is a Flutter focus-timer app built around a roulette-style time picker, timer sessions, history tracking, ads, and a progressively systematized design/UI/UX layer.

## D-Day Goal

Open **Settings → D-Day goal** to save a goal name and target date. The focus
timer displays the goal; tap its card to edit or delete it without resetting a
running session. One goal is saved locally, including across app restarts.
The countdown uses local calendar days: `D-n`, `D-Day`, then `D+n` after the date.
It refreshes at midnight and when the app resumes. D-Day does not require Pro.
If the saved goal is unreadable, its recovery action asks for confirmation,
backs up the damaged value locally, and resets only the goal. Timer/history
data are preserved. The timer uses a side-by-side layout in short wide windows
and supports scrolling when space is limited.

## Documentation Index

### Product / Release

- [PROJECT_RULES.md](PROJECT_RULES.md)
- [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)
- [PLAY_CONSOLE_SETUP.md](PLAY_CONSOLE_SETUP.md)
- [GOOGLE_PLAY_BILLING.md](GOOGLE_PLAY_BILLING.md)
- [GOOGLE_PLAY_DESCRIPTION.md](GOOGLE_PLAY_DESCRIPTION.md)
- [PRIVACY_POLICY.md](PRIVACY_POLICY.md)

### Design System

- [DESIGN_TOKENS.md](DESIGN_TOKENS.md)
- [COMPONENT_USAGE_RULES.md](COMPONENT_USAGE_RULES.md)
- [RESPONSIVE_GUIDE.md](RESPONSIVE_GUIDE.md)
- [VISUAL_REGRESSION_GUIDE.md](VISUAL_REGRESSION_GUIDE.md)

### UX / Writing / Accessibility

- [UX_GUIDE.md](UX_GUIDE.md)
- [UI_WRITING_GUIDE.md](UI_WRITING_GUIDE.md)
- [ACCESSIBILITY_GUIDE.md](ACCESSIBILITY_GUIDE.md)
- [PR_DESIGN_CHECKLIST.md](PR_DESIGN_CHECKLIST.md)

### Testing / Workflow

- [TEST_ARTIFACT_POLICY.md](TEST_ARTIFACT_POLICY.md)

## Local Verification

Run:

- `flutter analyze`
- `flutter test`
