#!/usr/bin/env bash
set -Eeuo pipefail

: "${DATABASE_URL:?DATABASE_URL not set}"

cd ~/.crive-migs/work

# Join network jika disediakan
NET_ARG=()
if [[ -n "${DOCKER_NETWORK:-}" ]] && docker network ls --format '{{.Name}}' | grep -qx "$DOCKER_NETWORK"; then
  NET_ARG=(--network "$DOCKER_NETWORK")
fi

# Bentuk ulang URL agar pasti bisa konek dari kontainer:
# - host -> host.docker.internal (biar bisa akses service host/compose)
# - sslmode=disable (hindari self-signed)
DB="$(node -e '
  const raw = process.env.DATABASE_URL;
  if (!raw) process.exit(10);
  const u = new URL(raw);
  if (!u.port) u.port = "5432";
  u.hostname = "host.docker.internal";
  u.searchParams.set("sslmode","disable");
  process.stdout.write(u.toString());
')"

docker run --rm "${NET_ARG[@]}" \
  --add-host=host.docker.internal:host-gateway \
  -e DATABASE_URL="$DB" \
  -v "$PWD":/work -w /work node:20-bullseye bash -lc '
    set -Eeuo pipefail
    npm i pg@8 --no-audit --no-fund --silent
    node db/scripts/migrate.cjs status
    node db/scripts/migrate.cjs up
  '
