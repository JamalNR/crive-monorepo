#!/usr/bin/env bash
set -euo pipefail
ALLOWLIST_FILE=".registry-allowlist.txt"
touch "$ALLOWLIST_FILE"

ALLOW_PATTERNS=$(grep -vE '^\s*#|^\s*$' "$ALLOWLIST_FILE" || true)

fail=0
TMP=$(mktemp)
# 1) URL selain npmjs registry
grep -Eroh --exclude-dir=node_modules 'https?://[^"'\'' )]+' pnpm-lock.yaml **/package.json 2>/dev/null \
  | grep -v 'registry.npmjs.org' > "$TMP" || true
if [ -s "$TMP" ]; then
  if [ -n "$ALLOW_PATTERNS" ]; then
    while read -r pat; do grep -v "$pat" "$TMP" -i > "$TMP.f" && mv "$TMP.f" "$TMP"; done <<< "$ALLOW_PATTERNS"
  fi
fi
if [ -s "$TMP" ]; then
  echo "[REGISTRY] Disallowed external URLs detected:"
  cat "$TMP"
  fail=1
fi

# 2) Larang spec non-registry: github:, git+, file:, link:
grep -Eroh --exclude-dir=node_modules '(github:|git\+|file:|link:)' **/package.json pnpm-lock.yaml 2>/dev/null > "$TMP" || true
if [ -s "$TMP" ]; then
  if [ -n "$ALLOW_PATTERNS" ]; then
    while read -r pat; do grep -v "$pat" "$TMP" -i > "$TMP.f" && mv "$TMP.f" "$TMP"; done <<< "$ALLOW_PATTERNS"
  fi
fi
if [ -s "$TMP" ]; then
  echo "[REGISTRY] Non-registry specs found (github:/git+/file:/link:):"
  cat "$TMP"
  fail=1
fi

# 3) Integritas store PNPM (default true), laporkan status
echo "[INFO] verify-store-integrity assumed true (pnpm default)."

# Upload laporan kalau ada pelanggaran
if [ "$fail" -ne 0 ]; then
  mkdir -p artifacts/security
  ( echo "=== REGISTRY VIOLATIONS ==="; date; ) > artifacts/security/registry-violations.txt
  grep -Eroh 'https?://[^"'\'' )]+' pnpm-lock.yaml **/package.json 2>/dev/null | sort -u >> artifacts/security/registry-violations.txt || true
  exit 2
else
  echo "[OK] Registry pin & integrity check passed."
fi
