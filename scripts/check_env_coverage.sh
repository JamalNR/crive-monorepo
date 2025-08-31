#!/usr/bin/env bash
set -euo pipefail
REPORT="${1:-$(ls -t docs/env/ENV_REPORT_*.md | head -1)}"
echo "[INFO] Using report: $REPORT"
overall_ok=1

for app in api admin; do
  EX="apps/$app/.env.example"
  if [[ ! -f "$EX" ]]; then
    echo "[SKIP] $EX not found"
    continue
  fi
  echo "[CHECK] apps/$app"

  S=$(grep -n "^## apps/$app$" "$REPORT" | head -1 | cut -d: -f1 || true)
  if [[ -z "${S:-}" ]]; then
    echo "FAIL apps/$app: section missing in report"
    overall_ok=0
    continue
  fi
  E=$(tail -n +"$((S+1))" "$REPORT" | grep -n "^## " | head -1 | cut -d: -f1 || true)
  if [[ -z "${E:-}" ]]; then
    E=$(wc -l < "$REPORT")
  else
    E=$((S+E-2))
  fi

  tmp_doc="$(mktemp)"; tmp_ex="$(mktemp)"
  sed -n "${S},${E}p" "$REPORT" \
    | grep -E '^\|[[:space:]]*[A-Z0-9_]+[[:space:]]*\|' \
    | grep -vE '^\|[[:space:]]*Key[[:space:]]*\|' \
    | cut -d'|' -f2 \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
    | sort -u > "$tmp_doc"

  cut -d= -f1 "$EX" | sed '/^\s*$/d' | sort -u > "$tmp_ex"

  if diff -u "$tmp_ex" "$tmp_doc"; then
    echo "PASS apps/$app (all keys covered)"
  else
    echo "FAIL apps/$app (see diff above)"
    overall_ok=0
  fi

  rm -f "$tmp_doc" "$tmp_ex"
done

if [[ $overall_ok -eq 1 ]]; then
  exit 0
else
  exit 1
fi
