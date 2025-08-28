#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

pass(){ echo "✅ $1"; }
fail(){ echo "❌ $1"; exit 1; }

TEMPLATE="$ROOT/.env.example"
[[ -s "$TEMPLATE" ]] || fail ".env.example tidak ada / kosong"

# 1) Tidak ada secret sungguhan di placeholder
#    - Boleh: kosong, "change_me*", "dummy", "example", "postgres://USER:PASS@HOST:5432/db"
BAD_LINES=$(awk -F= '
  /^[A-Z0-9_]+=/{key=$1; val=$0; sub(/^[^=]*=/,"",val);
    isSecret=(key ~ /(SECRET|PASSWORD|TOKEN|API[_]?KEY|ACCESS[_]?KEY|SERVER_KEY|CLIENT_KEY)$/)
    allow=(val=="" || val ~ /^change_me/ || val ~ /dummy/i || val ~ /example/i || val ~ /^postgres:\/\/USER:PASS@HOST:5432\//)
    if(isSecret && !allow){ print NR ":" $0 }
  }' "$TEMPLATE")

if [[ -n "$BAD_LINES" ]]; then
  echo "$BAD_LINES"
  fail ".env.example mengandung nilai yang tampak seperti secret asli"
else
  pass "Tidak ada secret asli di .env.example"
fi

# 2) Kunci WEB & API minimal ada
REQ_WEB=( NEXT_PUBLIC_APP_URL NEXT_PUBLIC_API_BASE_URL NEXT_PUBLIC_API_URL NEXT_TELEMETRY_DISABLED )
REQ_API=( API_PORT DATABASE_URL JWT_SECRET RATE_LIMIT_MAX OPENAI_API_KEY )
for k in "${REQ_WEB[@]}" "${REQ_API[@]}"; do
  grep -Eq "^${k}=" "$TEMPLATE" || fail "Key wajib tidak ditemukan: $k"
done
pass "Key wajib WEB & API ada"

# 3) Semua nama di .env.example harus tercatat di katalog
DOCS="$ROOT/docs"
awk -F'|' '/^[A-Z0-9_][A-Z0-9_ ]*\|/ {gsub(/ /,"",$1); print $1}' "$DOCS/ENV_CATALOG.md" \
 | sort -u > "$DOCS/.catalog_names.txt"
awk -F= '/^[A-Z0-9_]+=/{print $1}' "$TEMPLATE" | sort -u > "$DOCS/.template_names.txt"
EXTRA=$(comm -23 "$DOCS/.template_names.txt" "$DOCS/.catalog_names.txt" || true)
if [[ -n "$EXTRA" ]]; then
  echo "$EXTRA"
  fail "Ada nama di .env.example yang belum ada di ENV_CATALOG.md"
fi
pass ".env.example sinkron dengan ENV_CATALOG.md"

# 4) Ringkasan
echo "----- RINGKASAN -----"
echo "Template keys :" $(wc -l < "$DOCS/.template_names.txt")
echo "Catalog  keys :" $(wc -l < "$DOCS/.catalog_names.txt")
pass "VERIFIKASI .env.example: LULUS (100%)"
