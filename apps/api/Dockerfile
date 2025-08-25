FROM node:20-alpine AS base
ENV PNPM_HOME="/pnpm" PATH="/pnpm:$PATH"
RUN corepack enable && corepack prepare pnpm@10.14.0 --activate && pnpm -v

FROM base AS builder
WORKDIR /workspace
RUN apk add --no-cache --virtual .build-deps python3 make g++ && apk add --no-cache git

COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY apps/api/package.json apps/api/
COPY packages/shared/package.json packages/shared/

# Install seluruh workspace
RUN pnpm -r install --no-frozen-lockfile

# Salin kode
COPY . .

# (opsional) Prisma generate
RUN if [ -f apps/api/prisma/schema.prisma ]; then pnpm --filter ./apps/api... prisma generate; fi

# Build: shared dulu -> baru API
RUN pnpm --filter @crive/shared... build
RUN pnpm --filter ./apps/api... build

# Deploy ramping utk API
RUN pnpm --filter ./apps/api... deploy --prod --legacy /out

FROM node:20-alpine AS runner
ENV NODE_ENV=production PORT=4000
WORKDIR /srv/api
RUN apk add --no-cache curl
RUN addgroup -S app && adduser -S app -G app
COPY --chown=app:app --from=builder /out/ /srv/api/
RUN find /srv/api -maxdepth 3 -type f -name package.json -not -path "*/node_modules/*" -delete
RUN find /srv/api -maxdepth 3 -type f -name package.json -not -path "*/node_modules/*" -delete
RUN find /srv/api -maxdepth 3 -type f -name package.json -not -path "*/node_modules/*" -delete
RUN find /srv/api -maxdepth 3 -type f -name package.json -not -path "*/node_modules/*" -delete
RUN find /srv/api -maxdepth 3 -type f -name package.json -not -path "*/node_modules/*" -delete
RUN find /srv/api -maxdepth 3 -type f -name package.json -not -path "*/node_modules/*" -delete

RUN printf '%s\n' '#!/bin/sh' \
  'set -e' \
  'if [ -f dist/server.js ]; then TARGET=dist/server.js;' \
  'elif [ -f dist/index.js ]; then TARGET=dist/index.js;' \
  'elif [ -f build/server.js ]; then TARGET=build/server.js;' \
  'else TARGET=${START_FILE:-dist/server.js}; fi' \
  'exec node "$TARGET"' > /usr/local/bin/start-api && chmod +x /usr/local/bin/start-api

USER app
EXPOSE 4000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -fsS http://127.0.0.1:${PORT}/healthz || exit 1
STOPSIGNAL SIGINT
CMD ["start-api"]
