#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
CRATE="$REPO_ROOT/crates/beatlix-lighting"
OUT="$REPO_ROOT/packages/beatlix-lighting"

# Save package.json before wasm-pack overwrites it
cp "$OUT/package.json" "$OUT/package.json.bak"

wasm-pack build "$CRATE" \
  --target web \
  --out-dir "$OUT" \
  --out-name wasm \
  -- --features wasm

# Restore our package.json
mv "$OUT/package.json.bak" "$OUT/package.json"
