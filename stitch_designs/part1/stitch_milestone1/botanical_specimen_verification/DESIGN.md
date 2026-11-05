---
name: Botanical Specimen Verification
colors:
  surface: '#fbf9f4'
  surface-dim: '#dbdad5'
  surface-bright: '#fbf9f4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3ee'
  surface-container: '#f0eee9'
  surface-container-high: '#eae8e3'
  surface-container-highest: '#e4e2dd'
  on-surface: '#1b1c19'
  on-surface-variant: '#414845'
  inverse-surface: '#30312e'
  inverse-on-surface: '#f2f1ec'
  outline: '#717975'
  outline-variant: '#c1c8c4'
  surface-tint: '#43655b'
  primary: '#000a06'
  on-primary: '#ffffff'
  primary-container: '#00251d'
  on-primary-container: '#6b8e83'
  inverse-primary: '#a9cec2'
  secondary: '#38675a'
  on-secondary: '#ffffff'
  secondary-container: '#b8eada'
  on-secondary-container: '#3c6b5e'
  tertiary: '#000b04'
  on-tertiary: '#ffffff'
  tertiary-container: '#002614'
  on-tertiary-container: '#6a9077'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c5ebdd'
  primary-fixed-dim: '#a9cec2'
  on-primary-fixed: '#002019'
  on-primary-fixed-variant: '#2b4d44'
  secondary-fixed: '#bbeddc'
  secondary-fixed-dim: '#9fd1c1'
  on-secondary-fixed: '#002019'
  on-secondary-fixed-variant: '#1f4f43'
  tertiary-fixed: '#c3eccf'
  tertiary-fixed-dim: '#a8d0b4'
  on-tertiary-fixed: '#002111'
  on-tertiary-fixed-variant: '#2a4e39'
  background: '#fbf9f4'
  on-background: '#1b1c19'
  surface-variant: '#e4e2dd'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Manrope
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.015em
  headline-lg:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Manrope
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.005em
  headline-sm:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: 0.02em
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
---

## Brand & Style

### Brand Personality & Core Mood
This design system bridges botanical organic warmth with rigorous laboratory-grade precision. It serves investigative scientific workflows, multimodal analysis, and agricultural verification. The interface evokes credibility, calm clarity, analytical trust, and grounded luxury. It eliminates visual noise in favor of data integrity, structured verification trails, and tactile natural surfaces.

### Design Movement & Visual Language
The aesthetic merges **Modern Scientific Minimalism** with **Organic Tactility**:
- Crisp, legible sans-serif typography engineered for high-density diagnostic data.
- Natural, warm ivory reading surfaces paired with layered deep forest shadows and luminous botanical highlights.
- Evidence-first visual structures: pill counters, confidence telemetry dials, spectral analysis chips, and cryptographic verification status indicators.
- Rounded contours (8–12px baseline) that soften technical rigor into an approachable, field-ready instrument.

## Colors

### Palette System
The palette is rooted in deep evergreen canopy tones balanced against warm organic parchment backdrops.

- **Primary (`#163B32`)**: Used for primary action containers, definitive verified state indicators, active headers, and navigation anchors.
- **Secondary (`#235347`)**: Applied to sub-headers, interactive borders, and secondary action framing.
- **Tertiary (`#8EB69B`)**: Soft muted sage used for interactive states, chip highlights, analytical graphs, and active focus boundaries.
- **Neutral Canvas (`#FAF8F3`)**: The core background tone. Mimics archival botanical paper, avoiding stark blue-light eye strain during long field investigations.
- **Surface Variant (`#F5EFE8`)**: Warm parchment tone for nested evidence containers, filter docks, and card bodies.
- **Deep Canopy Black (`#051F20` / `#0B2B26`)**: High-contrast typography and maximum-emphasis iconography.
- **Pale Botanical Ivory (`#DAF1DE`)**: Subtle success tints, scanner beam scrims, and verified badge fills.

### Semantic & Verification Tokens
- **Verified / High Confidence**: `#163B32` text on `#DAF1DE` badge background (contrast ratio > 7:1).
- **Flagged / Variance Detected**: `#A75743` with warm terra-cotta tint.
- **Pending Analysis**: Deep amber gold `#7A5B12` on muted parchment.
- All core text combinations strictly comply with WCAG AA standard (minimum 4.5:1 for body copy and 3:1 for large display elements).

## Typography

### Structural Decisions
- **Display & Body (`Manrope`)**: Provides a balance of clean geometric discipline and modern open apertures. It maintains absolute legibility when presenting dense chemical taxonomy, geographical coordinates, and laboratory field notes.
- **Telemetry & Labels (`JetBrains Mono`)**: Assigned to verification hashes, specimen batch numbers, confidence percentiles, and timestamp metadata. The monospaced cadence reinforces technical exactness and mechanical authenticity.

### Hierarchy & Responsive Behavior
- Large headlines gracefully step down on viewports below 600px width (`display-lg` compresses to `display-lg-mobile`) to prevent awkward line breaks in narrow mobile viewports.
- Body copy line height adheres strictly to 1.45–1.5x font size for sustained readability over warm background surfaces.

## Layout & Spacing

### Layout Architecture
- Built on a **Fluid-Responsive Grid** conforming to an 8-point base rhythm, with 4-point micro-adjustments for compact telemetry readouts.
- **Mobile (<600px)**: 4 columns, `margin: 1rem`, `gutter: 1rem`. Bottom sheets, sticky thumb-zone triggers, and single-column multimodal feeds.
- **Tablet (600px - 1024px)**: 8 columns, `margin: 1.5rem`, `gutter: 1.25rem`. Split specimen-viewer and evidence dossier panels.
- **Desktop (>1024px)**: 12 columns, max content envelope `1280px`, `margin: 2.5rem`, `gutter: 1.5rem`. Multi-pane workspace featuring specimen viewport, metadata rail, and validation pipeline.

