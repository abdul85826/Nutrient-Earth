# Nutrient Earth — Antigravity Document Pack

This folder contains ten source-of-truth planning documents for Antigravity. Read `01_PRD.md` first, then `02_TRD.md`, then the remaining documents in numerical order. `README_START_HERE.md` is the execution instruction sheet, not a replacement for the ten requested documents.

## Critical instruction to Antigravity
**Do not start by rebuilding the app. Audit the current repository first. Preserve working code.**

### Required first response
Return:
1. Repository and architecture inventory.
2. Existing functionality that works and how it was verified.
3. Existing authentication, database, migrations, storage, deployment, Groq integration, weather provider, and all other API references (variable names only, never secret values).
4. Security and data-loss risks.
5. Dependencies/license status.
6. Gap matrix against these ten documents.
7. Proposed smallest safe implementation sequence.
8. Files you intend to change and why.
9. Tests that will prove each change works.
10. Explicit blockers/assumptions requiring owner approval.

Do not edit files until this audit is delivered and reviewed. If the user has explicitly instructed the agent to proceed after audit, create a branch/checkpoint and implement the smallest complete vertical slice.

## Order of authority
1. Existing verified repository behavior is preserved unless demonstrably unsafe or owner-approved for change.
2. These documents define intended product and acceptance criteria.
3. Provider documentation and current legal/regulatory sources determine actual capabilities and constraints.
4. If documents conflict, stop and report the conflict; do not silently choose.

## Zero-paid-crawl rule
Do not invoke paid crawling/search APIs or trial credits as the default. No automatic billing, upgrade, or paid fallback. Use official APIs and properly licensed public data first; evaluate self-hosted open-source crawling only after license, SSRF, robots, site terms, and maintenance review. A “free tier” is not a promise of permanent free access.

## “Free” infrastructure reality
Open-source software can avoid license fees but still costs compute, storage, bandwidth, operations, backups, email delivery, and security maintenance. Do not promise a production service is cost-free. Before adopting any managed service, show recurring costs, usage caps, pause behavior, data processing terms, and exit/migration plan. No card attachment or paid resource creation without explicit approval.

## Research sources reviewed (re-verify before production)
- Apple HealthKit authorization: https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data
- Apple HealthKit privacy: https://developer.apple.com/documentation/healthkit/protecting-user-privacy
- Android Health Connect data types/permissions: https://developer.android.com/health-and-fitness/health-connect/data-types
- Supabase self-hosting responsibilities: https://supabase.com/docs/guides/self-hosting
- Supabase managed billing/quotas: https://supabase.com/docs/guides/platform/billing-on-supabase
- Brave Search API: https://brave.com/search/api/
- Exa pricing: https://exa.ai/pricing
- Firecrawl: https://www.firecrawl.dev/
- Scrapy: https://github.com/scrapy/scrapy
- Crawl4AI: https://github.com/unclecode/crawl4ai
- Playwright: https://github.com/microsoft/playwright
- Valkey: https://valkey.io/
- Vercel docs: https://vercel.com/docs
- USDA FoodData Central: https://fdc.nal.usda.gov/api-guide.html
- Open Food Facts: https://world.openfoodfacts.org/data
- Open-Meteo terms: https://open-meteo.com/en/terms
- FSSAI: https://www.fssai.gov.in/
- India DPDP Act/Rules: verify current official Gazette/MeitY material and commencement dates before launch.
- GDPR: verify official text and local counsel where applicable.

These sources establish implementation constraints, not a legal opinion. Pricing, quotas, licenses, SDK behavior, terms, and regulations can change; verify against official current documentation before enabling a provider or launching a regulated feature.

## Implementation gate
The first release should prove a real end-to-end path, not show five empty tabs: secure auth → consent-aware profile → Ask → safe ingestion/retrieval → claim verification → cited answer → conversation history → data export/delete → usage metering → quota alert → deploy and smoke-test. Additional tabs and device integrations ship only when their source, safety, privacy, and operational gates pass.
