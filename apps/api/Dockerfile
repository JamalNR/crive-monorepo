FROM node@sha256:eabac870db94f7342d6c33560d6613f188bbcf4bbe1f4eb47d5e2a08e1a37722
WORKDIR /workspace
RUN corepack enable && corepack prepare pnpm@9 --activate

# Manifest untuk cache
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY packages/shared/package.json packages/shared/
COPY apps/api/package.json apps/api/

# Install semua workspace
RUN pnpm -r install --no-frozen-lockfile

# Bawa seluruh source
COPY . .

# Pastikan @crive/shared ter-install & build (tanpa pnpm -r build)
RUN pnpm -r --filter @crive/shared install --no-frozen-lockfile \
 && pnpm -r --filter @crive/shared run build

# Jalankan API
WORKDIR /workspace/apps/api
EXPOSE 4000
CMD ["node","./src/index.mjs"]
