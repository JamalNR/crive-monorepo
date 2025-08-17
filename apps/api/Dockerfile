# apps/api/Dockerfile
FROM node:20-alpine

WORKDIR /workspace
RUN corepack enable && corepack prepare pnpm@9 --activate

# 1) Bawa manifest supaya cache install stabil
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY packages/shared/package.json packages/shared/
COPY apps/api/package.json apps/api/

# Tambahkan sebelum build command
RUN pnpm install --frozen-lockfile --prefer-frozen-lockfile

# Debug build
RUN pnpm --filter @crive/shared build --reporter=verbose

# 3) Bawa seluruh source
COPY . .

# 4) Pastikan @crive/shared punya node_modules + build setelah COPY
RUN pnpm --filter @crive/shared build || (echo "Build failed, checking logs..." && exit 1)

# 5) Jalankan API
WORKDIR /workspace/apps/api
EXPOSE 4000
CMD ["node", "./src/index.mjs"]
