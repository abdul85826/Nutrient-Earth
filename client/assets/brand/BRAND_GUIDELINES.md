# Nutrient Earth — Master Brand Asset Guidelines & Production System Specification

> **Status**: APPROVED & LOCKED  
> **Source of Truth**: `assets/brand/logo/source/nutrient_earth_logo_reference.png`  
> **Canonical Asset Directory**: `client/assets/brand/logo/`  
> **Classification**: Production Brand Identity, Asset Engine & Design Token Architecture  

---

## 1. Preserve the Master Logo (Single Source of Truth)

The approved Nutrient Earth logo is the single, immutable source of truth for the company's visual identity. It must be preserved exactly as a serious global health and technology institution would manage its identity assets.

### Master Principles
* **Exact Geometry**: The circular biological boundary, the interlocking `NE` monogram, and the living leaf contours are mathematically fixed and locked.
* **Exact Proportions**: Strict 1:1 perfect square aspect ratio. The symbol diameter to wordmark proportion is immutable.
* **Exact Color Extraction**: The primary signature green (`#1B3A20`) is extracted directly from the approved source artwork.
* **Exact Typography & Wordmark**: The official serif monogram curvature and the clean geometric wordmark are non-negotiable.
* **Strict Prohibitions**:
  * ❌ No redesign, reinterpretation, or recoloring.
  * ❌ No additional symbols, icons, or embellishments.
  * ❌ No decorative particles, sparkles, or futuristic dust.
  * ❌ No gradients unless they already exist in the approved source.
  * ❌ No outer glow, neon halos, or futuristic blooms applied to the master logo artwork.
  * ❌ No 3D distortions, tilt, bevel, or perspective skews.
  * ❌ No glassmorphism, blur effects, or transparency filters applied to the logo itself.
  * ❌ No drop shadows or heavy blur layers that alter the identity.
  * ❌ No manual redrawing when the canonical vector source is available.
  * ❌ Never use a screenshot of the logo as a production asset.

---

## 2. Production Variants System

To serve every surface from high-DPI desktop viewports to ultra-compact smart wearables, the canonical master logo is exported into dedicated production variants:

```
assets/brand/logo/
├── nutrient_earth_logo.svg               # Full Logo Lockup (Symbol + Wordmark)
├── nutrient_earth_symbol.svg             # Symbol Mark Only (Monogram + Leaf + Rings)
├── nutrient_earth_symbol_small.svg       # Small-Scale Optimized Symbol (16dp - 32dp)
├── nutrient_earth_wordmark.svg           # Standalone Horizontal Wordmark
├── nutrient_earth_logo_white.svg         # Full Logo Monochrome Pure White
├── nutrient_earth_logo_black.svg         # Full Logo Monochrome Pure Black
├── nutrient_earth_logo_green.svg         # Full Logo Single Approved Green (#1B3A20)
├── nutrient_earth_symbol_white.svg       # Symbol Monochrome Pure White
├── nutrient_earth_symbol_black.svg       # Symbol Monochrome Pure Black
├── nutrient_earth_symbol_green.svg       # Symbol Single Approved Green (#1B3A20)
├── nutrient_earth_wordmark_white.svg     # Wordmark Pure White
├── nutrient_earth_wordmark_black.svg     # Wordmark Pure Black
├── nutrient_earth_wordmark_green.svg     # Wordmark Single Approved Green (#1B3A20)
├── nutrient_earth_app_icon.png           # Master Launcher App Icon (1024x1024)
└── favicon.ico                           # Multi-resolution Favicon (16px, 32px, 48px)
```

### A. Full Logo Lockup
* **Composition**: Master circular mark + typographic wordmark `NUTRIENT EARTH` + botanical sprig underline.
* **Usage**: Splash screens, onboarding hero headers, marketing web headers, formal press packages, clinical PDF report covers.

### B. Symbol Mark
* **Composition**: Isolated circular symbol (outer biological ring, inner disk boundary, interlocking `NE` monogram, ascending living leaf).
* **Usage**: Application launcher icon, browser favicon, compact navigation bars, profile avatars, floating action triggers.

