# Responsive Guide

This document defines the baseline responsive behavior for the app UI.

## Breakpoints

- Small phone: `< 360`
- Standard phone: `360 - 599`
- Tablet / large layout: `>= 600`

## Rules

- Primary actions must remain visible without horizontal scrolling.
- Large circular widgets should scale down on narrow screens.
- Dense statistic layouts should wrap or stack when width is tight.
- Text-heavy content should wrap or scroll before clipping.

## Screen Guidance

### Roulette

- Wheel size scales down on small phones
- Padding reduces slightly on narrow screens
- CTA stays full width

### Timer

- Timer ring scales with available width
- Controls remain reachable on short screens
- Secondary controls must not push the timer out of view

### History

- Stats should stack or wrap on constrained width
- Calendar remains primary but should not make stats unreadable

### Settings

- Keep single-column layout
- Prefer bottom sheets for option selection on mobile

## QA Checklist

1. Test width `320`
2. Test width `390`
3. Test width `768`
4. Test long translated strings
5. Test larger text scale
