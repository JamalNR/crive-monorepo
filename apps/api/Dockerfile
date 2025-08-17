# apps/api/Dockerfile
FROM node:20-alpine

WORKDIR /workspace
RUN corepack enable && corepack prepare pnpm@9 --activate

# salin seluruh monorepo
COPY . .

# install deps monorepo
RUN pnpm install --no-frozen-lockfile

# build lib yang dipakai API (wajib agar ada dist/)
RUN pnpm --filter @crive/shared build

# jalankan API
WORKDIR /workspace/apps/api
EXPOSE 4000
CMD ["node", "./src/index.mjs"]
