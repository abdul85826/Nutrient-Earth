#!/bin/bash
set -e

# ==============================================================================
# Nutrient Earth — Vercel Production Build Script
# Fast, reproducible static delivery for Vercel edge deployment.
# ==============================================================================

REPO_ROOT="$PWD"
echo "=== Nutrient Earth Vercel Build ==="
echo "Working directory: $REPO_ROOT"

# 1. Ensure latest stitch artboards (including Screen 18) are synced to build/web
if [ -d "$REPO_ROOT/client/web/stitch" ]; then
  echo "Syncing updated Stitch screens to build/web/stitch..."
  mkdir -p "$REPO_ROOT/build/web/stitch"
  cp -r "$REPO_ROOT/client/web/stitch/"* "$REPO_ROOT/build/web/stitch/"
fi

# Ensure assets/config.json exists in build/web/assets
if [ -f "$REPO_ROOT/client/assets/config.json" ] && [ -d "$REPO_ROOT/build/web/assets" ]; then
  cp "$REPO_ROOT/client/assets/config.json" "$REPO_ROOT/build/web/assets/config.json"
fi

# 2. Check if build/web is already pre-compiled
if [ -f "$REPO_ROOT/build/web/index.html" ] && [ -f "$REPO_ROOT/build/web/main.dart.js" ]; then
  TOTAL_FILES=$(find "$REPO_ROOT/build/web" -type f | wc -l)
  echo "SUCCESS: build/web release is ready with $TOTAL_FILES files."
else
  # Rebuild with Flutter if not pre-compiled and flutter is available
  if command -v flutter &> /dev/null; then
    echo "Compiling Flutter Web release..."
    cd "$REPO_ROOT/client"
    flutter config --no-analytics
    flutter pub get
    flutter build web --release
    cd "$REPO_ROOT"
    mkdir -p "$REPO_ROOT/build"
    cp -r "$REPO_ROOT/client/build/web" "$REPO_ROOT/build/"
  fi
fi

# 3. Verify final build output
if [ -f "$REPO_ROOT/build/web/index.html" ] && [ -f "$REPO_ROOT/build/web/main.dart.js" ]; then
  echo "=== Build output verified successfully ==="
  exit 0
else
  echo "ERROR: build/web output missing!"
  exit 1
fi
