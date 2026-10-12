# Nutrient Earth — Brand Source of Truth & Design System Specification

## 1. Executive Brand Identity & Vision

Nutrient Earth is an authoritative, evidence-driven Health Context & Decision Intelligence platform. Its mission is to eliminate guesswork from daily health decisions by transforming fragmented biological and nutritional data into verified, peer-reviewed, personalized guidance.

### The Brand Essence
- **Authority**: Rooted in biochemistry, clinical medicine, and deterministic reasoning. Never pseudoscientific or sensationalist.
- **Calmness**: A serene, distraction-free environment designed to reduce health anxiety rather than provoke panic or dopamine addiction.
- **Botanical Precision**: The harmony of organic botanical vitality and clinical precision—exemplified by the botanical evergreen, luminous chartreuse halo, and warm ivory canvas.

---

## 2. Logo Analysis & Authoritative Asset Rules

The official Nutrient Earth brand emblem (as defined in the authoritative visual asset) combines classical editorial typography, botanical organic growth, and luminous scientific energy.

```
       .---.               
     /       \             <- Luminous Chartreuse Ring Glow
    |  .---.  |            <- Deep Botanical Evergreen Bezel
    | |  N  | |            <- Classical Serif Monogram with Leaf Stem
    | |  E  | |            
    |  '---'  |            
     \       /             
       '---'               
  NUTRIENT EARTH           <- Tracked Geometric Sans-Serif
      — 🌿 —               <- Botanical Triad Symbol with Hairline Dividers
  A New LifeStyle          <- Elegant Display Serif Slogan
```

### Visual Components of the Emblem
1. **The Concentric Medallion**:
   - **Outer Luminous Ring**: A glowing chartreuse-to-emerald gradient halo (`#B4F35E` transitioning to `#133B2B`), evoking biological cellular energy and clean solar synthesis.
   - **Evergreen Bezel**: A solid deep forest green ring (`#0E382B`) providing structural weight and classical grounding.
   - **Inner Medallion Canvas**: A pure, tranquil warm ivory circular plate (`#FBF9F4`).
2. **The "NE" Monogram**:
   - High-contrast transitional/didone serif typography.
   - The diagonal stroke of the **'N'** integrates an organic, living botanical leaf, symbolizing biological nourishment rising directly from nature.
   - The **'E'** balances the letterform with classical proportions, horizontal baseline stability, and delicate serifs.
3. **The Wordmark**:
   - `NUTRIENT EARTH` is set in all-caps, modern geometric sans-serif with generous letter-spacing (+2.5 tracking), establishing modern clinical clarity.
4. **The Botanical Triad (`— 🌿 —`)**:
   - A symmetrical three-leaf botanical sprout flanked by delicate hairline horizontal rules (`0.75dp`), serving as the official brand punctuation mark.
5. **The Slogan ("A New LifeStyle")**:
   - Set in classical display serif, communicating human dignity, holistic wellness, and timeless lifestyle balance.

### Approved Brand Logo Variants
To ensure cross-platform consistency, six official logo variants are authorized:

| Variant | Composition | Primary Use Case | Background Compatibility |
|---|---|---|---|
| **Primary Vertical (Master)** | Circular Medallion + Wordmark + Botanical Triad + Slogan | Splash screen, Welcome/Onboarding hero, Brand collateral | Warm Ivory (`#FBF9F4`) or Pale Cream (`#F5F0E6`) |
| **Horizontal Lockup** | Medallion (left) + "NUTRIENT EARTH" Wordmark (right) | App bar, web navigation header, documentation headers | Light backgrounds (`#FFFFFF`, `#FBF9F4`) |
| **App Icon / Favicon** | Medallion only (Luminous ring + Evergreen Bezel + "NE" Monogram) | iOS/Android launcher icons, browser favicon, PWA manifest | Transparent or System Launcher canvas |
| **Dark Theme Variant** | Inverted Medallion (Evergreen background with Luminous Chartreuse text) | Settings dark theme, night-mode splash | Deep Forest (`#08231B`) |
| **Monochrome Print / Stamp** | Single-ink botanical evergreen (`#0E382B`) or black (`#000000`) | Clinical exports, PDF reports, laboratory data sheets | Pure White (`#FFFFFF`) |
| **Minimal Wordmark** | Text-only `NUTRIENT EARTH` with small botanical leaf | Dense application headers, modal titles | Any approved surface |

