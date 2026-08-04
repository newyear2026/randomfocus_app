# Design Tokens

This document captures the design tokens and reusable UI rules currently used by the Flutter app.

All values that get painted on screen resolve through `BuildContext` so light and
dark mode share one token vocabulary. Never hardcode `Colors.white` or
`Colors.deepPurple.shadeXXX` in a page or widget — reach for a token instead.

Code source: `lib/theme/`

## Color Tokens

### Brand

- `brandPrimary`: `Colors.deepPurple`
- `brandPrimaryDark`: `#CFBCFF` (dark mode accent)
- `onBrandPrimaryDark`: `#381E72`
- `brandSecondary`: `#3F51B5`
- `brandAccent`: `Colors.purple`

### Context-resolved roles

| Token | Light | Dark |
| --- | --- | --- |
| `accent` | `deepPurple.shade600` | `#CFBCFF` |
| `onAccent` | `#FFFFFF` | `#381E72` |
| `accentStrong` | `deepPurple.shade800` | `#CFBCFF` |
| `surface` | `#FFFFFF` | `#211E26` |
| `surfaceMuted` | `#F7F5FB` | `#2B2930` |
| `background` | `#FFFFFF` | `#141218` |
| `textPrimary` | `#1F2937` | `#E7E0EC` |
| `textSecondary` | `#4B5563` | `#CAC4D0` |
| `textMuted` | `#6B7280` | `#948F99` |
| `subtleBorder` | brand primary @ `0.14` | `#49454F` |
| `onAppBar` | `#FFFFFF` | `#E7E0EC` |

### Gradients

- `screenBackground`: light `deepPurple.50 → purple.50 → white`; dark near-flat `#141218 → #181521 → #141218`
- `appBarGradient`: light `deepPurple.700 → deepPurple.500 → purple.400`; dark flat `#211E26`
- `primaryActionGradient`: light `deepPurple.600 → deepPurple → purple.600`; dark flat `#CFBCFF`

### Session status

Status colors are separate from roulette segment colors so "completed" never
shares a hue with a duration segment.

| Token | Light | Dark |
| --- | --- | --- |
| `statusSuccess` | `#0F7A56` | `#4ADE80` |
| `statusWarning` | `#B45309` | `#FBBF24` |
| `statusDanger` | `#B91C1C` | `#FCA5A5` |
| `statusFill` | status @ `0.12` | status @ `0.22` |

### Roulette Segment Colors

| Minutes | Light | Dark |
| --- | --- | --- |
| `25` | `#FF9800` | `#B26A12` |
| `30` | `#EF4444` | `#A8393A` |
| `45` | `#10B981` | `#0D7357` |
| `50` | `#6366F1` | `#4A4CB8` |
| `60` | `#3B82F6` | `#2A5FA8` |
| `90` | `#EC4899` | `#A83571` |

Dark variants are desaturated so the wheel does not glow against a dark surface.

Code source: `lib/theme/app_colors.dart`

## Typography Tokens

No text style carries a shadow. Contrast comes from color; shadows only blur
glyph edges and cost render time.

Two weights carry the hierarchy: `w600` for emphasis, `w400`–`w500` for body.

### Titles

- `appBarTitle`: `22 / w700 / letterSpacing 0.2`
- `sectionTitle`: `20 / w700`
- `groupLabel`: `13 / w600 / letterSpacing 0.4 / secondary` — form group headers
- `tileTitle`: `16 / w600`

### Body

- `body`: `15 / height 1.6 / secondary`
- `tileSubtitle`: `14 / w400 / muted`
- `appBarSubtitle`: `13 / w500 / onAppBar @ 0.85`

### Numeric / Emphasis

- `timerDisplay`: `64 / w600 / tabular figures`
- `statValue`: `17 / w700`
- `statLabel`: `12 / w500 / muted` — never below 11
- `buttonLabel`: `17 / w600 / letterSpacing 0.3`
- `largeButtonLabel`: `20 / w600 / letterSpacing 0.5`

Code source: `lib/theme/app_text_styles.dart`

## Radius Tokens

Material 3 shape scale, five steps only.

- `input`: `12`
- `badge`: `12`
- `tile`: `16`
- `card`: `16`
- `cardLarge`: `24`
- `dialog`: `28`
- `button`: `30` (pill for height 60)
- `heroButton`: `34` (pill for height 68)

Code source: `lib/theme/app_radius.dart`

## Spacing Tokens

- `xxs 2` · `xs 4` · `sm 8` · `md 12` · `lg 16` · `xl 20` · `xxl 24` · `xxxl 32` · `hero 40` · `section 48`
- `screenHorizontal`: `24`
- `cardPadding`: `20`
- `largeCardPadding`: `32`
- `buttonHeight`: `60`
- `heroButtonHeight`: `68`

Code source: `lib/theme/app_spacing.dart`

## Elevation / Shadow Tokens

Shadows communicate "this surface floats above another". Decorative stacking is
not allowed — a single shadow per elevated surface.

- `card`: blur `10`, y `2` — the only shadow in the system
- `button`, `iconBadge`, `statBadge`: intentionally empty; these are flat and
  rely on color contrast

Code source: `lib/theme/app_shadows.dart`

## Reusable Patterns

### Screen Frame

- Gradient screen background (near-flat in dark)
- Transparent scaffold
- Gradient app bar (flat surface in dark)
- Centered title with compact subtitle

### Section Card

- `surface` background, one hairline border, one soft shadow
- `AppRadius.card`, or `cardLarge` for hero containers

### Settings / Info Tile

- Flat tinted square icon badge (no nested gradients)
- `tileTitle` + muted subtitle
- Optional chevron or trailing control
- `grouped: true` drops the per-tile card so several tiles share one card with
  dividers

### CTA Button

- `primaryActionGradient` fill, pill radius, `onAccent` label
- No shadow; disabled state drops fill to `0.38` alpha

### Stats Tile

- Circular tinted icon badge
- `statValue` over `statLabel`

### Progress Ring

- Stroke `9`, rounded caps, track at accent `0.14`
- Value is always real progress — never a decorative constant
- Animates to its target over `280ms`

### Bottom Navigation

- Fixed `64` height; icon size and padding never change with selection
- Selection shown by a `56x32` pill behind the icon

## Accessibility Floors

- Minimum touch target `48x48` (calendar rows use `48`)
- Minimum font size `11`
- Meaning is never carried by color alone (calendar markers also vary in density)
