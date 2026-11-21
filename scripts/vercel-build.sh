#!/bin/bash
set -e

# ==============================================================================
# Nutrient Earth — Vercel Production Build Script
# Automatically downloads official Flutter stable SDK and compiles Flutter Web Release.
# ==============================================================================

REPO_ROOT="$PWD"
echo "=== Establishing Official Flutter SDK Environment ==="
echo "Working directory: $REPO_ROOT"

if command -v flutter &> /dev/null; then
  echo "Flutter is already installed: $(flutter --version | head -n 1)"
else
  echo "Setting up Flutter stable SDK..."
  if [ ! -d "/tmp/flutter/bin" ]; then
    rm -rf /tmp/flutter
    FLUTTER_TAR_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.4-stable.tar.xz"
    echo "Downloading official Flutter stable tarball from $FLUTTER_TAR_URL..."
    if curl -sSfL "$FLUTTER_TAR_URL" -o /tmp/flutter.tar.xz; then
      tar -xf /tmp/flutter.tar.xz -C /tmp
      rm -f /tmp/flutter.tar.xz
    else
      echo "Tarball download failed, falling back to git clone --depth 1 -b stable..."
      git clone --depth 1 -b stable https://github.com/flutter/flutter.git /tmp/flutter
    fi
  fi
  export PATH="/tmp/flutter/bin:$PATH"
fi

git config --global --add safe.directory /tmp/flutter 2>/dev/null || true

echo "=== Verified Flutter Environment ==="
flutter --version

echo "=== Building Flutter Web Release ==="
cd "$REPO_ROOT"
if [ -d "client" ] && [ -f "client/pubspec.yaml" ]; then
  cd client
fi

echo "Current build directory: $PWD"
flutter config --no-analytics
flutter pub get
flutter build web --release

# Ensure assets/config.json exists directly under assets/ for direct HTTP requests
if [ -f "build/web/assets/assets/config.json" ] && [ ! -f "build/web/assets/config.json" ]; then
  cp "build/web/assets/assets/config.json" "build/web/assets/config.json"
fi

# Ensure output is mirrored to both root build/web and client/build/web
if [ "$PWD" != "$REPO_ROOT" ]; then
  mkdir -p "$REPO_ROOT/build"
  rm -rf "$REPO_ROOT/build/web"
  cp -r build/web "$REPO_ROOT/build/"
fi

# Ensure stitch assets are present in root build/web/stitch
if [ -d "$REPO_ROOT/client/web/stitch" ] && [ ! -d "$REPO_ROOT/build/web/stitch" ]; then
  mkdir -p "$REPO_ROOT/build/web"
  cp -r "$REPO_ROOT/client/web/stitch" "$REPO_ROOT/build/web/stitch"
fi

echo "=== Verifying build output ==="
if [ -f "$REPO_ROOT/build/web/index.html" ] && [ -f "$REPO_ROOT/build/web/main.dart.js" ]; then
  TOTAL_FILES=$(find "$REPO_ROOT/build/web" -type f | wc -l)
  echo "SUCCESS: build/web generated successfully with $TOTAL_FILES files."
else
  echo "ERROR: build/web/index.html or main.dart.js not found!"
  exit 1
fi

echo "=== Generating Vercel Build Output API v3 Tree (.vercel/output) ==="
cd "$REPO_ROOT"
node scripts/prepare-vercel-output.js
