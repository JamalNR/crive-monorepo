#!/usr/bin/env bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL required}"
OUT="${1:-schema-$(date +%Y%m%d-%H%M).sql}"
pg_dump "$DATABASE_URL" --schema-only --no-owner --no-privileges > "$OUT"
sha256sum "$OUT" > "$OUT.sha256" 2>/dev/null || shasum -a 256 "$OUT" > "$OUT.sha256"
echo "Schema snapshot -> $OUT"
