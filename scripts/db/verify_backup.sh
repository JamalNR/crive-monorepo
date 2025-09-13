set -euo pipefail
: "${1:?usage: verify_backup.sh </path/file.dump.gpg>}"
FILE="$1"
PASSPH="${BACKUP_PASSPHRASE:-}"
TMP="$(mktemp -d)"
OUT="$TMP/out.dump"
gpg --batch --yes --passphrase "$PASSPH" -o "$OUT" -d "$FILE"
docker rm -f pg-verify >/dev/null 2>&1 || true
docker run -d --name pg-verify -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=check -p 0:5432 postgres:17 >/dev/null
# wait
sleep 5; until docker exec pg-verify pg_isready -U postgres -d check >/dev/null 2>&1; do sleep 1; done
PORT=$(docker port pg-verify 5432/tcp | sed 's/.*://')
RESTORE_URL="postgresql://postgres:postgres@localhost:${PORT}/check"
pg_restore --exit-on-error --no-owner -d "$RESTORE_URL" "$OUT"
echo "Verify OK"