### Clear Space & Scale Constraints
- **Clear Space Rule**: The minimum exclusion zone around any logo lockup must equal half the height of the inner "NE" monogram ($0.5 \times H_{\text{monogram}}$). No text, buttons, or illustrations may enter this margin.
- **Minimum Digital Sizes**:
  - Full Master Lockup: Minimum height **72dp** / **96px**.
  - Horizontal Lockup: Minimum height **32dp** / **48px**.
  - Symbol-Only App Icon: Minimum size **24x24dp** / **32x32px**.
- **Prohibitions**:
  - Never distort, stretch, or alter the aspect ratio of the medallion or lettering.
  - Never alter the angle of the leaf inside the "N".
  - Never apply harsh drop shadows, 3D extrusions, or multi-colored outer strokes.
  - Never render the logo on high-contrast conflicting backgrounds (e.g., bright red, neon purple, or cluttered photographs without a darkening scrim).

---

## 3. Color Architecture & Token Specification

The color architecture directly translates the natural botanical atmosphere and clinical precision of the brand into accessible digital tokens.

### 3.1 Primary Brand Palette

```
#0E382B ── Botanical Evergreen (Primary Action & Brand Identity)
#1B4332 ── Evergreen Light (Hover / Secondary Brand Moments)
#08231B ── Deep Forest Obsidian (Primary Headings & High Contrast Text)
#B4F35E ── Luminous Lime (Illumination Accent & Active Evidence Highlights)
#FBF9F4 ── Warm Ivory (Primary Application Canvas)
```

| Token Name | Hex Code | Role & Usage Description | WCAG 2.1 Contrast on `#FBF9F4` |
|---|---|---|---|
| `neBotanicalEvergreen` | `#0E382B` | **Primary Brand Color**: Primary buttons, selected tab indicators, brand banners, key action states. | **11.2 : 1** (AAA Compliant) |
| `neEvergreenLight` | `#1B4332` | **Brand Interactive**: Hover states, active pressed states on primary components, secondary badges. | **8.4 : 1** (AAA Compliant) |
| `neDeepForest` | `#08231B` | **Obsidian Base**: Deepest structural backgrounds, high-contrast display headings, dark modal headers. | **13.8 : 1** (AAA Compliant) |
| `neLuminousLime` | `#B4F35E` | **Luminous Illumination Accent**: Micro-highlights, completed protocol rings, citation verified tags, subtle glow effects. | *Used as accent/badge, not body text* |
| `neChartreuseGlow` | `#9EE854` | **Active Interaction Glow**: Focus indicators, verified scientific badge boundaries. | *Used on dark evergreen surfaces: 7.8 : 1* |

### 3.2 Canvas & Surface Palette

| Token Name | Hex Code | Role & Usage Description |
|---|---|---|
| `neWarmIvory` | `#FBF9F4` | **Primary Application Canvas**: Default background for all screens (Ask, Explore, Growth, Body, Store). Provides serene warmth and eliminates harsh clinical white glare. |
| `neSurfaceWhite` | `#FFFFFF` | **Elevated Surface**: Primary cards, research query input containers, bottom navigation bar, floating dialogs. |
| `neSurfaceSubtle` | `#F3EFE6` | **Secondary Surface**: Inset containers, table headers, inactive tab chips, code blocks, quote containers. |
| `neSurfaceMuted` | `#ECE7DF` | **Tertiary Surface**: Subtle dividers, disabled button backgrounds, outline badge fills. |

### 3.3 Text & Typography Palette

