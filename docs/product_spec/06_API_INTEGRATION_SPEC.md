# Nutrient Earth — API and Integration Specifications

## 1. Provider policy
“Free tier” is not the same as permanently free. For this phase, prefer self-hosted open-source components with licenses compatible with commercial use, public datasets with verified licenses, and existing user-owned API credentials. Do not silently activate paid trials, attach a card, or rely on quota that expires. If an external API has a free quota but can later charge, it is not approved as an unbounded production dependency.

Maintain an integration registry with: provider, purpose, official docs, license/terms, pricing model, rate limits, authentication, scopes, data sent, data retained, region, fallback, failure behavior, key owner, last verified date, and kill switch.

## 2. Existing providers
- **Groq API:** already reported as available by the project owner. Verify actual model IDs, account tier, rate limits, terms, privacy/data retention, spend controls, and key ownership in the provider dashboard. Do not assume the key is valid or that every model is free. Backend only; no client key.
- **Weather API:** provider unspecified. Audit existing code/config and identify exact vendor, terms, quota, attribution, geographic coverage, and cache policy before replacing it. Weather should not be a critical health dependency.
- Other API keys: discover from secret-manager/env names and code references without printing values. Never ask user to paste secret values into chat or Antigravity prompts.

## 3. Search and crawling — zero-paid-call policy
For the initial phase, disable paid crawling/search APIs such as Brave paid API, Exa paid usage, and Firecrawl paid usage unless the owner explicitly approves a budget. A provider's free monthly allowance is not the same as permanently free; do not depend on it for core product uptime.

Preferred approach:
1. Direct official APIs and open datasets first.
2. Self-hosted open-source retrieval/crawling only for permitted public pages.
3. Use a self-hosted crawler/parser such as Scrapy or another reviewed open-source project only after verifying current license, maintenance status, robots/terms compliance, SSRF defenses, and security updates.
4. For JavaScript-heavy pages, use Playwright for permitted browser automation/testing, not as a bypass for anti-bot controls.
5. Do not use CAPTCHA bypass, paywall circumvention, credential/session reuse, stealth evasion, or unauthorized crawling.
6. Enforce host allowlists where feasible, domain-specific concurrency/rate limits, crawl-delay/robots policy, bounded depth/pages/bytes, deduplication, content hashes, and a global kill switch.
7. Never crawl private URLs, localhost, loopback, private IP ranges, link-local, cloud metadata endpoints, or redirect chains that resolve to them.

## 4. Search/crawl provider registry (verify before enabling)
- **Brave Search API/MCP:** paid/quota-based API, not a permanent-free guarantee. Keep disabled under current zero-paid-call rule. Official: https://brave.com/search/api/
- **Exa:** pricing/credits can change; disable unless explicitly budget-approved. Official: https://exa.ai/pricing
- **Firecrawl:** credits/plan limits change; disable paid calls. Official: https://www.firecrawl.dev/
- **Scrapy:** open-source crawler; verify license/version: https://github.com/scrapy/scrapy
- **Crawl4AI:** open-source extraction/crawling candidate; verify license/version/security before adoption: https://github.com/unclecode/crawl4ai
- **Playwright:** open-source browser automation/testing candidate; not a crawler quota substitute and not a permission bypass: https://github.com/microsoft/playwright
- **Context7:** docs retrieval candidate; verify its current plan/terms and whether local docs are sufficient: https://context7.com/
No provider is considered enabled because it appears in this document.

