FROM node:20-alpine
WORKDIR /workspace
RUN corepack enable && corepack prepare pnpm@9 --activate

# Install manifest dulu (untuk cache stabil)
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY packages/shared/package.json packages/shared/
COPY apps/api/package.json apps/api/

# Install seluruh workspace (node_modules tersedia)
RUN pnpm -r install --no-frozen-lockfile

# Salin seluruh source
COPY . .

# Pastikan @crive/shared ter-install & build (JANGAN pnpm -r build)
RUN pnpm -r --filter @crive/shared install --no-frozen-lockfile \
 && pnpm -r --filter @crive/shared run build

# Jalankan API
WORKDIR /workspace/apps/api
EXPOSE 4000
CMD ["node","./src/index.mjs"]
