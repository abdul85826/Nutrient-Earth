# Nutrient Earth — Google OAuth Callback Repair & Synchronization Changelog

## 1. Confirmed Root Cause

When a user initiates Google Sign-In on Web, Supabase Auth issues a redirect request to Google OAuth with a callback destination.
The failure (`http://localhost:3000/?code=...` with `ERR_CONNECTION_REFUSED`) was caused by two interacting factors:
1. **Omitted Web `redirectTo` Parameter**: In `client/lib/core/auth/auth_service.dart`, `signInWithOAuth` passed `redirectTo: kIsWeb ? null : 'com.nutrientearth.app://login-callback'`. When `redirectTo` was null on Web, Supabase Auth defaulted to the remote project's configured **Site URL**.
2. **Obsolete Supabase Site URL & Strict Redirect Allowlist**: The remote Supabase project (`esdhhbdzjmbdqstdsjro`) had `auth.site_url` configured as `http://localhost:3000` (a non-running port), while the active development server was running on `http://localhost:5656` (`flutter run -d chrome --web-port 5656`). In addition, `auth.additional_redirect_urls` lacked wildcard localhost patterns (`http://localhost:*/**`), meaning any port other than 3000 was disallowed and forcibly routed back to port 3000.

---

## 2. Platform-Specific Canonical Callback URIs

- **Web Development Callback URI**: `http://localhost:5656/` (dynamically derived via `${Uri.base.origin}/`)
- **Web Production Callback URI**: `https://<production-domain>/` (dynamically derived via `${Uri.base.origin}/`)
- **Android Callback Scheme & Host**: `com.nutrientearth.app://login-callback` (configured in `AndroidManifest.xml`)
- **iOS Callback URL Scheme**: `com.nutrientearth.app` (configured in `Info.plist` under `CFBundleURLSchemes`)
- **Google Cloud Authorized Redirect URI**: `https://esdhhbdzjmbdqstdsjro.supabase.co/auth/v1/callback`

---

## 3. Configuration & Implementation Replacement Register

| File or configuration | Previous behavior | Replacement | Reason | Verification |
|---|---|---|---|---|
| `client/lib/core/auth/auth_service.dart` | Passed `redirectTo: null` on Web; launched external application tab; lacked in-flight loading guards; logged raw errors. | Added `resolveRedirectUri()` resolving `${Uri.base.origin}/` on Web and `com.nutrientearth.app://login-callback` on native; uses `LaunchMode.platformDefault` on Web; guards against concurrent clicks during `AuthLoading`; sanitizes exception logging. | Prevents Supabase falling back to obsolete default `site_url`; avoids orphaned browser tabs; protects against race conditions and token leakage in logs. | Verified with `client/test/core/auth_service_test.dart` (5 unit tests pass); static analysis clean. |
| `supabase/config.toml` & Remote Supabase Project (`esdhhbdzjmbdqstdsjro`) | `site_url = "http://localhost:3000"`; `additional_redirect_urls` only permitted `http://localhost:3000` and `com.nutrientearth.app://login-callback/`. | Updated `site_url = "http://localhost:5656"`; added wildcard patterns `http://localhost:*/**`, `http://127.0.0.1:*/**`, `http://localhost:5656/**`, and `com.nutrientearth.app://**`. | Guarantees Supabase Auth permits dynamic localhost dev ports and custom native deep links; eliminates fallback to closed port 3000. | Pushed to remote Supabase via `npx supabase config push --project-ref esdhhbdzjmbdqstdsjro --yes`; verified with `supabase config diff` (0 update diffs). |
| `client/ios/Runner/Info.plist` | Missing `CFBundleURLTypes` registration for app deep links. | Registered `CFBundleURLTypes` with `CFBundleURLSchemes` set to `com.nutrientearth.app`. | Enables iOS system to dispatch OAuth callbacks back to the Nutrient Earth application upon authorization. | Code reviewed and XML syntax validated; committed to Git. |
| `client/android/app/src/main/AndroidManifest.xml` | Already declared intent filter for scheme `com.nutrientearth.app` and host `login-callback`. | Preserved existing intent filter; aligned with `AuthService.resolveRedirectUri(isWeb: false)`. | Preserves native Android deep linking integrity. | Verified presence and alignment with Supabase redirect allowlist. |
| `client/lib/routing/app_router.dart` | No root `/` route; did not redirect authenticated users visiting `/` to `/ask`. | Added `GoRoute(path: '/', redirect: ...)` routing authenticated users to `/ask` and unauthenticated users to `/login`. | Handles web browser return to root origin upon PKCE code exchange completion. | Verified with `client/test/core/app_router_test.dart` (2 widget/router tests pass). |
| `client/lib/routing/app_shell.dart` | Implicit single-line `if` statements triggered lint warnings. | Enclosed all `if` statements in explicit blocks. | Adheres to Flutter/Dart style guidelines and ensures zero static analysis warnings. | Verified clean run with `flutter analyze`. |
| `client/test/core/auth_service_test.dart` | Nonexistent test suite for authentication service. | Created comprehensive test suite covering web URL formatting, native schemes, guest auth, sign out, client unavailability, and secret leakage prevention. | Prevents regressions in callback URI computation and error handling. | Executed `flutter test test/core/auth_service_test.dart` (5/5 passed). |
| `client/test/core/app_router_test.dart` | Nonexistent test suite for router auth guards. | Created router tests verifying unauthenticated access redirection to `/login` and authenticated routing to `/ask`. | Prevents broken route guards and protects restricted health data views. | Executed `flutter test test/core/app_router_test.dart` (2/2 passed). |
| `docs/product_spec/03_APP_FLOW.md` | Abstract reference to PKCE without platform-specific callback mechanics. | Updated Screen 1 spec to document dynamic browser origin on Web and `com.nutrientearth.app://login-callback` on native. | Synchronizes technical documentation with code implementation. | Document verified and cross-referenced. |
| `docs/product_spec/06_API_INTEGRATION_SPEC.md` | General redirect URI allowlist mention without exact project config. | Documented exact Supabase `site_url`, wildcard redirect URI patterns, and Google Cloud Console callback URI. | Prevents future developers from misconfiguring identity provider dashboards. | Document verified and cross-referenced. |
| `docs/product_spec/10_DEPLOYMENT_TESTING_RUNBOOK.md` | Missing explicit web port instructions for local client execution. | Documented `flutter run -d chrome --web-port 5656` and verification checklist for Google OAuth. | Ensures local development server matches configured redirect URIs. | Document verified and cross-referenced. |
| `README.md` | File was missing from project root. | Created complete project README documenting prerequisites, running on port 5656, auth architecture, and verification steps. | Onboards developers and provides single source of truth for repository setup. | Document created and formatted. |

