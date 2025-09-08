#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL not set}"

WORK="$HOME/.crive-migs/work"
cd "$WORK"

NET_ARG=""
EXTRA_HOST=""
DBURL_HOSTED="$DATABASE_URL"

# Coba join network stack/compose agar host "db" bisa resolve
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  if [[ -n "${DOCKER_NETWORK:-}" ]] && docker network ls --format '{{.Name}}' | grep -qx "${DOCKER_NETWORK}"; then
    NET_ARG="--network ${DOCKER_NETWORK}"
  else
    NET="$(docker ps --format '{{.Networks}}' | tr ' ' '\n' \
      | grep -E 'crive.*_default|crive-.*-default|crive-stack_default' | head -n1 || true)"
    [[ -n "$NET" ]] && NET_ARG="--network $NET"
  fi
fi

# Jika tidak join network -> pakai host.docker.internal (Linux butuh host-gateway)
if [[ -z "$NET_ARG" ]]; then
  EXTRA_HOST="--add-host=host.docker.internal:host-gateway"
  # Ganti hanya host di URL; kredensial/port/query tetap aman
  DBURL_HOSTED="$(printf '%s' "$DATABASE_URL" \
    | sed -E 's#^(postgresql?://([^@/]+@)?)[^/:?#]+#\1host.docker.internal#')"
fi

docker run --rm $NET_ARG $EXTRA_HOST \
  -e DATABASE_URL="$DBURL_HOSTED" \
  -v "$WORK":/work -w /work node:20-bullseye bash -lc '
    set -euo pipefail
    npm i pg@8 --no-audit --no-fund --silent
    node db/scripts/migrate.cjs status
    node db/scripts/migrate.cjs up
  '
