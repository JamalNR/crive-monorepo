# apps/api/Dockerfile
FROM node:20-alpine

WORKDIR /workspace
RUN corepack enable && corepack prepare pnpm@9 --activate

# Salin manifest dulu (biar cache rapi)
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY packages/shared/package.json packages/shared/
COPY apps/api/package.json apps/api/

# Install semua deps workspace (termasuk dev) secara rekursif
RUN pnpm -r install --no-frozen-lockfile

# Baru salin seluruh repo
COPY . .

# Build library shared yang dipakai API
RUN pnpm -r --filter @crive/shared build

# Jalankan API (pakai source)
WORKDIR /workspace/apps/api
EXPOSE 4000
CMD ["node", "./src/index.mjs"]
