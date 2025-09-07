#!/usr/bin/env bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"
DOCKER=${DOCKER:-docker}
if ! $DOCKER info >/dev/null 2>&1; then DOCKER="sudo -n docker"; fi
NET_ARG=""
if [ -n "${DOCKER_NETWORK:-}" ] && $DOCKER network ls --format '{{.Name}}' | grep -qx "$DOCKER_NETWORK"; then
  NET_ARG="--network $DOCKER_NETWORK"
fi
$DOCKER run --rm $NET_ARG \
  -e DATABASE_URL="$DATABASE_URL" \
  -v "$(pwd)":/work -w /work node:20-bullseye \
  bash -lc 'npm i pg@8 --no-audit --no-fund --silent; node db/scripts/migrate.cjs up'