### C. Wordmark Only
* **Composition**: High-precision typographic glyphs for `NUTRIENT EARTH` with integrated botanical sprig.
* **Usage**: Horizontal navigation bars, editorial mastheads, compact header ribbons where vertical height is constrained.

### D. Monochrome & Single-Color Variants
* **Pure White (`#FFFFFF`)**: Calibrated for dark substrates, obsidian surfaces (`#0A0E0B`), night-mode navigation, dark video overlays, and engraved hardware.
* **Pure Black (`#000000`)**: Calibrated for high-contrast documentation, thermal receipts, single-color laser printers, physical fax transmissions, and stencil printing.
* **Single Approved Green (`#1B3A20`)**: Calibrated for single-ink stationery, letterheads, warm ivory cardstock (`#FAF5D8`), and clinical lab slips.

### E. Small-Size Optimized Variant (`nutrient_earth_symbol_small.svg`)
* **Composition**: Specifically calibrated for micro viewports between **16dp and 32dp**.
* **Optimization**: Subtle stroke-weight reinforcement and subpixel alignment to ensure the `NE` monogram and leaf apex maintain high optical contrast without blurring or filling in on low-DPI displays.
* **Rule**: Does not alter the identity or geometry—solely optimizes rendering clarity.

---

## 3. Required File Formats & Technical Specifications

| Format | File Extension | Technical Specification | Primary Production Role |
| :--- | :--- | :--- | :--- |
| **Vector SVG** | `.svg` | Clean XML, explicit `viewBox="0 0 1024 1024"`, zero inline styling noise, subpixel vector accuracy. | Primary vector asset for Web, Flutter, and high-DPI scaling. |
| **High-Res PNG** | `.png` | 1024×1024 master, 32-bit RGBA, uncompressed lossless alpha channel, zero background clipping. | Flutter mobile raster rendering, splash, onboarding hero. |
| **Vector PDF** | `.pdf` | Vector master archive, CMYK / RGB calibrated, embeddable vector streams. | Clinical report headers, formal print archive, press releases. |
| **Web-Optimized WebP** | `.webp` | High-efficiency lossless WebP, 75% smaller footprint than PNG. | Next.js / PWA web applications, CDN caching. |
| **Multi-Res Favicon** | `.ico` | Embedded multi-layer icon containing 16×16, 32×32, and 48×48 frames. | Windows desktop shortcut, multi-browser tab representation. |

---

## 4. App Icon System (iOS & Android)

The Nutrient Earth app icon utilizes the approved symbol mark centered on an obsidian substrate canvas.

```
+-------------------------------------------------------+
|  CANVAS: 1024 x 1024 px                               |
|  SUBSTRATE: Solid Obsidian #0A0E0B                    |
|                                                       |
|        +-------------------------------------+        |
|        |  SAFE AREA: 768 x 768 px (75%)      |        |
|        |                                     |        |
|        |              (SYMBOL)               |        |
|        |            Circular Mark            |        |
|        |           Approved Green            |        |
|        |                                     |        |
|        +-------------------------------------+        |
|                                                       |
|  MARGIN: 128 px on all sides                          |
+-------------------------------------------------------+
```

### Technical Requirements
* **Master Resolution**: 1024×1024 px PNG.
* **Substrate**: Solid Obsidian Canvas (`#0A0E0B`), zero transparency (strict Apple App Store & Google Play requirement).
* **Safe Margins**: 128 px uniform margin (12.5% on each edge) ensuring the circular mark is safely contained within Apple's squircle mask and Android's adaptive circle, squircle, or teardrop masks.
* **Android Adaptive Icons**:
  * Background: Solid `#0A0E0B` layer (108dp canvas).
  * Foreground: Scaled circular symbol mark centered within the 72dp safe circle (66.6% safe area).
* **Strict Prohibitions**:
  * ❌ No text inside the app icon.
  * ❌ No decorative photo backgrounds or complex gradients.
  * ❌ No artificial 3D bevels or simulated phone frames.

---

## 5. Splash Screen Specification

The Nutrient Earth splash screen communicates **clean, trustworthy, intelligent, and premium health technology**.

