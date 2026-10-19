---
name: framer-motion-21stdev
description: >-
  Interactive animations and modern component design using Framer Motion and 21st.dev /
  Aceternity component patterns. Use for layout animations, scroll-driven effects,
  spring physics, gesture controls, dynamic hero sections, and copy-paste modern UI components.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# Framer Motion & 21st.dev Component Engineering

This skill provides patterns for building animated, physics-driven UI components inspired by [21st.dev](https://21st.dev) and modern React/Framer Motion component libraries.

---

## 1. Core Framer Motion Patterns

### Spring Physics Defaults
```tsx
export const springTransition = {
  type: "spring",
  stiffness: 400,
  damping: 30,
};

export const gentleSpring = {
  type: "spring",
  stiffness: 100,
  damping: 15,
};
```

### Layout Animation (Shared Layouts)
Use `layout` and `layoutId` for smooth tab switches, indicator sliders, and modal expansions:
```tsx
import { motion, AnimatePresence } from "framer-motion";

export function SegmentedControl({ tabs, selected, onSelect }) {
  return (
    <div className="flex gap-1 p-1 bg-neutral-900/60 rounded-xl border border-neutral-800 backdrop-blur-md">
      {tabs.map((tab) => (
        <button
          key={tab.id}
          onClick={() => onSelect(tab.id)}
          className="relative px-4 py-2 text-sm font-medium transition-colors"
        >
          {selected === tab.id && (
            <motion.div
              layoutId="active-pill"
              className="absolute inset-0 bg-neutral-800 rounded-lg shadow-sm"
              transition={springTransition}
            />
          )}
          <span className="relative z-10">{tab.label}</span>
        </button>
      ))}
    </div>
  );
}
```

---

## 2. 21st.dev Inspired Component Recipes

### Background Gradient & Spotlight
A spotlight effect tracking mouse movements across the card:
```tsx
import { motion, useMotionTemplate, useMotionValue } from "framer-motion";

export function SpotlightCard({ children }) {
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);

  function handleMouseMove({ currentTarget, clientX, clientY }) {
    const { left, top } = currentTarget.getBoundingClientRect();
    mouseX.set(clientX - left);
    mouseY.set(clientY - top);
  }

  return (
    <div
      onMouseMove={handleMouseMove}
      className="group relative rounded-2xl border border-white/10 bg-neutral-950 p-8 overflow-hidden"
    >
      <motion.div
        className="pointer-events-none absolute -inset-px rounded-2xl opacity-0 transition duration-300 group-hover:opacity-100"
        style={{
          background: useMotionTemplate`
            radial-gradient(
              450px circle at ${mouseX}px ${mouseY}px,
              rgba(56, 189, 248, 0.15),
              transparent 80%
            )
          `,
        }}
      />
      <div className="relative z-10">{children}</div>
    </div>
  );
}
```

### Staggered Reveal on Scroll
```tsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0.1,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 16 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.5, ease: [0.16, 1, 0.3, 1] },
  },
};
```

---

## 3. Best Practices
1. **Never animate layout properties directly** (`width`, `height`, `top`, `left`). Instead, animate `transform` (`x`, `y`, `scale`) and `opacity` to avoid layout thrashing.
2. **Always include `exit` states inside `<AnimatePresence>`** to avoid abrupt unmounts.
3. **Guard with `useReducedMotion()`** to disable heavy transformations when the user requests minimal motion.
