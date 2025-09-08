#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL not set}"

WORK="$HOME/.crive-migs/work"
cd "$WORK"

NET_ARG=""
EXTRA_HOST=""
USE_HOST_INTERNAL=0

# Coba join ke network aplikasi (compose/stack)
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  if [[ -n "${DOCKER_NETWORK:-}" ]] && docker network ls --format '{{.Name}}' | grep -qx "${DOCKER_NETWORK}"; then
    NET_ARG="--network ${DOCKER_NETWORK}"
  else
    NET="$(docker ps --format '{{.Networks}}' | tr ' ' '\n' \
      | grep -E 'crive.*_default|crive-.*-default|crive-stack_default' | head -n1 || true)"
    [[ -n "$NET" ]] && NET_ARG="--network $NET"
  fi
fi

# Jika tidak join network, pakai host.docker.internal
if [[ -z "$NET_ARG" ]]; then
  EXTRA_HOST="--add-host=host.docker.internal:host-gateway"
  USE_HOST_INTERNAL=1
fi

docker run --rm $NET_ARG $EXTRA_HOST \
  -e ORIGINAL_DATABASE_URL="$DATABASE_URL" \
  -e USE_HOST_INTERNAL="$USE_HOST_INTERNAL" \
  -v "$WORK":/work -w /work node:20-bullseye bash -lc '
    set -euo pipefail

    # Bangun ulang URL di DALAM kontainer (Node tersedia di sini)
    FINAL_URL="$(node - <<'"'"'JS'"'"'
      const raw = process.env.ORIGINAL_DATABASE_URL || "";
      if (!raw) { console.error("NO_DBURL"); process.exit(3); }
      let url;
      try {
        // normalisasi skema bila ada "postgresql:"
        url = new URL(raw.replace(/^postgresql:/, "postgres:"));
      } catch (e) {
        console.error("BAD_DBURL:" + raw);
        process.exit(4);
      }
      if (process.env.USE_HOST_INTERNAL === "1") {
        if (!url.port) url.port = "5432";
        url.hostname = "host.docker.internal";
      }
      process.stdout.write(url.toString());
    JS
    )"

    export DATABASE_URL="$FINAL_URL"

    npm i pg@8 --no-audit --no-fund --silent
    node db/scripts/migrate.cjs status
    node db/scripts/migrate.cjs up
  '
