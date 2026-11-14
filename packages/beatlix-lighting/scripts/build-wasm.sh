#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
CRATE="$REPO_ROOT/crates/beatlix-lighting"
OUT="$REPO_ROOT/packages/beatlix-lighting"

wasm-pack build "$CRATE" \
  --target web \
  --out-dir "$OUT" \
  --out-name wasm \
  -- --features wasm
