#!/usr/bin/env bash
set -euo pipefail
echo "## Compliance & Supply-Chain Summary" >> $GITHUB_STEP_SUMMARY
if [ -f license-report.json ]; then
  echo "- License report: \`license-report.json\` (artifact)" >> $GITHUB_STEP_SUMMARY
fi
echo "- OSV & Trivy: gate HIGH/CRITICAL = **aktif**" >> $GITHUB_STEP_SUMMARY
echo "- SBOM CycloneDX: artifact \`sbom-cyclonedx.json\`" >> $GITHUB_STEP_SUMMARY
echo "- Lockfile discipline: wajib label \`deps\`/\`renovate\` jika \`pnpm-lock.yaml\` berubah" >> $GITHUB_STEP_SUMMARY
