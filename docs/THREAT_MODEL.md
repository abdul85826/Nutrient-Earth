# Nutrient Earth — Threat Model & Attack Surface Analysis

**Methodology:** STRIDE & PASTA (Process for Attack Simulation and Threat Analysis)  
**Date:** 2026-10-26  
**Security Level:** Production Healthcare & Nutritional Biochemistry Application  

---

## 1. Asset Classification & Sensitivity

| Asset | Sensitivity | Impact of Compromise | Primary Protection |
| :--- | :--- | :--- | :--- |
| **User Biometric Records & Health Lab Reports** | **HIGH (Confidential)** | Severe privacy violation, regulatory penalties (GDPR/CCPA/HIPAA) | Supabase RLS, AES-256 Storage, TLS 1.3 |
| **Personal Daily Routines & Checklists** | **MEDIUM (Private)** | User surveillance, behavioral profiling | User-scoped queries (`auth.uid()`) |
| **AI Model API Keys (Gemini, Groq)** | **HIGH (Confidential)** | Financial theft, API quota exhaustion, unmetered abuse | Server-side secrets vault (Supabase Secrets) |
| **Scientific Evidence Base** | **LOW (Public)** | Disinformation if tampered, loss of trust | Static repository, read-only RLS, signature checks |
| **User Authentication Tokens (JWTs)** | **CRITICAL (Confidential)**| Account takeover, unauthorized profile modification | PKCE OAuth, secure device keychain storage |

---

## 2. Threat Actor Profiles

1. **Unauthenticated External Attacker (Script Kiddie / Botnet)**
   - **Capability:** Automated scanning, vulnerability fuzzing, dictionary attacks, URL scraping.
   - **Goal:** Extract API keys from client bundles, exploit SSRF endpoints to probe cloud metadata, perform DDoS.
2. **Authenticated Malicious Tenant (Cross-User Intruder)**
   - **Capability:** Valid user credentials, customized API requests, modified client payload.
   - **Goal:** Read or modify other users' health reports, tamper with telemetry, elevate privileges.
3. **Prompt Injection & Adversarial Prompt Crafter**
   - **Capability:** Inputs engineered prompts into research search bars, uploads adversarial OCR images.
   - **Goal:** Bypass scientific disclaimers, force the system to emit prescription advice or extract internal system prompts.
4. **Network Man-in-the-Middle (MitM)**
   - **Capability:** Intercepting traffic on public Wi-Fi networks.
   - **Goal:** Capture authentication tokens, modify telemetry data in transit.

---

## 3. STRIDE Threat Assessment & Mitigations

### 1. Spoofing Identity
* **Threat:** Attacker attempts to forge user identity or session tokens to view medical records.
* **Mitigation:** Supabase Auth issues cryptographically signed HS256/RS256 JWTs. Client communicates over TLS 1.3. PKCE prevents code injection during OAuth handshakes.

### 2. Tampering with Data
* **Threat:** Malicious client attempts to modify another user's health profile or alter evidence scores.
* **Mitigation:** PostgreSQL Row Level Security enforces `auth.uid() = user_id` on all write operations. Content tables (`learn_content`, `exercise_routines`) are strictly read-only for client roles.

### 3. Repudiation
* **Threat:** User claims they did not initiate an inquiry or account deletion.
* **Mitigation:** Timestamps, transaction UUIDs, and immutable audit logs within Supabase PostgreSQL.

### 4. Information Disclosure
* **Threat:**
  - Client binary exposes `.env` containing LLM keys.
  - SSRF endpoint exposes internal cloud metadata (`169.254.169.254`).
  - Error messages expose database stack traces or SQL fragments.
* **Mitigation:**
  - Remove `.env` from Flutter asset bundle.
  - Enforce strict hostname whitelisting and IP filtering on user-supplied URLs.
  - Client exception handlers display sanitized error messages (`Research error: Request failed`).

### 5. Denial of Service (DoS)
* **Threat:**
  - Repeated expensive LLM synthesis inquiries exhaust API quotas or freeze the application.
  - Oversized payloads (>50MB) submitted to image analysis endpoints.
* **Mitigation:**
  - Max query length capped at 500 characters.
  - Storage bucket enforces 15MB file size limit and strict MIME validation (`application/pdf`, `image/png`, `image/jpeg`).
  - Client-side debounce and duplicate submission guards.

### 6. Elevation of Privilege
* **Threat:** Attacker modifies user profile to gain admin access or write permissions on store products.
* **Mitigation:** Roles are not stored in client-accessible user metadata. Schema permissions for `public.store_products` and `public.learn_content` restrict `INSERT/UPDATE/DELETE` exclusively to `service_role`.

---

## 4. Attack Surface Map

```
[ User Input Vector: Search Bar & URL Input ]
  ├─ Threat: Prompt Injection, XSS, SSRF
  └─ Defense: SecurityUrlValidator + QuerySanitizer (max 500 chars)

[ User Input Vector: Document / Image Upload ]
  ├─ Threat: Malicious executable upload, zip bomb, buffer overflow
  └─ Defense: Supabase Storage MIME validation + 15MB limit + Isolated S3 prefix

[ Network Vector: Supabase REST & GraphQL Gateway ]
  ├─ Threat: Broken Object Level Authorization (BOLA), IDOR
  └─ Defense: PostgreSQL RLS enforced per table on auth.uid()

[ Compilation & Distribution Vector: Client Binary / Web ]
  ├─ Threat: Hardcoded credential harvesting
  └─ Defense: Zero secrets in assets, removal of .env from pubspec.yaml
```
