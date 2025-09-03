#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/artifacts/sbom"; mkdir -p "$OUT"

# pilih runner: pnpm dlx atau npx
if command -v pnpm >/dev/null 2>&1; then
  GEN="pnpm dlx -y @cyclonedx/cyclonedx-npm"
else
  GEN="npx -y @cyclonedx/cyclonedx-npm"
fi

gen() {
  local DIR="$1"; [ -d "$DIR" ] || return 0
  ( cd "$DIR";
    local NAME; NAME="$(node -p "require('./package.json').name || require('path').basename(process.cwd())")"
    echo "[*] SBOM: $NAME ($DIR)"
    $GEN --output-format json --spec-version 1.5 --omit dev --output-file "$OUT/sbom-${NAME}.json"
  )
}
gen apps/api
gen apps/admin
gen packages/shared
echo "[*] Done. Files:"; ls -1 "$OUT" || true