### Internal Spacing Rhythm
- Compact UI controls (chips, status pills, table cells) leverage `space-xs` (4px) and `space-sm` (8px).
- Evidence modules and visual specimen preview blocks utilize `space-md` (12px) padding and `space-lg` (20px) separating gaps.

## Elevation & Depth

### Atmospheric Tonal Layering
Rather than using heavy dropped shadows, depth is achieved through layered organic surfaces and subtle light refraction:

1. **Level 0 (Base Canvas)**: Flat `#FAF8F3` archival neutral surface.
2. **Level 1 (Card Panels & Dossier Blocks)**: Surface `#F5EFE8` with an ultra-fine border: `1px solid rgba(22, 59, 50, 0.08)`. Shadow: `0 2px 6px -1px rgba(5, 31, 32, 0.04)`.
3. **Level 2 (Hovered Cards & Interactive Controls)**: Shadow: `0 8px 20px -3px rgba(5, 31, 32, 0.08)`, subtle border shift to `rgba(35, 83, 71, 0.20)`.
4. **Level 3 (Modal Sheets, Diagnostic HUDs & Camera Overlays)**: Surface `#051F20` with 88% opacity and `backdrop-filter: blur(12px)`. Subtle glow ring: `0 0 0 1px rgba(142, 182, 155, 0.24), 0 16px 32px -4px rgba(5, 31, 32, 0.25)`.

## Shapes

### Contour Strategy
The system adopts roundedness level `2` to balance high-tech instrumentation with organic touchpoints:
- **Base Components (Inputs, Buttons, Cards)**: `8px` to `10px` radius (`rounded-md`).
- **Surface Cards & Inspection Panels**: `12px` to `16px` radius (`rounded-lg`).
- **Telemetry Chips, Verified Badges & Filter Pills**: Full pill geometry (`rounded-full` / `9999px`) to match the soft organic pebble aesthetic shown in the specimen palettes.

## Components

### Buttons
- **Primary Action (Verify / Submit / Scan)**: Background `#163B32`, text `#FAF8F3`, font weight 600. Radius `10px`. Hover transitions to `#0B2B26`. Active state scales subtly (`scale(0.98)`).
- **Secondary Action**: Transparent background, border `1.5px solid #235347`, text `#163B32`. Radius `10px`.
- **Ghost / Utility**: Text `#235347`, hover background `rgba(35, 83, 71, 0.08)`.

### Verification Chips & Telemetry Tags
- **Confidence Metric Pill**: Full pill shape, padding `4px 10px`. Monospaced label (`JetBrains Mono`, 11px).
  - *High Confidence (>95%)*: `#DAF1DE` background with `#0B2B26` text and a `#163B32` circular status dot.
  - *Review Needed*: `#F5EFE8` background with `#7A5B12` text.
- **Specimen World Tags**: Pill container with subtle colored background tints matching the five worlds (Forest `#DAF1DE`, Earth `#F5EFE8`, Growth `#FBF7EA`, Water `#E6EEF3`, Bloom `#F8EEF1`).

### Form Fields & Analysis Inputs
- **Text Inputs**: Height `44px`, background `#FFFFFF` or `#F5EFE8`, border `1px solid rgba(22, 59, 50, 0.16)`, radius `8px`.
- **Focus State**: Border color `#235347`, ambient ring `0 0 0 3px rgba(142, 182, 155, 0.25)`.
- **Attached Metadata Prefix**: Monospace uppercase label embedded into leading container slot.

### Cards & Evidence Containers
- **Diagnostic Specimen Card**: `#F5EFE8` interior background, 12px rounded corner, 1px perimeter line `rgba(22, 59, 50, 0.08)`. Internal padding `16px`. Header features title in `Manrope` semibold alongside monospaced specimen ID.

### Checkboxes & Segmented Selectors
- **Selection Controls**: Checkbox has a 4px corner radius, `#163B32` fill when active with `#FAF8F3` check icon.
- **Segmented Verification Toggle**: Pill-style segmented track in `#EFE8DF` with an active sliding pill in `#FAF8F3` boasting an elevation-1 shadow.Generate exactly five screens per batch. Use the attached design.md, original NE logo, and approved six-color palette as the source of truth. Never change the palette. No demo data, mock users, preloaded information, fabricated health records, fake citations, invented results, or sample notifications. All user fields must remain blank and selections unselected until the actual user provides information. Design genuine first-run empty states. Maintain exactly two primary tabs: Research and Goals. Do not invent features or extra screens. Keep every screen production-oriented, accessible, consistent, and ready for review before generating the next batch.

Apply world-class UI/UX principles and production-level engineering judgment to every screen: clear visual hierarchy, intuitive navigation, consistent design tokens, reusable components, responsive layouts, accessible contrast and text sizing, appropriate interaction states, privacy-conscious information design, and predictable user flows. Prioritize clarity, usability, maintainability, and realistic implementation over decorative effects. Ensure every screen has a defined purpose, clear primary action, sensible back/navigation behavior, and appropriate empty, loading, error, disabled, and success states where relevant. Do not cram the entire product into onboarding or a single screen. Include only the content and controls necessary for the current screen; additional details, questions, and capabilities will be designed in their appropriate later screens and batches. Follow established platform conventions and the attached design specification. Do not imply that prototype interactions, authentication, data persistence, research, or submissions work unless actually implemented. Generate only the requested five screens, then stop for review and approval before continuing.