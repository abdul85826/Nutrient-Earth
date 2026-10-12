# Nutrient Earth

> Continuous Health Context & Decision Intelligence Platform

Nutrient Earth transforms fragmented health data into trusted, evidence-based, personalized guidance. Built on Flutter and Supabase, it provides a unified health memory powered by deterministic reasoning and peer-reviewed clinical knowledge.

---

## 1. Prerequisites & Toolchain

- **Flutter SDK**: `>=3.22.0` (Tested on 3.47.1-pre)
- **Dart SDK**: `>=3.4.0` (Tested on 3.13.1)
- **Node.js & npm**: For Supabase CLI commands
- **Google Chrome**: For Flutter Web development
- **Supabase CLI**: For local and remote project synchronization

---

## 2. Quickstart & Local Development

### Client Installation
```bash
cd client
flutter pub get
```

### Running Flutter Web
To ensure OAuth redirects align with the configured Supabase authentication allowlist, run Flutter Web on the designated development port (**5656**):

```bash
flutter run -d chrome --web-port 5656
```

### Running on Mobile (Android / iOS)
```bash
# Android
flutter run -d android

# iOS (macOS required)
flutter run -d ios
```

---

## 3. Authentication Architecture & OAuth Configuration

Nutrient Earth uses **Supabase Auth** with PKCE (Proof Key for Code Exchange) flow:

### Platform Redirect URIs
- **Web**: Uses dynamic browser origin (`${Uri.base.origin}/`). In local development, this resolves to `http://localhost:5656/`. In production, this resolves to the deployed web domain.
- **Android**: Custom deep-link scheme `com.nutrientearth.app://login-callback` registered in `android/app/src/main/AndroidManifest.xml`.
- **iOS**: Custom URL scheme `com.nutrientearth.app` registered in `ios/Runner/Info.plist`.

### Supabase URL Configuration
- **Site URL**: `http://localhost:5656`
- **Redirect URLs (Allowlist)**:
  - `http://localhost:*/**`
  - `http://127.0.0.1:*/**`
  - `http://localhost:5656/**`
  - `com.nutrientearth.app://**`
  - `com.nutrientearth.app://login-callback`

### Google Cloud OAuth Configuration
- **Authorized JavaScript Origins**: `https://<supabase-project-ref>.supabase.co`
- **Authorized Redirect URIs**: `https://<supabase-project-ref>.supabase.co/auth/v1/callback`

---

## 4. Verification & Testing

Run all quality gates prior to pushing commits:

```bash
cd client

# Check formatting
dart format --output=none --set-exit-if-changed lib test

# Static analysis
flutter analyze

# Run unit & regression test suite
flutter test
```

---

## 5. Engineering Documentation

- [OAUTH_REPAIR_CHANGELOG.md](file:///d:/Documents/NE_App/Nutrient_Earth/docs/engineering/OAUTH_REPAIR_CHANGELOG.md) — Comprehensive OAuth defect diagnosis, replacement register, and verification log.
- [docs/product_spec/](file:///d:/Documents/NE_App/Nutrient_Earth/docs/product_spec/) — Source-of-truth architecture, security, and product specifications.
