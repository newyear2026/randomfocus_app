# Accessibility Guide

This document defines the baseline accessibility rules for the app.

## Principles

- Meaning must not depend on color alone.
- Tap targets must remain comfortably tappable.
- Text must stay readable under larger text scales.
- Important custom controls should expose clear semantics.

## Tap Targets

- Minimum target: `48x48`
- Prefer `56x56` or larger for primary mobile controls

## Text

- Use shared text styles to preserve hierarchy
- Avoid clipping under longer translations
- Verify numeric UI remains stable and readable

## Contrast

- Check white text over gradients carefully
- Avoid low-opacity text for essential information
- Ensure primary actions remain clearly distinguishable

## Semantics

Add labels for:
- Icon-only buttons
- Refresh actions
- Close actions
- Save/share actions
- Custom interactive controls

Examples:
- `Refresh history`
- `Close timer page`
- `Save app icon`

## Motion

- Motion should support orientation, not decoration only
- Avoid stacking multiple moving elements unnecessarily

## State Feedback

- Loading, empty, error, and confirmation states need readable text
- Error states should provide a clear recovery path
- Snackbars should not be the only place critical information appears

## Responsive Behavior

- Validate small phone layouts first
- Check large text scale for wrapping and clipping
- Avoid rigid fixed-height content regions for text-heavy states

## QA Checklist

1. Can the primary action be found quickly?
2. Are icon-only actions understandable?
3. Does the screen work at larger text scales?
4. Are empty and error states readable?
5. Are contrast and tap targets still safe on mobile?
