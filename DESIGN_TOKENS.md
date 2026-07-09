# Design Tokens

This document captures the design tokens and reusable UI rules currently used by the Flutter app.

## Color Tokens

### Brand
- `brandPrimary`: `#673AB7`
- `brandSecondary`: `#3F51B5`
- `brandAccent`: `#9C27B0`
- `brandSurface`: `#FFFFFF`

### Backgrounds
- `screenBackgroundStart`: `deepPurple.shade50`
- `screenBackgroundMid`: `purple.shade50`
- `screenBackgroundEnd`: `#FFFFFF`

### App Bar
- `appBarStart`: `deepPurple.shade700`
- `appBarMid`: `deepPurple.shade500`
- `appBarEnd`: `purple.shade400`

### Status / Utility
- `success`: `#10B981`
- `warning`: `#FF9800`
- `danger`: `#EF4444`
- `info`: `#3B82F6`
- `textPrimary`: `#1F2937`
- `textSecondary`: `#4B5563`
- `textMuted`: `#6B7280`
- `borderSubtle`: brand primary at `0.14`

### Roulette Segment Colors
- `25m`: `#FF9800`
- `30m`: `#EF4444`
- `45m`: `#10B981`
- `50m`: `#6366F1`
- `60m`: `#3B82F6`
- `90m`: `#EC4899`

## Typography Tokens

### Titles
- `screenTitle`: `26 / w900 / letterSpacing 1.2 / white`
- `sectionTitle`: `22 / w900 / letterSpacing 0.5`
- `statValue`: `16 / w900 / letterSpacing 0.8`

### Body
- `tileTitle`: `18 / w800`
- `tileSubtitle`: `14 / w500 / muted`
- `body`: `15 / height 1.6`
- `caption`: `13 / w600`

### Numeric / Emphasis
- `timerDisplay`: `72 / w900 / tabular figures`
- `heroButton`: `22-26 / w900 / letterSpacing 1.5-2.0`

## Shape Tokens

- `inputRadius`: `12`
- `tileRadius`: `16`
- `cardRadius`: `18`
- `largeCardRadius`: `28`
- `pillRadius`: `30`
- `heroButtonRadius`: `36`

## Spacing Tokens

- `screenHorizontal`: `24`
- `sectionGap`: `16`
- `tileGap`: `8`
- `cardPadding`: `20`
- `largeCardPadding`: `32`
- `buttonHeight`: `60`
- `heroButtonHeight`: `68`

Code source: `lib/theme/app_spacing.dart`

## Elevation / Shadow Tokens

- `cardShadow`: blur `12-20`, y `4-6`, opacity `0.08-0.15`
- `heroShadow`: blur `20-30`, y `8-10`, opacity `0.2-0.5`
- `iconShadow`: blur `8-10`, y `3`, opacity `0.25-0.3`

Code source: `lib/theme/app_shadows.dart`

## Radius Tokens

- `input`: `12`
- `badge`: `14`
- `tile`: `16`
- `card`: `18`
- `cardLarge`: `20`
- `dialog`: `28`
- `button`: `30`
- `heroButton`: `36`

Code source: `lib/theme/app_radius.dart`

## Reusable Patterns

### Screen Frame
- Gradient screen background
- Transparent scaffold
- Gradient app bar
- Large centered title with compact subtitle

### Section Card
- White or soft gradient background
- Rounded corners
- One subtle border
- Purple-tinted shadow

### Settings / Info Tile
- Card shell
- Gradient icon badge
- Strong title + muted subtitle
- Optional chevron / trailing control

### CTA Button
- Purple gradient fill
- Large rounded corners
- White bold text
- One strong outer shadow

### Stats Tile
- Circular icon badge
- Bold value
- Compact two-line label

## Current Gaps

- Some pages still contain screen-specific decoration values inline.
- Spacing and shadow constants are documented here, but only color and text tokens are fully centralized in code.
- Timer naming still mixes minutes/seconds in a few identifiers.