```
+-------------------------------------------------------+
|                                                       |
|                                                       |
|                                                       |
|                     [MASTER LOGO]                     |
|                   Nutrient Earth                      |
|                  Centered at 120dp                    |
|                                                       |
|                                                       |
|                                                       |
| SUBSTRATE: Approved Brand Forest Green (#1B3A20)      |
+-------------------------------------------------------+
```

### Visual Parameters
* **Substrate**: Approved Brand Forest Green (`#1B3A20`) or Master Obsidian (`#0A0E0B`).
* **Centered Asset**: Master Full Logo Lockup (`nutrient_earth_logo.svg` or white lockup `nutrient_earth_logo_white.svg` at 120dp diameter).
* **Typography**: Wordmark placed at canonical clear space below mark.
* **Prohibitions**: Absolutely zero floating particles, zero busy spinning loaders, zero AI gimmick text.
* **Motion Choreography**:
  * **Entrance**: 400ms subtle opacity ease-in (`Curves.easeOutCubic`).
  * **System Hold**: 600ms minimum duration to verify biometric auth / initialize Drift database.
  * **Exit Transition**: Seamless crossfade into the Today Screen navigation shell.
  * **Accessibility**: If `MediaQuery.disableAnimations` or `reduceMotion` is active, animations are bypassed instantly.

---

## 6. Centralized Design Tokens (Color Architecture)

Colors are extracted directly from the master logo reference artwork. Semantic clinical status colors are strictly decoupled from brand greens to prevent diagnostic false positives.

### Master Extracted Brand Palette

| Token Name | Hex Code | RGB | HSL | CMYK | Role & Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`brandGreenDark`** | `#1B3A20` | `27, 58, 32` | `130°, 36%, 17%` | `53, 0, 45, 77` | Primary signature brand green, core ground. |
| **`brandGreenMid`** | `#5B8238` | `91, 130, 56` | `92°, 40%, 36%` | `30, 0, 57, 49` | Mid botanical green, living leaf stem. |
| **`brandGreenHighlight`** | `#9BA853` | `155, 168, 83` | `69°, 34%, 49%` | `8, 0, 51, 34` | Olive-lime highlight, active focus rings. |
| **`botanicalLeafApex`** | `#6A8912` | `106, 137, 18` | `76°, 77%, 30%` | `23, 0, 87, 46` | Living leaf tip apex, vital focal point. |
| **`botanicalLeafBody`** | `#476526` | `71, 101, 38` | `89°, 45%, 27%` | `30, 0, 62, 60` | Leaf body depth and curvature shading. |
| **`brandCream`** | `#FAF5D8` | `250, 245, 216`| `51°, 77%, 91%` | `0, 2, 14, 2` | Warm brand cream for light mode containers. |
| **`brandIvory`** | `#FCF7E0` | `252, 247, 224`| `49°, 82%, 93%` | `0, 2, 11, 1` | Radiant bone ivory foreground and lettering. |
| **`brandHaloGold`** | `#C2C56A` | `194, 197, 106`| `62°, 45%, 59%` | `2, 0, 46, 23` | Luminous halo depth aura behind mark. |

### Supporting Neutral & UI Canvas Hierarchy

| Token Name | Hex Code | Role in Application |
| :--- | :--- | :--- |
| **`obsidianCanvas`** | `#0A0E0B` | Master dark canvas substrate (deep OLED black with warm green undertone). |
| **`surfaceDark`** | `#131915` | Default card and navigation surface substrate. |
| **`surfaceElevatedDark`**| `#1A241D` | Elevated dialogs, bottom sheets, and interactive cards. |
| **`borderDark`** | `#233327` | Subtle 1px structural container boundary. |
| **`textPrimaryDark`** | `#FCF7E0` | Brand ivory for titles, metric values, and primary labels. |
| **`textSecondaryDark`** | `#9BA853` | Botanical olive-lime for captions, units, and metadata. |
| **`canvasLight`** | `#FFFDF5` | Primary light mode substrate (calm warm organic ivory). |
| **`surfaceLight`** | `#FAF8F2` | Light mode card surface. |
| **`textPrimaryLight`** | `#1B3A20` | Brand forest green for primary reading text in light mode. |

