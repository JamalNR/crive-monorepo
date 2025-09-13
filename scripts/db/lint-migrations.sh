#!/usr/bin/env bash
set -euo pipefail
ERR=0
echo "Lint: scan anti-destruktif (DROP/TABLE REWRITE/NOT NULL langsung)..."
while IFS= read -r -d '' f; do
  low=$(tr 'A-Z' 'a-z' < "$f")
  bad=""
  grep -Eiq '\bdrop\s+(table|column|constraint|index)\b' <<<"$low" && bad=1
  grep -Eiq 'alter\s+table\s+.+\s+alter\s+column\s+.+\s+set\s+not\s+null' <<<"$low" && bad=1
  grep -Eiq '\bcluster\b|\bvacuum\s+full\b' <<<"$low" && bad=1
  if [ -n "${bad}" ]; then
    echo "::error file=$f::Mengandung operasi destruktif. Ikuti policy expand→contract."
    ERR=1
  fi
done < <(find db/migrations -maxdepth 1 -name '*.sql' -print0)

exit $ERR
