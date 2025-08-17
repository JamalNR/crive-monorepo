FROM node:20-alpine

WORKDIR /workspace
RUN corepack enable && corepack prepare pnpm@9 --activate

# Bawa seluruh repo (node_modules diabaikan oleh .dockerignore)
COPY . .

# Install semua workspace + build semua (termasuk @crive/shared)
RUN pnpm -r install --no-frozen-lockfile
RUN pnpm -r build

# Jalankan API
WORKDIR /workspace/apps/api
EXPOSE 4000
CMD ["node","./src/index.mjs"]