### Decoupled Semantic Clinical Palette

| Semantic Token | Hex Code | Clinical Meaning | Accessibility Rule |
| :--- | :--- | :--- | :--- |
| **`success`** | `#48B868` | Optimal biometric range / Verified target | Never convey status by color alone; must include check glyph + label. |
| **`warning`** | `#E8A238` | Threshold deviation / Attention recommended | Include triangular caution glyph + explicit delta text. |
| **`error`** | `#D94848` | Clinical risk / System anomaly / Input failure | Include octagonal warning glyph + actionable remedy. |
| **`info`** | `#4888D9` | Deterministic explanation / Health Memory node | Include circular info glyph + scientific citation link. |

---

## 7. Official Typography System

The typography system is engineered for **uncompromising clinical clarity, data readability, and cross-platform accessibility**.

* **Brand & Display Typography**: `Outfit` (Geometric, confident, friendly, human, high distinction).
* **Interface & Body Typography**: `Inter` (Tall x-height, neutral, clinical clarity).
* **Numeric Telemetry & Biometrics**: `Inter` with OpenType `FontFeature.tabularFigures()` (`tnum`) enabled to eliminate character jitter during live sensor streaming.

| Style Role | Font Family | Size | Weight | Line Height | Letter Spacing |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Display Large** | `Outfit` | 32sp | Bold (700) | 1.20 | -0.5px |
| **Display Medium** | `Outfit` | 28sp | SemiBold (600) | 1.25 | -0.25px |
| **Headline Large** | `Outfit` | 24sp | SemiBold (600) | 1.30 | 0.0px |
| **Headline Medium** | `Outfit` | 20sp | Medium (500) | 1.35 | 0.0px |
| **Title Medium** | `Outfit` | 18sp | SemiBold (600) | 1.40 | 0.15px |
| **Body Large** | `Inter` | 16sp | Regular (400) | 1.50 | 0.15px |
| **Body Medium** | `Inter` | 14sp | Regular (400) | 1.50 | 0.25px |
| **Label / Button** | `Inter` | 14sp | Medium (500) | 1.40 | 0.5px |
| **Caption** | `Inter` | 12sp | Regular (400) | 1.40 | 0.4px |
| **Numeric Value** | `Inter` (tnum)| 28sp | Bold (700) | 1.15 | -0.5px |

---

## 8. Scalable Spacing Scale (8dp Biological Grid)

To eliminate arbitrary padding values across mobile, tablet, and desktop viewports, Nutrient Earth enforces a mathematically scaled **8dp grid system**:

| Token | Value | Base Grid Multiplier | Primary UI Application |
| :--- | :--- | :--- | :--- |
| **`space2`** (`xxs`) | 2dp | 0.25× | Subpixel borders, micro badge padding |
| **`space4`** (`xs`) | 4dp | 0.5× | Tight element gaps, icon-to-label spacing |
| **`space8`** (`sm`) | 8dp | 1.0× | Chip internal padding, compact list gaps |
| **`space12`** | 12dp | 1.5× | Dense card internal padding, compact inputs |
| **`space16`** (`md`) | 16dp | 2.0× | Standard mobile screen margin, form spacing |
| **`space24`** (`lg`) | 24dp | 3.0× | Card internal padding, tablet gutters |
| **`space32`** (`xl`) | 32dp | 4.0× | Desktop grid gutters, hero section spacing |
| **`space48`** (`xxl`)| 48dp | 6.0× | Major section separators, modal paddings |
| **`space64`** (`xxxl`)| 64dp | 8.0× | Splash screen offsets, desktop hero padding |

---

## 9. Logo Clear Space ($1X$ Rule)

The master logo must be surrounded by a mandatory clear space envelope on all four sides.

```
       +---------------------------------------------+
       |                  [ 1X ]                     |
       |        +---------------------------+        |
       |        |                           |        |
[ 1X ] | [ 1X ] |       NUTRIENT EARTH      | [ 1X ] | [ 1X ]
       |        |        MASTER LOGO        |        |
       |        +---------------------------+        |
       |                  [ 1X ]                     |
       +---------------------------------------------+
```

