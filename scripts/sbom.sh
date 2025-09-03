#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/artifacts/sbom"
mkdir -p "$OUT"

gen() {
  local DIR="$1"
  [ -d "$DIR" ] || return 0
  ( cd "$DIR"
    local NAME
    NAME="$(node -p "require('./package.json').name || require('path').basename(process.cwd())")"
    echo "[*] Generating SBOM for: $NAME ($DIR)"
    pnpm dlx -y @cyclonedx/cyclonedx-npm \
      --output-format json \
      --spec-version 1.5 \
      --omit dev \
      --output-file "$OUT/sbom-${NAME}.json"
  )
}

# daftar workspace yang kita pakai di repo ini
gen apps/api
gen apps/admin
gen packages/shared

echo "[*] Generated files:"
ls -l "$OUT" || true
