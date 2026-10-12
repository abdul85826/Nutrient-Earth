# Nutrient Earth — Security, Access Control, and Privacy

## 1. Threat model
Assume malicious users, compromised accounts, prompt injection, hostile files/URLs, SSRF, credential theft, supply-chain compromise, abusive scraping, quota exhaustion, insider misuse, and accidental cross-user data leakage. Health data, identity data, photos, reports, family history, and device records are sensitive.

## 2. Identity and session controls
- Use a maintained OIDC/OAuth provider; Authorization Code + PKCE for public/native clients.
- Validate issuer, audience, signature, expiry, state, nonce, redirect URI, and token scopes.
- MFA/passkeys where available; secure recovery; rate-limit login, OTP, magic-link, password-reset, and account-link attempts.
- Rotate/revoke sessions on password/security changes, logout, account deletion, and suspected compromise.
- Native tokens use platform secure storage; web uses secure, HttpOnly, SameSite cookies where architecture supports it.
- Never place client secrets in Flutter/web bundles or Antigravity-generated code.

## 3. Authorization
Authentication is not authorization. Enforce user ownership on every endpoint and object-storage operation. Derive identity from the verified session, not request body. Enforce least privilege in service roles, database roles, workers, admin tools, MCPs, and API keys. Admin access is time-bounded, reason-coded, logged, and reviewed.

## 4. Database and storage
- RLS policies tested for every user-owned table and nested query.
- Service-role keys remain server-side and never reach clients.
- Private buckets only; short-lived signed URLs; verify ownership before signing.
- File validation by actual content/MIME/signature, size caps, malware scanning, parser sandboxing, decompression limits, and retention cleanup.
- Encryption in transit and at rest; secrets in a secret manager; key rotation and backup encryption.
- Avoid raw health data in application logs, analytics, traces, error messages, prompts, or alert emails.

## 5. URL/crawler security
- SSRF defense at fetch and redirect stages, with DNS resolution checks and egress restrictions.
- Block localhost, private/loopback/link-local/multicast/reserved IPs and cloud metadata endpoints; revalidate every redirect and DNS resolution.
- Restrict schemes to HTTP/HTTPS; disallow credentials in URLs; cap redirects, response size, content types, duration, and decompression ratio.
- Respect robots directives, terms, copyright, and rate limits. No stealth, CAPTCHA bypass, paywall circumvention, or authentication bypass.
- Parse in sandboxed worker with CPU/memory/time budgets. Treat crawled content as untrusted data, never executable instructions.

## 6. AI security and prompt injection
- Retrieved documents, OCR, PDFs, URLs, comments, images, and tool output are untrusted data.
- Never allow content to override system policy, tool permissions, safety rules, or developer instructions.
- Separate data from instructions; tools use explicit schemas and allowlists.
- Tool calls are server-side, authorized per user/request, budgeted, logged with redaction, and denied by default.
- Never let model output select arbitrary network destinations, execute shell commands, read arbitrary files, or reveal secrets.
- Validate all model output against typed schemas; escape output for its destination; use output encoding against HTML/Markdown injection.
- Do not store hidden chain-of-thought. Store concise evidence, decisions, and verification metadata only.

## 7. Health and privacy controls
- Purpose limitation and data minimization; collect sensitive fields just-in-time.
- Granular consent for each integration/data type; revocation blocks future collection and processing.
- No health-data sale, ad profiling, or training use by default.
- Explicitly disclose third-party processors, data region, retention, and data sent to each AI provider.
- Separate production user data from developer testing; use synthetic or properly de-identified test fixtures.
- Avoid sending sensitive data to public search providers; minimize or redact queries where feasible.
- Age-appropriate onboarding and jurisdiction-specific consent requirements must be legally reviewed before launch.

## 8. Data rights
Implement authenticated data access/export, correction, consent withdrawal, account deletion, and deletion status. Export includes manifest, version, checksums, and supported machine-readable formats. Re-authenticate for sensitive export. Use short-lived download links. Deletion propagates to primary storage, object storage, search/vector indexes, caches, queues, and processors; backups follow documented retention/legal policy. Do not claim instant total deletion if backup lifecycle prevents it.

## 9. MCP and developer tools
MCP is a developer integration surface, not an automatic production runtime dependency. Install only necessary servers. Use read-only and project-scoped permissions; isolate credentials; never connect unrestricted production DB writes to an agent. Review server source, package provenance, pinned versions, tool schemas, outbound network behavior, and license. No tool receives all API keys. Prefer separate least-privilege credentials for each provider and environment. Log and review sensitive tool actions.

## 10. Rate limits and abuse
Per-user, per-IP, per-device, per-endpoint and per-provider budgets; upload caps; concurrency limits; account enumeration protection; abuse detection; CAPTCHA only where appropriate and privacy reviewed. Enforce cost ceilings and kill switches. Avoid exposing whether a user’s email or account exists.

## 11. Security verification gate
Before public release: threat model review; dependency/SBOM scan; static analysis; secret scan; auth/session tests; RLS cross-tenant tests; storage URL tests; SSRF suite; file-parser fuzz tests; prompt injection tests; rate-limit tests; backup restore; incident runbook; privacy/data deletion tests; pen-test plan appropriate to exposure and data sensitivity.
