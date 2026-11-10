#!/bin/bash
set -e

# ==============================================================================
# Nutrient Earth — Vercel Production Build Script
# Pins Flutter SDK to 3.47.1 (stable) for reproducible Web builds.
# ==============================================================================

REPO_ROOT="$PWD"
FLUTTER_VERSION="3.47.1"
echo "=== Establishing Reproducible Flutter SDK Environment ($FLUTTER_VERSION) ==="
echo "Working directory: $REPO_ROOT"

if command -v flutter &> /dev/null; then
  echo "Flutter is already installed: $(flutter --version | head -n 1)"
else
  echo "Downloading Flutter SDK $FLUTTER_VERSION..."
  mkdir -p /tmp/flutter_dl
  curl -sSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" | tar -xJ -C /tmp
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

echo "=== Verifying build output ==="
if [ -f "$REPO_ROOT/build/web/index.html" ] && [ -f "$REPO_ROOT/build/web/main.dart.js" ] && [ -f "$REPO_ROOT/build/web/stitch/screen_01/index.html" ]; then
  TOTAL_FILES=$(find "$REPO_ROOT/build/web" -type f | wc -l)
  echo "SUCCESS: build/web generated successfully with $TOTAL_FILES files."
else
  echo "ERROR: build/web/index.html or main.dart.js not found!"
  exit 1
fi

echo "=== Generating Vercel Build Output API v3 Tree (.vercel/output) ==="
cd "$REPO_ROOT"
node scripts/prepare-vercel-output.js
