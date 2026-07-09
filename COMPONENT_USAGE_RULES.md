# Component Usage Rules

This document defines when to use each shared UI component in the app.

## Core Principles

- Prefer shared components before writing page-local decoration.
- Use token files in `lib/theme/` for repeated visual values.
- Keep page widgets focused on layout and state, not raw styling.
- If a style repeats in two or more places, move it into the shared layer.

## Theme Tokens

Use these files first:

- `lib/theme/app_colors.dart`: color tokens and gradients
- `lib/theme/app_text_styles.dart`: shared typography styles
- `lib/theme/app_spacing.dart`: spacing tokens and common insets
- `lib/theme/app_radius.dart`: border radius tokens
- `lib/theme/app_shadows.dart`: shared shadow recipes
- `lib/theme/app_theme.dart`: app-wide Material theme wiring

## Shared Components

### `AppScreen`

Use for:
- Full-screen app pages with the standard gradient background
- Pages that need the standard gradient app bar
- Pages with a large title and optional subtitle

Do not use for:
- Temporary overlays
- Full-bleed custom experiences that intentionally break the main shell

### `AppSectionCard`

Use for:
- Grouped content blocks
- White or soft-gradient containers
- Reusable content sections inside pages

Rules:
- Prefer `AppSectionCard` over raw `Container` when a block has border, radius, and shadow
- Only add page-local styling if the section is clearly exceptional

### `AppPrimaryButton`

Use for:
- Primary CTA actions
- Start, Stop, Continue, Submit, Spin

Rules:
- There should usually be one primary action per local action group
- Use the default text style unless the button is a hero/button variant

### `AppSecondaryButton`

Use for:
- Alternate actions in dialogs
- Retry, Spin Again, Cancel-adjacent actions that should not overpower the primary CTA

### `AppInfoTile`

Use for:
- Settings rows
- Help/about/legal rows
- Navigable list items with icon + title + subtitle

Rules:
- Prefer this over custom `ListTile` wrappers in settings-like screens
- Keep titles short and subtitles explanatory

### `AppStatTile`

Use for:
- Small metric displays
- Dashboard-style summaries with icon + value + label

Rules:
- Use concise labels
- Keep values scannable and short

## When To Create A New Shared Component

Create a new shared component only if:

- The pattern appears in at least two screens, or
- The pattern is central to the app brand, or
- The pattern is likely to be reused for future features

Keep it page-local if:

- It is highly specific to one workflow
- It carries one-off content structure
- Generalizing it would introduce more parameters than clarity

## Naming Rules

- Shared widgets: `app_<role>.dart`
- Shared tokens: `app_<token_type>.dart`
- Keep component names semantic, not visual-only

Good:
- `AppInfoTile`
- `AppSectionCard`

Avoid:
- `PurpleCard`
- `RoundedBoxWidget`

## Change Management

Before adding a new style:

1. Check whether a token already exists.
2. Check whether a shared component already expresses the pattern.
3. If not, add the smallest shared abstraction that removes duplication.
4. Update `DESIGN_TOKENS.md` if the design language changes materially.
