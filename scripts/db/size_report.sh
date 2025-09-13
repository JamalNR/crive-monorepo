#!/usr/bin/env bash
set -euo pipefail
du -sh /var/backups/crive/* 2>/dev/null || true
