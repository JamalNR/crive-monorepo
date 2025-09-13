#!/usr/bin/env bash
set -euo pipefail
OUT="db/audit"
mkdir -p "$OUT"
STAMP="$(date +%Y%m%dT%H%M%S)"
SCHEMA="$OUT/schema-${STAMP}.sql"

pg_dump "${DATABASE_URL:?}" --schema-only --no-owner --no-privileges > "$SCHEMA"

# Diff terhadap file terakhir (jika ada)
LAST="$(ls -1 $OUT/schema-*.sql 2>/dev/null | tail -n2 | head -n1 || true)"
if [ -f "$LAST" ]; then
  echo "### Schema diff vs $(basename "$LAST")" >> "$GITHUB_STEP_SUMMARY"
  diff -u "$LAST" "$SCHEMA" || true
fi

echo "Schema snapshot: $SCHEMA"