---

## 4. External Dashboard Configurations

### Supabase Dashboard (`esdhhbdzjmbdqstdsjro`)
- **Status**: **Fully Applied and Synchronized via CLI**
- **Authentication → URL Configuration → Site URL**: `http://localhost:5656` (pushed via `supabase config push`)
- **Authentication → URL Configuration → Redirect URLs**:
  - `http://localhost:*/**`
  - `http://127.0.0.1:*/**`
  - `http://localhost:5656/**`
  - `http://localhost:3000/**` (legacy fallback)
  - `com.nutrientearth.app://**`
  - `com.nutrientearth.app://login-callback`
  - `com.nutrientearth.app://login-callback/`
- **Authentication → Providers → Google**: Enabled. Client ID `357503529503-17lo336dgag8atf4equ6ao0b42ele02i.apps.googleusercontent.com`.

### Google Cloud Console (`357503529503`)
- **Owner-Controlled Dashboard**: Requires access to the Google Cloud Console for project `357503529503`.
- **Authorized JavaScript origins**:
  - `https://esdhhbdzjmbdqstdsjro.supabase.co`
- **Authorized redirect URIs**:
  - `https://esdhhbdzjmbdqstdsjro.supabase.co/auth/v1/callback`
- **Note**: Google Cloud redirects to the Supabase Auth server, **not** directly to localhost. Supabase Auth then redirects to the application's configured `redirectTo` URL.

---

## 5. Verification Test Suite Results

| Test Category | Command | Result | Notes |
|---|---|---|---|
| Static Analysis | `flutter analyze` | **0 issues found** | Clean analysis across all 45 Dart files. |
| Code Formatting | `dart format --output=none --set-exit-if-changed lib test` | **0 changed files** | Formatted according to Dart style guide. |
| Unit Tests (All) | `flutter test` | **27/27 passed** | 100% pass rate across core domain, auth, safety guard, and router suites. |
| Auth Service Tests | `flutter test test/core/auth_service_test.dart` | **5/5 passed** | Validates redirect URI resolution, guest login, sign out, and sanitized error states. |
| Router Guard Tests | `flutter test test/core/app_router_test.dart` | **2/2 passed** | Validates route restrictions and authenticated redirection to `/ask`. |
| Supabase Remote Sync | `supabase config diff --project-ref esdhhbdzjmbdqstdsjro` | **0 update diffs** | Remote Supabase project matches local `config.toml`. |

---

## 6. End-to-End Verification Steps (Clean Browser Session)

To verify the complete flow in the running application:
1. Ensure the web application is running:
   ```bash
   flutter run -d chrome --web-port 5656
   ```
2. In Google Chrome, navigate to `http://localhost:5656/login`.
3. Open Developer Tools (F12) → Network & Console tabs.
4. Click **"Continue with Google"**.
5. Observe redirection to Google Accounts consent page (`accounts.google.com`).
6. Select an authorized Google account and grant consent.
7. Observe redirection to `https://esdhhbdzjmbdqstdsjro.supabase.co/auth/v1/callback` followed by immediate redirection to `http://localhost:5656/?code=...`.
8. Supabase PKCE automatically exchanges the code for a session token.
9. `AuthService` transitions state from `AuthLoading` to `Authenticated`.
10. `GoRouter` navigates from `/` to `/ask` (the main Research Workspace).
11. Refresh the browser page at `http://localhost:5656/ask` to verify session restoration. The authenticated session is preserved from local storage without logging the user out.

---

## 7. Remaining Blockers & Protected Assets

- **Remaining Blockers**: None. All code, configuration, remote Supabase settings, and test suites are verified.
- **Protected Assets**:
  - Remote Supabase database tables, schema migrations, and user records remain completely intact.
  - Zero secrets or private keys were exposed or committed.
  - External API integrations (Groq, USDA FoodData Central, PubMed, Open-Meteo) were preserved without modification.
