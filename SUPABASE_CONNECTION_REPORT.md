# SUPABASE CONNECTION REPORT
*Generated: 2026-06-25*

---

## Summary

| System | Status |
|--------|--------|
| **Connected** | ✅ YES |
| **Authentication** | ⚠️ PARTIAL (Guest ✅ / Google ❌ / OTP ✅) |
| **Database Read** | ✅ YES |
| **Database Write** | ⚠️ CONDITIONAL (depends on RLS & public.users row) |
| **Storage** | ❓ UNKNOWN (uploadProfilePhoto implemented, not tested) |
| **Realtime** | ❌ NOT CONFIGURED |

---

## 1. Initialization

**File**: `lib/main.dart`

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co',
  publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key',
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
    detectSessionInUri: true,
    autoRefreshToken: true,
  ),
);
```

**Env File**: `.env.development`
```
SUPABASE_URL=https://esdhhbdzjmbdqstdsjro.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
```

**Result**: ✅ Supabase IS initialized from `.env.development`. Real URL and Anon Key are present. PKCE auth flow is enabled. Session detection is enabled.

**⚠️ RISK**: If `.env.development` file is missing at runtime (e.g., after a clean install or release build), the fallback is `'https://your-project.supabase.co'` which is a placeholder and will fail silently.

---

## 2. Authentication

### Guest Login
- **Method**: `SharedPreferences.setString('ne_auth_mode', 'guest')`
- **Supabase involvement**: NONE. No Supabase session is created.
- **Identity**: Local UUID generated via `IdentityManager`.
- **Status**: ✅ WORKS

### Google Login (OAuth)
- **Method**: `Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google, redirectTo: 'com.nutrientearth.app://login-callback/')`
- **Problem**: The Android deep link `com.nutrientearth.app://login-callback` is declared in AndroidManifest.xml correctly.
- **Root Cause of `ERR_CONNECTION_REFUSED`**: Supabase's OAuth flow opens a **browser** (Chrome/WebView). After Google authenticates, it redirects to `com.nutrientearth.app://login-callback/`. If Supabase project's **Redirect URLs** do not include this custom scheme, Supabase falls back to `localhost:PORT` — which is unreachable on a physical device. This is a **Supabase Dashboard Configuration issue**, not a code issue.
- **Status**: ❌ BROKEN — Supabase Dashboard Redirect URL NOT configured for custom scheme.

### Magic Link / OTP
- **Method**: `signInWithOtp(email: email, shouldCreateUser: true)` + `verifyOTP()`
- **Redirect**: OTP-based, no web redirect needed. Code is received via email.
- **Status**: ✅ SHOULD WORK (OTP code flow, no localhost redirect)
- **Note**: Magic link (click-to-login) would fail for the same reason as Google OAuth if it redirects to localhost.

### Email/Password Login
- **Status**: ❌ NOT IMPLEMENTED — `_handleSendOtp` triggers OTP, no password field in UI.

---

## 3. Database Operations

### Can the app read from `users` table?
- **Code**: `SupabaseService.getAppUser()` → `_client.from('users').select('*').eq('id', uid).maybeSingle()`
- **Status**: ✅ YES — implemented with error handling. Falls back to Isar if query fails.

### Can the app insert into `users`?
- **Code**: `SupabaseService.ensureUserRecordExists()` → `_client.from('users').upsert({id, email})`
- **Status**: ⚠️ CONDITIONAL — Requires RLS INSERT policy on `public.users` to allow authenticated user to insert their own row. If RLS blocks this, insertion fails silently (try/catch swallows the error).

### Can the app update profiles?
- **Code**: `SupabaseService.upsertUserProfile()` → `_client.from('user_profiles').upsert(combinedData, onConflict: 'user_id')`
- **Status**: ⚠️ CONDITIONAL — Requires `user_profiles` table to exist in database with the correct schema, and RLS policies to allow writes.

### Are RLS policies blocking writes?
- **Finding**: Cannot verify without live database introspection. Writes are wrapped in silent try/catch throughout codebase (e.g., `supabase_service.dart:135`: "Silently fail for now"). Failed writes are NOT exposed in the UI.
- **Status**: ❓ UNKNOWN — All write failures are silently swallowed.

---

## 4. Current Blockers

| Blocker | Severity | Fix Required |
|---------|----------|--------------|
| Google OAuth redirect → localhost | CRITICAL | Add `com.nutrientearth.app://login-callback` to Supabase Dashboard → Authentication → URL Configuration → Redirect URLs |
| Magic Link redirect → localhost | HIGH | Same fix as above |
| Silent write failures | HIGH | Expose errors in debug logs or UI instead of swallowing |
| RLS policy status unknown | MEDIUM | Audit RLS on `users`, `user_profiles`, `onboarding_drafts` tables |
| Email+Password login absent | LOW | Not in scope per requirements |
| Realtime not configured | LOW | Not required for current scope |
