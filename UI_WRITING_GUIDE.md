# UI Writing Guide

This document defines the app's UI writing rules.

## Principles

- Be short.
- Be explicit.
- Prefer user-facing language over system language.
- Keep one message focused on one job.

## Tone

- Calm
- Direct
- Clear
- Non-technical by default

## Button Labels

- Prefer explicit verbs.
- Keep labels to 1-2 words when possible.

Good:
- `Start`
- `Retry`
- `Refresh`
- `Save`

Avoid:
- `OK` when a clearer action exists
- `Proceed` when `Continue` or `Start` is clearer

## Confirmation Copy

Use:
- Short title
- One sentence explaining the consequence
- One cancel action
- One explicit confirm action

Pattern:
- Title: `Go back?`
- Body: `Your timer page will close.`
- Buttons: `Cancel` / `Go Back`

## Loading Copy

- Optional if loading is brief
- Use short progress phrasing

Examples:
- `Loading...`
- `Loading history...`
- `Preparing timer...`

## Empty State Copy

Use 3 parts:

1. Title
2. One short explanation
3. Optional recovery action

Pattern:
- Title: `No History Yet`
- Body: `Complete a focus session to see it here.`
- Action: `Refresh`

## Error Copy

- State what failed
- Do not blame the user
- Offer one recovery action if possible

Examples:
- `Could not load history.`
- `Could not open the privacy policy.`
- `Saving failed. Please try again.`

## Success Copy

- Only show when useful
- Keep shorter than error copy

Examples:
- `Icon saved.`
- `Language updated.`

## Length Rules

- Button: 1-2 words
- Dialog title: under 4 words when possible
- Snackbar: one short sentence
- Empty/error body: 1-2 short sentences

## Formatting Rules

- Sentence case
- No emoji in product UI
- Avoid all caps
- Avoid repeated punctuation

## Localization Rules

- Avoid idioms
- Avoid slang
- Avoid culture-specific jokes or metaphors
