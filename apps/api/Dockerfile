# apps/api/Dockerfile
# syntax=docker/dockerfile:1

FROM node:20-alpine AS deps
WORKDIR /workspace
# aktifkan pnpm via corepack (lebih bersih daripada npm i -g pnpm)
RUN corepack enable && corepack prepare pnpm@9 --activate

# --- Salin file MANIFEST saja untuk cache install yang maksimal ---
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
COPY apps/api/package.json apps/api/package.json
# (opsional) kalau ada packages lain yang jadi dependency:
# COPY packages/shared/package.json packages/shared/package.json

# Install dependencies (workspace-aware)
RUN pnpm install --frozen-lockfile

# --- Runtime layer ---
FROM node:20-alpine AS runner
WORKDIR /workspace
# bawa hasil install dari layer deps
COPY --from=deps /workspace/node_modules ./node_modules
# bawa seluruh source (diperlukan saat run/build)
COPY . .

# masuk ke app API
WORKDIR /workspace/apps/api
EXPOSE 4000
# Gunakan "start" kalau ada, fallback ke "dev"
CMD ["pnpm","start"]
