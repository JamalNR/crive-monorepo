#!/usr/bin/env bash
set -euo pipefail
OUT="docs/env/ENV_REPORT_$(date +%F).md"
{
  echo "# ENV Report – $(date +%F)"
  echo
  for app in api admin; do
    EX="apps/$app/.env.example"; [ -f "$EX" ] || continue
    echo "## apps/$app"; echo
    echo "| Key | Type | Source | Notes |"
    echo "|-----|------|--------|-------|"
    cut -d= -f1 "$EX" | sed '/^\s*$/d' | sort -u | while read -r k; do
      if [[ "$k" == NEXT_PUBLIC_* ]]; then
        echo "| $k | non-secret | repo(.env.example) | public var |"
      else
        echo "| $k | secret | Doppler(prd) | runtime injection |"
      fi
    done
    echo
  done
  echo "Sumber: docs/ENV_CATALOG.md, Doppler (project=crive, config=prd)"
} > "$OUT"
echo "$OUT"