| Token Name | Hex Code | Role & Usage Description | Contrast on `#FBF9F4` |
|---|---|---|---|
| `neTextPrimary` | `#112019` | **Primary Body & Heading**: Main clinical text, question composer input, titles, data values. | **12.6 : 1** (AAA) |
| `neTextSecondary` | `#526E60` | **Secondary Metadata**: Timestamps, author names, study dates, subtitle instructions. | **5.2 : 1** (AA) |
| `neTextTertiary` | `#7E9A8C` | **Subdued Label**: Inactive navigation labels, input placeholders, citation footnote labels. | **3.2 : 1** (Large text AA) |
| `neTextInverse` | `#FBF9F4` | **Inverted Text**: Text rendered over Botanical Evergreen buttons and deep surfaces. | **11.2 : 1** (AAA) |

### 3.4 Semantic Status & Clinical Feedback Palette

| Token Name | Hex Code | Role & Clinical Meaning |
|---|---|---|
| `neSuccessEmerald` | `#1E6B4A` | **Verified / Goal Achieved**: High-grade scientific evidence, completed daily habit, verified formulation assay. |
| `neSuccessSurface` | `#EBF5F0` | Tinted background for verified evidence chips and positive habit progress. |
| `neWarningAmber` | `#945B00` | **Caution / Conflicting Evidence**: Incomplete clinical trial data, mild allergen warning, tentative nutritional estimate. |
| `neWarningSurface` | `#FDF4E5` | Tinted background for caution callouts and dietary conflict alerts. |
| `neErrorCrimson` | `#BA1A1A` | **Clinical Alert / Red Flag**: Acute medical emergency triage banner, contraindicated drug-nutrient interaction, network failure. |
| `neErrorSurface` | `#FDECEB` | Tinted background for emergency medical triage warnings and query error states. |
| `neInfoSlate` | `#2D5C88` | **Educational Context / Note**: Informational notes, anatomy educational overlays, reference range details. |
| `neInfoSurface` | `#ECF3F9` | Tinted background for educational context callouts. |

### 3.5 Border, Divider & Shadow Tokens

| Token Name | Value | Purpose |
|---|---|---|
| `neBorderSubtle` | `#E3DDD3` (Solid 1.0dp) | Primary card borders, input field outlines, bottom sheet boundaries. |
| `neBorderDivider` | `#EFECE5` (Solid 0.75dp) | Internal table row dividers, list item separators, horizontal rule dividers. |
| `neShadowCard` | `BoxShadow(color: Color(0x0A0E382B), blurRadius: 12, offset: Offset(0, 3))` | Soft botanical card elevation with subtle evergreen shadow tint. |
| `neShadowElevated` | `BoxShadow(color: Color(0x140E382B), blurRadius: 20, offset: Offset(0, 6))` | Modal dialogs, floating action buttons, elevated bottom sheets. |
| `neShadowLuminous` | `BoxShadow(color: Color(0x4DB4F35E), blurRadius: 16, offset: Offset(0, 0))` | **Reserved Brand Illumination**: Research completion pulse, logo splash halo. |

### 3.6 Strict Restraint Rule for Luminous Halo
The luminous green ring from the logo (`#B4F35E`) represents biological illumination.
- **Permitted**: Splash screen entrance, brand mark illumination, active completion ring on a verified research answer, success badge icon highlights.
- **Prohibited**: Never apply full-screen glowing backgrounds, continuous pulsing outlines around standard cards, glowing text, or neon buttons. Illumination is a high-value signal, not decorative wallpaper.

---

## 4. Typography Hierarchy & Rules

The typographic system utilizes a dual-font architecture:
1. **Editorial Display Serif (`Playfair Display` or `Georgia`)**: Evokes classical scientific literature, botanical journals, and trusted medical compendiums.
2. **Functional Sans-Serif (`Inter` or `Roboto`)**: Provides maximum digital clarity, accessibility, and high data density for biometrics, citations, and interactive controls.

### 4.1 Type Scale Specification

