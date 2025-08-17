# apps/api/Dockerfile
FROM node:20-alpine

# Pakai pnpm via corepack
RUN corepack enable && corepack prepare pnpm@9 --activate

# Kerja di root monorepo
WORKDIR /workspace

# Salin seluruh repo (gunakan .dockerignore utk node_modules/dll)
COPY . .

# Install deps di root workspace
RUN pnpm -w install --no-frozen-lockfile

# Build lib yang dipakai API (agar ada /packages/shared/dist)
RUN pnpm -w --filter "@crive/shared" run build

# Jalankan API
WORKDIR /workspace/apps/api
EXPOSE 4000
ENV PORT=4000 HOST=0.0.0.0

CMD ["node", "./src/index.mjs"]
