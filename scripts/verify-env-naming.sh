#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCS="$ROOT/docs"

pass(){ echo "✅ $1"; }
fail(){ echo "❌ $1"; exit 1; }

awk -F'|' '/^[A-Z0-9_][A-Z0-9_ ]*\|/ {gsub(/ /,"",$1); print $1}' "$DOCS/ENV_CATALOG.md" \
 | sort -u > "$DOCS/.naming_catalog.txt"

ALLOWED='^[A-Z][A-Z0-9_]*$'
# Next.js non-public reserved whitelist
EXEMPT_NEXT=(
  NEXT_TELEMETRY_DISABLED
)

is_exempt_next() {
  local n="$1"
  for e in "${EXEMPT_NEXT[@]}"; do [[ "$n" == "$e" ]] && return 0; done
  return 1
}

BAD=0
while read -r name; do
  [[ -z "${name:-}" || "$name" =~ ^# ]] && continue

  if ! [[ "$name" =~ $ALLOWED ]]; then
    echo "NAMING: invalid pattern → $name"; BAD=1
  fi
  [[ "$name" == *"__"* ]] && { echo "NAMING: double underscore → $name"; BAD=1; }
  [[ "$name" == *_ ]] &&     { echo "NAMING: trailing underscore → $name"; BAD=1; }

  # Next.js rule: if starts with NEXT_, must be NEXT_PUBLIC_ unless exempt
  if [[ "$name" == NEXT_* && "$name" != NEXT_PUBLIC_* ]] && ! is_exempt_next "$name"; then
    echo "NAMING: gunakan prefix NEXT_PUBLIC_ untuk variabel Next.js → $name"; BAD=1
  fi
done < "$DOCS/.naming_catalog.txt"

if [[ $BAD -eq 0 ]]; then
  pass "Penamaan ENV: LULUS (0 pelanggaran)"
else
  fail "Penamaan ENV: GAGAL (ada pelanggaran)"
fi
