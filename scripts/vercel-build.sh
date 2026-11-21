#!/bin/bash
set -e

# ==============================================================================
# Nutrient Earth - Vercel Production Build Script
# Fast, reproducible static delivery for Vercel edge deployment.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
node "$SCRIPT_DIR/build.js"
