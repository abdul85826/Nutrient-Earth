---
name: open-design
description: >-
  Local-first collaborative AI design agent workspace driven by DESIGN.md contracts.
  Use when generating web prototypes, UI design systems, mobile screens, presentations,
  motion graphics (HyperFrames), and running open-design skills and templates.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# Open Design — Local-First AI Design Agent Engine

Open Design (`nexu-io/open-design`) is a local-first collaborative design workspace and agent toolchain. It allows coding agents to function as design engines, translating `DESIGN.md` design system rules into interactive web components, mobile screens, and motion graphics.

---

## 1. Repository & Installation Directory

- **Repository Path**: `C:\Users\admin\tools\open-design`
- **Core Package Runtime**: Node.js v24+, pnpm
- **Skills Directory**: `C:\Users\admin\tools\open-design\skills\`
- **Design Systems**: `C:\Users\admin\tools\open-design\design-systems\`

---

## 2. Core Capabilities & Skills

Open Design bundles 50+ specialized design skills:
- **`ui-ux-pro-max` / `platform-design`**: Modern dark mode, glassmorphism, responsive token hierarchies.
- **`motion-design` / `motion-lab`**: Micro-interactions, spring physics, scroll reveals.
- **`video-hyperframes`**: Generative video and canvas motion frame generation.
- **`shadcn-ui` / `components`**: Accessible, production-ready component primitives.
- **`pptx` / `nanobanana-ppt`**: Automated presentation generation.
- **`reference-design-contract`**: Strict token adherence via `DESIGN.md`.

---

## 3. Workflow & Usage

### Driving Design via `DESIGN.md`
Every project using Open Design defines tokens in `DESIGN.md`:
```markdown
# Design System Specification
- **Color Palette**: Dark slate background (#0a0f1d), Emerald accents (#10b981), Soft white text (#f8fafc).
- **Typography**: Inter (UI), Outfit (Headings).
- **Border Radius**: 12px for cards, 9999px for pills.
- **Shadows**: Multi-layer ambient drop shadows with subtle borders.
```

### Running Open Design Commands
Navigate to `C:\Users\admin\tools\open-design`:
```bash
# Start local tools development server
pnpm tools-dev

# Execute a design skill artifact generator
pnpm exec od skill run <skill-name> --output ./artifact.html
```

### Agent MCP Integration
Open Design connects seamlessly to Hermes, Claude, and IDE agents:
- MCP server bridge connects local agent runtimes directly to design canvas.
- Real-time preview rendering via local web server.
