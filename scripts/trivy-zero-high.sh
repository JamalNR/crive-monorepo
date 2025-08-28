#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
REPORT="/tmp/trivy-node.json"
OVR="/tmp/pnpm-overrides.json"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1"; exit 1; }; }
need trivy; need jq; need node; need pnpm

echo "==[1] Install dependencies (respect overrides) =="
pnpm install

round=0
while :; do
  round=$((round+1))
  echo "==[2] Scan round #$round =="
  trivy fs --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed=false \
    --no-progress -f json . > "$REPORT"

  TOTAL=$(jq '[ .Results[]? | .Vulnerabilities[]? | select(.Severity=="HIGH" or .Severity=="CRITICAL") ] | length' "$REPORT")
  echo "   HIGH/CRITICAL found: $TOTAL"
  if [ "$TOTAL" -eq 0 ]; then
    echo "== OK: HIGH/CRITICAL = 0"
    break
  fi

  echo "==[3] Generate overrides for FIXED vulns =="
  jq '
    [ .Results[]? | .Vulnerabilities[]? 
      | select((.Severity=="HIGH" or .Severity=="CRITICAL")
               and (.FixedVersion!=null and .FixedVersion!="" ))
      | {PkgName, FixedVersion}
    ]
    | sort_by(.PkgName)
    | group_by(.PkgName)
    | map({ (.[0].PkgName): (.[0].FixedVersion)})
    | add // {}
  ' "$REPORT" > "$OVR"

  if [ "$(jq 'length' "$OVR")" -eq 0 ]; then
    echo "== No fixable vulns via overrides. Stopping loop."
    break
  fi

  echo "==[4] Merge into root package.json → pnpm.overrides =="
  node -e '
    const fs=require("fs");
    const P="package.json";
    const O=process.argv[1];
    const pkg=JSON.parse(fs.readFileSync(P,"utf8"));
    const ov=JSON.parse(fs.readFileSync(O,"utf8"));
    pkg.pnpm ||= {};
    pkg.pnpm.overrides ||= {};
    Object.assign(pkg.pnpm.overrides, ov);
    fs.writeFileSync(P, JSON.stringify(pkg,null,2));
    console.log("Merged overrides:", pkg.pnpm.overrides);
  ' "$OVR"

  echo "==[5] Install to apply overrides =="
  pnpm install
done

echo "==[6] Final verification table =="
trivy fs --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed=false \
  --no-progress -f table .

LEFT=$(trivy fs -f json --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed=false . \
  | jq '[ .Results[]? | .Vulnerabilities[]? 
          | select((.Severity=="HIGH" or .Severity=="CRITICAL")
                   and (.FixedVersion==null or .FixedVersion=="")) ] 
        | map({PkgName, InstalledVersion, VulnerabilityID}) | unique | length')

if [ "$LEFT" -gt 0 ]; then
  echo "== Remaining without FixedVersion: $LEFT (need replace/remove)"
  trivy fs -f json --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed=false . \
    | jq -r '
        .Results[]?.Vulnerabilities[]?
        | select((.Severity=="HIGH" or .Severity=="CRITICAL")
                 and (.FixedVersion==null or .FixedVersion==""))
        | "\(.PkgName)@\(.InstalledVersion)  CVE=\(.VulnerabilityID)"
      ' | sort -u | tee /tmp/trivy-leftovers.txt

  echo "== Who pulls them in (pnpm why) =="
  while read -r line; do
    PKG="${line%@*}"
    echo "---- $PKG ----"
    pnpm why "$PKG" || true
  done < <(cut -d' ' -f1 /tmp/trivy-leftovers.txt | sed 's/@[0-9].*//g' | sort -u)
  exit 2
fi

echo "== SUCCESS: HIGH = 0 and CRITICAL = 0 =="
