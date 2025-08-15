# syntax=docker/dockerfile:1.7
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm" PATH="$PNPM_HOME:$PATH"
RUN corepack enable && adduser -D -u 10001 appuser
WORKDIR /app

# ---- dev ----
FROM base AS dev
COPY pnpm-workspace.yaml package.json .npmrc* ./
COPY apps/api/package.json apps/api/
COPY packages/shared/package.json packages/shared/
RUN pnpm install
COPY . .
EXPOSE 4000
USER appuser
CMD ["pnpm","-w","--filter","@crive/api","dev"]

# ---- build (prod) ----
FROM base AS build
COPY . .
RUN pnpm install && pnpm -r run build

# ---- runtime (prod) ----
FROM node:22-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /app /app
EXPOSE 4000
USER node
CMD ["node","apps/api/src/index.mjs"]
