# Nutrient Earth — UI/UX Design Brief

## 1. Design principle
Calm, precise, evidence-forward, respectful, and accessible. Avoid “medical certainty” visual language when the data is incomplete. A beautiful interface must not conceal uncertainty or pretend a nonfunctional tab is live.

## 2. Information hierarchy
Every health-related answer/detail page should make these visible in order:
1. Direct answer or user goal.
2. What is known from the user's supplied/permissioned data.
3. Evidence and source citations.
4. What remains unknown or uncertain.
5. Safe, practical next steps.
6. Relevant limitations and escalation guidance.
7. Source/data freshness and controls.

## 3. Core design system
Define tokens centrally: color roles (surface, text, muted text, border, focus, success, warning, danger), spacing scale, typography scale, radii, elevation, motion, breakpoints, chart palette, and evidence badge semantics. Do not hardcode per-screen colors or spacing. Use design tokens that pass WCAG contrast checks; validate actual rendered states.

## 4. Five-tab structure
- Ask: dominant input area; clear text/image/audio/document/URL entry; attachments preview and remove; answer status; evidence drawer.
- Explore: search, topic cards, evidence filters, “traditional use vs clinical evidence” distinction, professional credential badges with verification date.
- Growth: goals, plan duration, ability/equipment filters, accessible exercise cards, movement demonstration with captions and alternatives.
- Body: timeline and metrics first; 3D anatomy as a navigational layer, not a decorative diagnostic body. Always show source and observation date when an organ/region is selected.
- Store: product comparison tables, ingredient and allergen transparency, testing evidence, batch identity, price/stock timestamps, warnings, and no undisclosed paid ranking.

## 5. Evidence components
- Citation chip opens source metadata: title, publisher, publication date, access date, link, relevant passage, and source type.
- Evidence quality label must have a defined rubric and explanatory tooltip; it is not a probability that the answer is true.
- Distinguish “supported by source,” “calculated,” “inferred,” “reported by user,” “not verified,” and “unknown.”
- A generated visual carries a persistent “AI-generated illustration” label.
- A product claim must link to product-specific evidence, not a generic homepage.

## 6. Onboarding UX
Progressive, skippable, one purpose per screen. Show progress but do not punish skipping. Ask for name, age/DOB, sex-related details, height/weight, health conditions, medications, allergies, family history, and photo only when a specific feature needs them. Use a “Why we ask” explanation beside sensitive fields. Never default a sensitive field from inference. Use “prefer not to say” where appropriate.

## 7. Body/avatar UX
Default to a neutral illustrated body/avatar with configurable presentation. Offer no-photo path permanently. Never make body shape or skin tone a proxy for diagnosis, risk, race, or health. Real-photo features require separate consent, visible processing purpose, retention controls, and a deletion path. Do not show false precision or medical heatmaps from a photograph.

## 8. Real-time and stale data
Every live/connected card displays “Updated [time]” and a freshness state. Distinguish live provider data, last synced device data, manually entered data, and stale/unknown. Include refresh and source details. If a provider is offline, show last-known data without implying current state.

## 9. Notifications and reminders
Settings should show every active reminder, origin (user-created/system rule), schedule, timezone, channel, last delivery, pause/delete controls. Lock-screen notification content defaults to privacy-preserving generic text. Marketing notifications off by default.

## 10. Required states
For every screen, design: initial/empty, loading, success, partial data, stale data, permission denied, offline, provider rate-limited, failed retry, permanent failure, and accessibility mode. Long-running jobs need progress stages without fake percentage estimates.

## 11. UI acceptance
- No fabricated numbers, ratings, citations, or availability.
- Every claim of “connected,” “synced,” “verified,” or “tested” has a backend-supported state.
- Focus order and screen-reader names are tested.
- Charts expose text summaries and data tables.
- All consent and data-control screens are reachable without support intervention.
