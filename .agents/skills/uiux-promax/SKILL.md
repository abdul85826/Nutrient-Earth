---
name: uiux-promax
description: >-
  Elite UI/UX and visual design engineering skill. Use when creating, styling,
  or polishing web/mobile interfaces, landing pages, design systems, micro-interactions,
  dark modes, glassmorphism, responsive layouts, TailwindCSS, and modern typography.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# UI/UX Pro Max — Design & Frontend Engineering

This skill guides the design and implementation of production-grade, aesthetically stunning user interfaces across web and mobile.

---

## 1. Visual Excellence & Aesthetics

- **Color Palette & Contrast**:
  - Never use raw default colors (`#ff0000`, `#00ff00`). Use curated, harmonious palettes (e.g., Tailwind Zinc/Slate neutrals paired with vibrant accents like Indigo `#6366f1`, Emerald `#10b981`, or Amber `#f59e0b`).
  - Maintain WCAG AAA/AA accessible contrast ratios (minimum 4.5:1 for body text, 3:1 for large headings).
  - Implement dynamic dark and light mode themes with CSS variables / semantic design tokens.

- **Depth & Hierarchy**:
  - **Glassmorphism**: Subtle translucent surfaces (`background: rgba(255, 255, 255, 0.05)`, `backdrop-filter: blur(16px)`, `border: 1px solid rgba(255, 255, 255, 0.1)`).
  - **Layered Shadows**: Soft multi-stop shadows rather than harsh single-offset drops (`box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.1)`).
  - **Visual Hierarchy**: Clear typographic scale (Hero > H1 > H2 > Subtitle > Body > Caption). Use modern fonts like Inter, Outfit, Plus Jakarta Sans, or Geist.

---

## 2. Micro-Interactions & Motion Principles

- **State Transitions**: Every button, card, and input must have clear states (`hover`, `active`, `focus-visible`, `disabled`, `loading`).
- **Spring Physics**: Prefer smooth spring/cubic-bezier curves (`cubic-bezier(0.16, 1, 0.3, 1)`) over linear transitions.
- **Haptic/Visual Feedback**: Add pulse rings, scale effects (`active:scale-95`), or subtle border glow upon user interaction.
- **Micro-Animations**: Skeleton loaders during network calls; fade-and-slide enters for dynamic content.

---

## 3. Responsive Layout Guidelines

- **Mobile First**: Design for small screens (320px–390px) first, scaling upward gracefully to tablet (768px) and desktop (1280px+).
- **Safe Area Insets**: Account for notches and navigation bars with `env(safe-area-inset-bottom)` and `env(safe-area-inset-top)`.
- **Touch Targets**: Minimum interactive tap target of 44x44px for touch interfaces.

---

## 4. Design System Tokens Architecture

Define structured design tokens at the root level:

```css
:root {
  --color-bg-primary: #0a0c10;
  --color-bg-surface: #141820;
  --color-border-subtle: rgba(255, 255, 255, 0.08);
  --color-accent-primary: #38bdf8;
  --color-text-primary: #f8fafc;
  --color-text-secondary: #94a3b8;
  --radius-sm: 6px;
  --radius-md: 12px;
  --radius-lg: 20px;
  --transition-smooth: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
}
```

---

## 5. Verification Checklist

1. [ ] Responsive across 375px, 768px, and 1440px viewports without horizontal overflow.
2. [ ] Keyboard navigation: All interactive elements are reachable with Tab and display clear focus rings.
3. [ ] Color contrast passes WCAG AA standards.
4. [ ] Reduced motion: Honor `prefers-reduced-motion` media queries.
