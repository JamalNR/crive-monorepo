# apps/api/Dockerfile
FROM node:20-alpine

WORKDIR /workspace
RUN corepack enable && corepack prepare pnpm@9 --activate

# 1) Bawa manifest supaya cache install stabil
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY packages/shared/package.json packages/shared/
COPY apps/api/package.json apps/api/

# 2) Install workspace (butuh dev deps buat tsc)
RUN pnpm -r install --no-frozen-lockfile

# 3) Bawa seluruh source
COPY . .

# 4) Pastikan @crive/shared punya node_modules + build setelah COPY
RUN pnpm -r --filter @crive/shared install --no-frozen-lockfile \
 && pnpm -r --filter @crive/shared build

# 5) Jalankan API
WORKDIR /workspace/apps/api
EXPOSE 4000
CMD ["node", "./src/index.mjs"]
