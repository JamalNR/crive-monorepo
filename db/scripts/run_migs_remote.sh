#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL not set}"

WORK="$HOME/.crive-migs/work"
cd "$WORK"

NET_ARG=""
EXTRA_HOST=""

# 1) Coba join ke network docker aplikasi (stg/prd)
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  if [[ -n "${DOCKER_NETWORK:-}" ]] && docker network ls --format '{{.Name}}' | grep -qx "${DOCKER_NETWORK}"; then
    NET_ARG="--network ${DOCKER_NETWORK}"
  else
    NET=$(docker ps --format '{{.Networks}}' | tr ' ' '\n' | \
          grep -E 'crive.*_default|crive-.*-default|crive-stack_default' | head -n1 || true)
    [[ -n "$NET" ]] && NET_ARG="--network $NET"
  fi
fi

# 2) Kalau TIDAK join network, ganti host ke host.docker.internal secara AMAN (pakai Node URL, bukan sed)
DBURL_HOSTED="$DATABASE_URL"
if [[ -z "$NET_ARG" ]]; then
  DBURL_HOSTED="$(env DATABASE_URL="$DATABASE_URL" node - <<'JS'
    const u = new URL(process.env.DATABASE_URL);
    if (!u.port) u.port = '5432';
    u.hostname = 'host.docker.internal';
    // pastikan query/sslmode dlsb tetap utuh
    process.stdout.write(u.toString());
JS
  )"
  EXTRA_HOST="--add-host=host.docker.internal:host-gateway"
fi

docker run --rm $NET_ARG $EXTRA_HOST \
  -e DATABASE_URL="$DBURL_HOSTED" \
  -v "$WORK":/work -w /work node:20-bullseye bash -lc '
    set -euo pipefail
    npm i pg@8 --no-audit --no-fund --silent
    node db/scripts/migrate.cjs status
    node db/scripts/migrate.cjs up
  '
