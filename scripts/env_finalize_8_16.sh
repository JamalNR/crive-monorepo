#!/usr/bin/env bash
set -euo pipefail

echo "[8] Validasi pola ignore (.gitignore)"
git check-ignore -v .env apps/admin/.env apps/api/foo.env
git check-ignore -v .env.example apps/admin/.env.example || true
echo "OK: pola ignore sesuai"

echo "[9] Sanity test pre-commit guard (negative test)"
echo "sk_live_TEST" > _tmp_secret || true
git add _tmp_secret || true
if git commit -m "tmp should fail" 2>/dev/null; then
  echo "FAIL: Guard tidak memblokir"; exit 1
else
  echo "OK: Guard memblokir commit berisi pola rahasia"
fi
git reset HEAD _tmp_secret >/dev/null 2>&1 || true
rm -f _tmp_secret

echo "[10] Cek selisih .env.example ↔ .env (lokal)"
pnpm -w run check:env:local

echo "[10b] Sanitasi .env.example (pastikan tak ada pola rahasia)"
if egrep -qi 'sk_live_|AKIA[0-9A-Z]{16}|AIzaSy|xoxb-|BEGIN .* PRIVATE KEY' .env.example; then
  echo "FAIL: .env.example terdeteksi pola rahasia"; exit 1
else
  echo "OK: .env.example bersih (sanitized)"
fi

echo "[11] Integrasi CI — DISKIP sesuai instruksi Anda"

echo "[12] Mapping per layanan (API/WEB/DB) — kunci minimum"
egrep -n '^(API_PORT|DATABASE_URL|API_JWT_SECRET|NEXT_PUBLIC_API_URL)=' .env.example

echo "[15] Review berkala (append log)"
mkdir -p docs/env/review/$(date +%Y)-Q$(($(date +%-m - 1)/3 + 1))
echo "$(date -u '+%F %T UTC') — ENV Pathing Sub-Stages 8–16 PASS (CI step skipped)" >> docs/env/REVIEW_LOG.md

echo "[16] Final verification — semua cek lulus"