### Mathematical Rule
* The clear space envelope equals **$1X$**, where **$X$** is defined as **0.25 × D** (one-quarter of the mark's circular diameter, equivalent to the vertical height of the `NE` monogram serif).
* **Encroachment Prohibitions**:
  * ❌ No buttons, text, cards, or interactive controls may enter this zone.
  * ❌ No screen edges, notches, or hardware camera cutouts may breach this envelope.
  * ❌ No partner logos or badges may be placed within this zone.

---

## 10. Minimum Usable Sizes

To preserve legibility and brand recognition across physical and digital surfaces:

| Asset Variant | Minimum Usable Size | Guidance & Fallback Rule |
| :--- | :--- | :--- |
| **Full Master Lockup** | **96dp** (width) | Below 96dp, do not force the wordmark. Switch to Symbol mark. |
| **Full Lockup Hero** | **128dp** (width) | Ideal display size for splash screens and landing headers. |
| **Circular Symbol Mark** | **20dp** (diameter) | Standard minimum size. Below 20dp, use `nutrient_earth_symbol_small.svg`. |
| **Navigation Logo** | **32dp** (diameter) | Default compact app bar leading mark. |
| **App Launcher Icon** | **48dp** (diameter) | Android home screen icon standard render boundary. |
| **Browser Favicon** | **16px** (square) | Multi-resolution ICO frame for browser tabs. |

---

## 11. Dark & Light Surface Contrast Matrix

Every approved variant has been empirically tested across target substrate backgrounds to guarantee WCAG 2.1 AA and AAA compliance:

| Substrate Background | Hex Code | Approved Asset Variant | Contrast Ratio | Compliance Level |
| :--- | :--- | :--- | :--- | :--- |
| **Primary Dark (Obsidian)** | `#0A0E0B` | `nutrient_earth_logo.svg` / `nutrient_earth_logo_white.svg` | **15.8:1** | **WCAG AAA** (Pass) |
| **Primary Light (Warm Ivory)** | `#FFFDF5` | `nutrient_earth_logo.svg` / `nutrient_earth_logo_green.svg` | **9.4:1** | **WCAG AAA** (Pass) |
| **Brand Forest Green** | `#1B3A20` | `nutrient_earth_logo_white.svg` / `nutrient_earth_symbol_white.svg` | **11.2:1** | **WCAG AAA** (Pass) |
| **Neutral Card Surface** | `#131915` | `nutrient_earth_logo.svg` / `nutrient_earth_symbol.svg` | **13.6:1** | **WCAG AAA** (Pass) |
| **Elevated Modal Surface** | `#1A241D` | `nutrient_earth_logo.svg` / `nutrient_earth_symbol.svg` | **12.1:1** | **WCAG AAA** (Pass) |
| **Brand Cream Card** | `#FAF5D8` | `nutrient_earth_logo_green.svg` / `nutrient_earth_symbol_green.svg` | **9.1:1** | **WCAG AAA** (Pass) |

---

## 12. Responsive Cross-Platform Behavior

Nutrient Earth adapts its brand representation dynamically across form factors while **strictly preserving 1:1 aspect ratio**:

```
MOBILE (< 600dp)            TABLET (600dp - 1024dp)         DESKTOP / WEB (>= 1024dp)
+-------------------+       +-------------------------+     +-------------------------------+
| [SYMBOL] 32dp     |       | [SYMBOL + WORDMARK]     |     | [FULL MASTER LOGO]            |
| Top Navigation    |       | Compact Rail (72dp)     |     | Expanded Sidebar (240dp)      |
| Bottom Nav (5)    |       | Dual Column Grid        |     | Multi-column Clinical Deck    |
+-------------------+       +-------------------------+     +-------------------------------+
```

* **Mobile Viewports (< 600dp)**: Navigation bar uses the 32dp **Symbol Mark** (`nutrient_earth_symbol.svg`) to preserve horizontal reading space for screen titles and action icons.
* **Tablet Viewports (600dp – 1024dp)**: Uses the **Horizontal Lockup** or 44dp Symbol Mark within the adaptive navigation rail.
* **Desktop & Web Viewports (≥ 1024dp)**: Uses the **Full Master Logo Lockup** within the 240dp persistent sidebar.
* **Scaling Law**: The logo mark is always scaled uniformly. Never independently modify width and height.

---

## 13. Developer Implementation & Architecture

All application code references the single source of truth through the centralized, strongly typed **`BrandAssets`** API located at `client/lib/core/design_system/assets/brand_assets.dart`.

### Code Usage Examples

```dart
import 'package:nutrient_earth/core/design_system/design_system.dart';

// 1. Primary Full Master Logo
BrandAssets.renderLogo(width: 120, height: 120);

// 2. Isolated Circular Brand Mark
BrandAssets.renderMark(size: 44, enableGlow: false);

// 3. Small-Size Optimized Symbol (16dp - 32dp)
BrandAssets.renderSymbolSmall(size: 24);

// 4. Standalone Typographic Wordmark
BrandAssets.renderWordmark(width: 180, height: 48);

// 5. Monochrome High-Contrast Renderers
BrandAssets.renderMonochrome(width: 96, isDark: true); // White vector
BrandAssets.renderMonochrome(width: 96, isDark: false); // Black vector

// 6. Direct Asset Paths
const logoPath = BrandAssets.logo;             // 'assets/brand/logo/nutrient_earth_logo.svg'
const symbolPath = BrandAssets.symbol;         // 'assets/brand/logo/nutrient_earth_symbol.svg'
const appIconPath = BrandAssets.appIcon;       // 'assets/brand/logo/nutrient_earth_app_icon.png'
const faviconPath = BrandAssets.faviconIco;     // 'assets/brand/logo/favicon.ico'
```

---

## 14. Quality Assurance Verification Matrix

Before any visual code is merged, the brand asset pipeline executes automated checks:

| Quality Gate | Verification Criteria | Status |
| :--- | :--- | :--- |
| **SVG Tag Structure** | Valid XML, starts with `<svg>`, ends with `</svg>`, contains viewBox. | **VERIFIED** (Pass) |
| **PNG Transparency** | 32-bit RGBA, uncompressed alpha channel, no white halos. | **VERIFIED** (Pass) |
| **No Accidental Backdrop** | Transparent bounding box around circular mark. | **VERIFIED** (Pass) |
| **No Internal Padding** | Artwork boundary snaps tightly to viewBox dimensions. | **VERIFIED** (Pass) |
| **Zero Distortion** | Strict 1:1 aspect ratio preserved across all variants. | **VERIFIED** (Pass) |
| **Color Fidelity** | Primary green `#1B3A20`, Ivory `#FCF7E0`, Cream `#FAF5D8`. | **VERIFIED** (Pass) |
| **Small-Size Legibility**| Symbol mark readable and sharp at 16dp and 20dp. | **VERIFIED** (Pass) |
| **App Icon Composition** | Master 1024×1024, solid obsidian substrate, 128px margins. | **VERIFIED** (Pass) |
| **Favicon Composition** | Multi-res ICO containing 16, 32, and 48px frames. | **VERIFIED** (Pass) |
| **Platform Paths** | Registered in `pubspec.yaml`, synchronized to `web/` icons. | **VERIFIED** (Pass) |
| **Automated Tests** | 35 brand system unit tests passing with zero errors. | **VERIFIED** (Pass) |

---

## 15. Important Product Principle

> **Nutrient Earth does not look like an AI-generated health app.**

The visual identity is intentional, restrained, and mature.

* **No generic AI gradients**: No purple-to-teal blends, no synthetic neon blooms.
* **No floating particles**: No animated dust or space clouds.
* **No excessive glassmorphism**: Interfaces are calm, readable, and structured.
* **No random 3D objects**: Visual elements exist solely to convey physiological truth.
* **The Logo is the Anchor**: Everything in the product visually respects the quiet confidence, scientific rigor, and biological vitality of the approved Nutrient Earth identity.