## 5. Other data/API candidates
- **USDA FoodData Central:** nutrition dataset/API; verify key requirements, usage terms, attribution, and geographic relevance: https://fdc.nal.usda.gov/api-guide.html
- **Open Food Facts:** community-contributed product data; treat as unverified input, verify licensing and product-label accuracy, and preserve attribution: https://world.openfoodfacts.org/data
- **Open-Meteo:** verify license/commercial-use terms and attribution before commercial deployment: https://open-meteo.com/en/terms
- **Google Health Connect:** Android health data platform, not a general cloud API; requires app permissions and Play Console declarations where applicable: https://developer.android.com/health-and-fitness/health-connect
- **Apple HealthKit:** iOS/watchOS framework with per-type authorization and app entitlements: https://developer.apple.com/documentation/healthkit
- **FHIR import:** user-initiated file import is an initial option; provider/EHR integrations require separate vendor, consent, and legal review.
- **Email:** choose an SMTP/self-hosted or provider path only after deliverability, abuse prevention, data processing terms, domain setup, and quotas are reviewed. No “sent” state without delivery provider confirmation.
- **Error tracking:** Sentry or self-hosted alternative only after verifying plan quotas, PII scrubbing, data residency, retention, and whether health payloads are excluded.
- **Vercel:** optional frontend deployment; verify current plan/runtime/build limits and do not assume it provides all backend/worker needs: https://vercel.com/docs
- **Supabase:** if already used, audit current plan and RLS; self-hosting transfers ops/backup/security responsibility to the team: https://supabase.com/docs/guides/self-hosting
- **Redis:** review exact version and license. For a permissive open-source Redis-compatible option, evaluate Valkey: https://valkey.io/ and verify its current license/release terms. Do not blindly add Redis because it is familiar.
- **OAuth/OIDC:** use a maintained identity provider and standards-compliant flow; native/public clients use Authorization Code + PKCE. Do not implement OAuth protocol manually.

## 6. API adapter contract
Every provider adapter must expose:
- typed request/response schemas;
- timeout and cancellation;
- provider-specific rate-limit handling and `Retry-After`;
- bounded retries with jitter for idempotent operations only;
- normalized errors (`AUTH_FAILED`, `RATE_LIMITED`, `QUOTA_EXHAUSTED`, `TIMEOUT`, `UNAVAILABLE`, `INVALID_RESPONSE`, `POLICY_BLOCKED`);
- usage event and request correlation ID;
- data classification and redaction;
- health/readiness signal where meaningful;
- per-provider concurrency/budget circuit breaker;
- contract tests using sanitized fixtures and live smoke tests only when explicitly enabled.

## 7. Credit and quota monitoring
Record every billable/non-billable request where possible. Normalize provider usage as requests, tokens, credits, estimated spend, remaining quota, reset time, status code, and source of measurement (`provider_api`, response_header, estimated_counter, manual_check). Never present an estimate as provider-confirmed balance.

Thresholds: configurable 50%, 75%, 90%, 100% of budget/known quota. De-duplicate per provider, quota period, threshold, and account. At 90% warn and throttle noncritical work; at 100% disable that provider by default unless a project owner explicitly configures an emergency budget. The system must not automatically purchase credits or upgrade plans.

Email/dashboard alerts must be independent of the AI/search provider that is exhausting. Do not include prompts, health documents, API keys, or full request bodies in alert emails. Include provider, threshold, period, evidence source, last observed usage, confidence, and next action. Monitor 429s and `Retry-After`; alert when provider telemetry is unavailable.

## 8. Email and OAuth security
OAuth redirect URIs exact-match and wildcard allowlist (`http://localhost:*/**`, `http://localhost:5656/**`, `com.nutrientearth.app://**`); state and nonce validation; PKCE; least scopes; token rotation/revocation; CSRF protections; platform-secure storage for native tokens; no tokens or authorization codes in URLs/logs/exception telemetry.
- Supabase Auth Site URL: `http://localhost:5656` in local development; production domain in staging/production.
- Google Cloud OAuth Web Client: Authorized Redirect URI points to `https://<supabase-project-ref>.supabase.co/auth/v1/callback`.
Email verification and recovery links must be single-use, time-bound, and rate-limited. Account linking requires proof of control of both identities.

## 9. Live-provider policy
A screen may say “live” only if data source timestamp, provider response, and freshness threshold are available. Every provider has an explicit disabled/degraded state. No fake fallback data, fake weather, invented prices, synthetic stock, or fabricated availability.