| Style Token | Font Family | Size (sp) | Weight | Line Height | Letter Spacing | Primary Purpose |
|---|---|---|---|---|---|---|
| `neDisplayLarge` | Display Serif | **32** | Bold (700) | 1.25 (40sp) | -0.5sp | Welcome hero titles, major editorial milestones. |
| `neDisplayMedium` | Display Serif | **26** | Bold (700) | 1.30 (34sp) | -0.3sp | Screen titles on desktop/tablet, feature hero headings. |
| `neHeadingLarge` | Display Serif | **22** | SemiBold (600) | 1.35 (30sp) | -0.2sp | Research question title, major section headings. |
| `neHeadingMedium` | Functional Sans | **18** | SemiBold (600) | 1.40 (25sp) | 0.0sp | Card headers, modal titles, evidence topic titles. |
| `neHeadingSmall` | Functional Sans | **16** | SemiBold (600) | 1.40 (22sp) | +0.1sp | Sub-headers, form field titles, anatomical region labels. |
| `neBodyLarge` | Functional Sans | **16** | Regular (400) | 1.55 (25sp) | +0.15sp | Primary research answer prose, reading paragraphs. |
| `neBodyMedium` | Functional Sans | **14** | Regular (400) | 1.50 (21sp) | +0.1sp | Standard card descriptions, biometrics summaries, settings items. |
| `neBodySmall` | Functional Sans | **12** | Regular (400) | 1.45 (17sp) | +0.2sp | Metadata footnotes, timestamp captions, disclaimer text. |
| `neLabelLarge` | Functional Sans | **14** | SemiBold (600) | 1.30 (18sp) | +0.25sp | Primary button text, tab navigation labels, action chips. |
| `neLabelSmall` | Functional Sans | **11** | Medium (500) | 1.25 (14sp) | +0.3sp | Bottom navigation bar labels, evidence tag badges. |
| `neNumericData` | Functional Sans (Tabular) | **18–28** | Bold (700) | 1.15 | -0.2sp | Biometric measurements (`120/80`, `94%`, `28.5`). Always uses tabular numbers. |
| `neCitationText` | Functional Sans | **12** | Medium (500) | 1.35 (16sp) | +0.1sp | Inline superscript citation badges `[1]`, DOI references, PubMed IDs. |

### 4.2 Prohibited Typographic Usages
- Never use the Display Serif for dense body text, medical tables, dosage charts, or interactive buttons.
- Never use ultra-thin font weights (`w100` or `w200`) on mobile screens as they degrade readability under daylight.
- Never all-caps continuous sentences or long paragraphs. All-caps is reserved exclusively for tracked category tags (`NUTRITION PROTOCOL`, `PUBMED ID`) and the master wordmark.

---

## 5. Spatial Grid, Layout & Component Geometry

### 5.1 The 4dp Spatial Grid
All margins, padding, spacing, and dimensions are strictly derived from an 8-point base grid with 4dp half-step increments:

| Spacing Token | Value (dp) | Primary Application |
|---|---|---|
| `neSpacing4` | **4.0** | Icon-to-label gaps, tight badge padding, chip internal margins. |
| `neSpacing8` | **8.0** | Compact element spacing, input icon insets, row item gaps. |
| `neSpacing12` | **12.0** | Sub-item margins, compact card internal padding. |
| `neSpacing16` | **16.0** | Standard card internal padding, list item vertical gaps, screen edge insets (compact mobile). |
| `neSpacing20` | **20.0** | Standard screen edge insets (standard mobile/tablet). |
| `neSpacing24` | **24.0** | Section dividers, header-to-content spacing, modal padding. |
| `neSpacing32` | **32.0** | Major workspace section separation, empty-state vertical spacing. |
| `neSpacing48` | **48.0** | Hero section bottom margin, desktop gutter width. |
| `neSpacing64` | **64.0** | Desktop top padding, welcome hero top offset. |

### 5.2 Component Geometry & Radii Scale

