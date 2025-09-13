#!/usr/bin/env bash
# Contoh backfill batchable + resume via offset key
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL required}"
TABLE="${1:?table name}"; COL="${2:?column to fill}"; SQL_EXPR="${3:?sql expression}"
BATCH="${BATCH_SIZE:-1000}"
OFFSET="${OFFSET:-0}"

echo "[backfill] table=$TABLE col=$COL expr=$SQL_EXPR batch=$BATCH offset=$OFFSET"
while true; do
  CHANGED=$(psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -t -A <<SQL
WITH cte AS (
  SELECT id FROM $TABLE
  WHERE $COL IS NULL
  ORDER BY id
  OFFSET $OFFSET LIMIT $BATCH
)
UPDATE $TABLE t
SET $COL = ($SQL_EXPR)
FROM cte
WHERE t.id = cte.id
RETURNING 1;
SQL
)
  CNT=$(echo "$CHANGED" | wc -l | tr -d ' ')
  echo "[backfill] changed=$CNT offset=$OFFSET"
  if [ "$CNT" -eq 0 ]; then break; fi
  OFFSET=$((OFFSET + BATCH))
done
echo "[backfill] done."
