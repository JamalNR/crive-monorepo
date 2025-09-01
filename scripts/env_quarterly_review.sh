#!/usr/bin/env bash
set -euo pipefail

PROJECT="${PROJECT:-crive}"
CONFS="${CONFS:-stg prd}"   # configs yang direview
NOW_UTC=$(date -u +%F"T"%H:%M:%SZ)
Y=$(date -u +%Y)
M=$(date -u +%m); Q=$(( (10#$M + 2) / 3 ))  # 1..4
OUTDIR="docs/env/review/${Y}-Q${Q}"
mkdir -p "$OUTDIR"

echo "# ENV Quarterly Review – ${Y}-Q${Q}" > "${OUTDIR}/SUMMARY.md"
echo "" >> "${OUTDIR}/SUMMARY.md"
echo "- Timestamp (UTC): ${NOW_UTC}" >> "${OUTDIR}/SUMMARY.md"
echo "- Project: ${PROJECT}" >> "${OUTDIR}/SUMMARY.md"
echo "" >> "${OUTDIR}/SUMMARY.md"

for cfg in ${CONFS}; do
  echo "[*] Dumping keys for config=$cfg"
  # ambil KUNCI saja (tanpa nilai), urut & unik
  KEYS="${OUTDIR}/ENV_KEYS_${cfg}.txt"
  doppler secrets download --project "${PROJECT}" --config "${cfg}" --format env \
    | cut -d= -f1 | sed '/^\s*$/d' | sort -u > "$KEYS"

  echo "## ${cfg}" >> "${OUTDIR}/SUMMARY.md"
  echo "" >> "${OUTDIR}/SUMMARY.md"
  echo "- Total keys: $(wc -l < "$KEYS")" >> "${OUTDIR}/SUMMARY.md"

  # bandingkan dengan kuartal sebelumnya bila ada
  PY=$Y; PQ=$((Q-1)); if [ $PQ -eq 0 ]; then PY=$((Y-1)); PQ=4; fi
  PREV="docs/env/review/${PY}-Q${PQ}/ENV_KEYS_${cfg}.txt"
  if [ -f "$PREV" ]; then
    echo "" >> "${OUTDIR}/SUMMARY.md"
    echo "<details><summary>Diff vs ${PY}-Q${PQ}</summary>" >> "${OUTDIR}/SUMMARY.md"
    echo "" >> "${OUTDIR}/SUMMARY.md"
    diff -u "$PREV" "$KEYS" || true | sed 's/^/    /' >> "${OUTDIR}/SUMMARY.md"
    echo "" >> "${OUTDIR}/SUMMARY.md"
    echo "</details>" >> "${OUTDIR}/SUMMARY.md"
  else
    echo "" >> "${OUTDIR}/SUMMARY.md"
    echo "_Tidak ada baseline sebelumnya (first run)_" >> "${OUTDIR}/SUMMARY.md"
  fi

  echo "" >> "${OUTDIR}/SUMMARY.md"
done

# append log review kumulatif
LOG="docs/env/REVIEW_LOG.md"
touch "$LOG"
{
  echo "| Timestamp (UTC) | Quarter | Project | Notes |"
  echo "|---|---|---|---|"
  tail -n +3 "$LOG" 2>/dev/null || true
  echo "| ${NOW_UTC} | ${Y}-Q${Q} | ${PROJECT} | Auto-generated review; lihat folder ${OUTDIR} |"
} > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"

echo "${OUTDIR}"   # path artefak (dipakai workflow)
