: "${DATABASE_URL:?DATABASE_URL required}"
BACKUP_DIR="${BACKUP_DIR:-/tmp/crive-backups}"
PASSPH="${BACKUP_PASSPHRASE:-}"
mkdir -p "$BACKUP_DIR/daily"

STAMP="$(date +'%Y%m%d-%H%M%S')"
OUT="$BACKUP_DIR/daily/crive-${STAMP}.dump"
pg_dump --no-owner --format=custom "$DATABASE_URL" -f "$OUT"
if [ -n "$PASSPH" ]; then
  gpg --batch --yes --passphrase "$PASSPH" -c "$OUT"
  shasum -a 256 "$OUT.gpg" > "$OUT.gpg.sha256"
  rm -f "$OUT"
  echo "Backup OK: $OUT.gpg"
else
  shasum -a 256 "$OUT" > "$OUT.sha256"
  echo "Backup OK: $OUT"
fi