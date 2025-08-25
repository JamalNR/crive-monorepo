# syntax=docker/dockerfile:1.7
FROM node:20-alpine AS base
WORKDIR /workspace
RUN apk add --no-cache curl && corepack enable

FROM base AS deps
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
COPY apps/admin/package.json apps/admin/package.json
COPY packages/shared/package.json packages/shared/package.json
RUN pnpm install --frozen-lockfile

FROM deps AS build
COPY . .
RUN pnpm -C apps/admin build

FROM node:20-alpine AS runtime
WORKDIR /workspace
ENV NODE_ENV=production
ENV PORT=3000
RUN apk add --no-cache curl netcat-openbsd && npm i -g pnpm@9
RUN addgroup -S nodejs && adduser -S nodejs -G nodejs
COPY --from=deps  /workspace/node_modules     ./node_modules
COPY --from=build /workspace/apps/admin       ./apps/admin
COPY --from=build /workspace/packages/shared  ./packages/shared
USER nodejs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD nc -z 127.0.0.1 ${PORT} || exit 1
CMD ["pnpm","-C","apps/admin","start"]