| Radius Token | Value (dp) | Permitted Components |
|---|---|---|
| `neRadius8` | **8.0** | Small action buttons, thumbnail images, compact badge containers. |
| `neRadius12` | **12.0** | Input fields, query composers, sub-cards, nested data tables. |
| `neRadius16` | **16.0** | Primary cards (Research cards, Explore topic cards, Habit cards). |
| `neRadius24` | **24.0** | Bottom sheet top corners, full-width modal dialogs. |
| `neRadiusPill` | **999.0** | Filter chips, tag pills, primary pill buttons, avatar containers. |

### 5.3 Responsive Layout Rules
- **Mobile (< 600dp)**:
  - Screen edge padding: `20dp` horizontal.
  - Cards take 100% of usable width.
  - Bottom navigation bar is anchored to bottom with safe-area insets.
- **Tablet (600dp – 1024dp)**:
  - Screen edge padding: `32dp` horizontal.
  - Max reading width for research answers: **680dp** (centered on screen).
  - Cards organize into a balanced 2-column responsive grid.
- **Desktop (> 1024dp)**:
  - Max container width: **1200dp**.
  - Dual-column or master-detail split layout for research workspace (Query & Answer left, Evidence Drawer right).
  - Navigation adapts to a persistent, dignified left rail with icon and label.

### 5.4 Touch Targets & Accessibility
- Every interactive element (buttons, icon taps, citation chips, checklist toggles) must have a touch target of at least **48x48dp**.
- Touch targets smaller than 48dp visually must extend invisible tap margins via `Padding` or `HitTestBehavior`.

---

## 6. Shared Motion & Transition Specification

Motion in Nutrient Earth must reinforce cause-and-effect, express organic calm, and respect user efficiency. It must never act as decorative delay or give the false impression that a medical calculation has been performed simply because a wheel is spinning.

### 6.1 Duration Tokens & Targets

| Target Duration | Value (ms) | Usage |
|---|---|---|
| `neMotionImmediate` | **120ms** | Micro-interactions: Button press down, checkbox toggle, icon state change. |
| `neMotionComponent` | **180ms** | Component transitions: Chip selection, accordion expand/collapse, card hover elevation. |
| `neMotionSurface` | **240ms** | Surface transitions: Tab switching, modal bottom sheet presentation, search bar expansion. |
| `neMotionIntentional`| **320ms** | Intentional reveals: Research answer completion entrance, full-screen dialog transition. |

### 6.2 Easing Curves
- **Standard Decelerate (`Curves.easeOutCubic`)**: Used for incoming elements, sheets opening, and answer reveals. The animation starts quickly and settles gently.
- **Standard Accelerate (`Curves.easeInCubic`)**: Used for exiting elements, dismissed modals, and cleared inputs.
- **Natural Spring / Bounce**: Strictly prohibited for medical data, test results, and error notifications. Subtle spring (`SpringDescription(mass: 1.0, stiffness: 180.0, damping: 20.0)`) is permitted only on button taps.

### 6.3 Accessibility & Reduced Motion
- When the user's operating system requests `prefers-reduced-motion`:
  - All positional slides, scale bounces, and translation animations are disabled.
  - Transitions collapse to immediate duration or a gentle `100ms` opacity crossfade.
  - No motion may autoplay indefinitely.

---

## 7. Unified Five-Destination Navigation Architecture

Nutrient Earth establishes a permanent, immutable five-field architecture:

```
[ 🧪 Ask ]    [ 🔬 Explore ]    [ 📈 Growth ]    [ 🫀 Body ]    [ 🌿 Store ]
```

### 7.1 Navigation Invariants
1. **Ask is the Primary Default**: Upon successful launch and authentication, the application opens directly into **Ask** (`/ask`). Users are never blocked by mandatory onboarding questionnaires.
2. **Session Preservation Across Tab Switches**: Switching tabs preserves scroll position, in-progress drafts, and loaded research.
3. **No Duplicate Navigation Bars**: Child detail pages (e.g. source inspection, study details) either push on top of the shell or retain the root navigation bar cleanly without nested duplicates.
4. **Desktop Navigation Rail**: On screens wider than 1024dp, the bottom bar cleanly transforms into a vertical left navigation rail anchored with the official horizontal logo.
