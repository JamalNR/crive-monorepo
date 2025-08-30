#!/usr/bin/env bash
set -euo pipefail

ALL_ENV_FILE="${1:-/tmp/env.all}"
ALLOWLIST_FILE="$2"
OUT_FILE="$3"

if [[ ! -f "$ALLOWLIST_FILE" ]]; then
  echo "Allowlist not found: $ALLOWLIST_FILE" >&2
  exit 2
fi

# Ambil hanya KEY=VALUE dari dump Doppler, lalu filter sesuai allowlist
grep -E '^[A-Z0-9_]+=.*$' "$ALL_ENV_FILE" | \
  grep -E -f <(grep -E '^[A-Z0-9_]+' "$ALLOWLIST_FILE" | sed 's/$/=/' ) \
  > "$OUT_FILE"

# Preflight: fail kalau ada key di allowlist yang tidak tersedia
MISSING=()
while IFS= read -r KEY; do
  [[ -z "$KEY" || "$KEY" =~ ^# ]] && continue
  if ! grep -qE "^${KEY}=" "$OUT_FILE"; then
    MISSING+=("$KEY")
  fi
done < <(grep -E '^[A-Z0-9_]+' "$ALLOWLIST_FILE")

if (( ${#MISSING[@]} > 0 )); then
  echo "ERROR: Missing required env keys:" >&2
  for k in "${MISSING[@]}"; do echo " - $k" >&2; done
  exit 3
fi

chmod 600 "$OUT_FILE"
echo "Generated $(basename "$OUT_FILE") with $(wc -l < "$OUT_FILE") keys"
