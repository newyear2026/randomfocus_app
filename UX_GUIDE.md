# UX Guide

This document captures the app's current UX rules and expected interaction behavior.

## Product Flow

Primary loop:

1. User opens the app.
2. User lands on the roulette screen.
3. User spins to receive a random focus duration.
4. User starts the focus timer.
5. On focus completion, the app records the session and starts break time.
6. User returns to the main flow and can review history or settings.

## UX Principles

- Keep the primary action obvious on every screen.
- Reduce choice during focus mode.
- Preserve continuity between roulette, timer, and history.
- Show progress visually before explaining it with text.
- Avoid blocking the user with unnecessary prompts.

## Screen Rules

### Splash

- Show brand quickly and transition automatically.
- Do not ask for input.
- Keep dwell time short.

### Home Navigation

- Bottom navigation should preserve state between tabs.
- The selected tab must be visually stronger than inactive tabs.
- History refresh should happen when the user explicitly returns to that tab.

### Roulette

- The spin action is the clear primary CTA.
- The wheel result should feel celebratory but still readable.
- The result dialog should offer one clear next step: start timer.
- Secondary retry should exist but not dominate the primary CTA.

### Timer

- During active focus, the UI should reduce escape routes.
- The timer value is the dominant element on screen.
- State labels must always explain whether the user is focusing, on break, or paused.
- Leaving an in-progress timer should require confirmation.
- Completion should transition into break smoothly without extra friction.

### History

- Users should be able to understand progress at a glance.
- Calendar marks should indicate meaningful completed activity.
- Summary stats should be compact and immediately scannable.

### Settings

- Rows should be easy to scan and tap.
- Labels should be plain-language, not technical.
- Legal/help/about information should be grouped with the same interaction pattern.

## Interaction Rules

- Use one primary CTA per section when possible.
- Use secondary actions for retries, alternate routes, or lower-priority tasks.
- Prefer direct manipulation and single-tap actions over multi-step flows.
- Dialogs should answer one question at a time.

## Feedback Rules

- Loading states should be visible but lightweight.
- Important state changes should have immediate visual confirmation.
- Failure feedback should be short and actionable.
- Non-critical failures should not break the main task flow.

## Data / Persistence UX

- Language, history, and spin state should persist across launches.
- Daily spin limits should reset automatically with no manual recovery needed.
- Session history should reflect whether a session was completed or stopped.

## Accessibility / Clarity

- Tap targets should remain comfortably touchable.
- Important labels should not rely only on color.
- Numeric information should be large and stable.
- Text hierarchy should remain consistent across screens.

## Future UX Work

- Add explicit empty-state copy standards
- Define snackbar/toast usage rules
- Define confirmation-dialog thresholds
- Add accessibility checks for contrast and screen reader labels
