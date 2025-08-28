#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(pwd)}"
OUT_DIR="$ROOT/docs"
RAW="$OUT_DIR/env_scan_raw.csv"

mkdir -p "$OUT_DIR"
echo "source,file,line,match" > "$RAW"

rg --no-ignore -n --glob '!node_modules' --glob '!.git' --glob '!dist' \
  -e 'process\.env\.[A-Z0-9_]+' \
  -e '\$\{[A-Z0-9_]+\}' \
  -e 'secrets\.([A-Z0-9_]+)' \
  -e '(^|[^A-Z0-9_])([A-Z0-9_]{3,})=' \
  -g '!*.png' -g '!*.jpg' -g '!*.svg' -g '!*.pdf' \
  "$ROOT" \
| gawk -F: 'BEGIN{OFS=","} {file=$1; line=$2; sub(/^[^:]+:[0-9]+:/,""); code=$0; src="code"; gsub(/"/,"\"\"",code); print src,file,line,"\"" code "\""}' \
>> "$RAW"

echo ">> Scan selesai: $RAW"
echo "Tips: buka CSV ini dan cocokkan ke docs/ENV_CATALOG.md."
