#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL not set}"

WORK="$HOME/.crive-migs/work"
cd "$WORK"

NET_ARG=""
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  if [[ -n "${DOCKER_NETWORK:-}" ]] && docker network ls --format '{{.Name}}' | grep -qx "${DOCKER_NETWORK}"; then
    NET_ARG="--network ${DOCKER_NETWORK}"
  else
    NET=$(docker ps --format '{{.Networks}}' | tr ' ' '\n' | grep -E 'crive.*_default|crive-.*-default|crive-stack_default' | head -n1 || true)
    [[ -n "$NET" ]] && NET_ARG="--network $NET"
  fi
fi

DBURL_HOSTED="$DATABASE_URL"
if [[ -z "$NET_ARG" ]]; then
  PORT=$(echo "$DATABASE_URL" | sed -nE 's#.*://[^:/?]+:([0-9]+).*#\1#p'); [[ -z "$PORT" ]] && PORT=5432
  DBURL_HOSTED=$(echo "$DATABASE_URL" | sed -E "s#(://)[^:/?]+(:?[0-9]+)?#\1host.docker.internal:${PORT}#")
fi

docker run --rm $NET_ARG \
  -e DATABASE_URL="$DBURL_HOSTED" \
  -v "$WORK":/work -w /work node:20-bullseye bash -lc '
    set -euo pipefail
    npm i pg@8 --no-audit --no-fund --silent
    node db/scripts/migrate.cjs status
    node db/scripts/migrate.cjs up
  '
