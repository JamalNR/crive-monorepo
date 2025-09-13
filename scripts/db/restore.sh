set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL required}"
: "${DUMP_FILE:?DUMP_FILE required}"
pg_restore --clean --if-exists --no-owner -d "$DATABASE_URL" "$DUMP_FILE"