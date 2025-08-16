# apps/api/Dockerfile
FROM node:20-alpine

WORKDIR /workspace
# pnpm dari corepack (lebih stabil di Node 20)
RUN corepack enable && corepack prepare pnpm@9 --activate

# Salin seluruh repo (kita sudah punya .dockerignore untuk membatasi context)
COPY . .

# Install dependensi tanpa strict lockfile agar tidak blok
RUN pnpm install --no-frozen-lockfile

# Opsional: build kalau apps/api punya script build
# RUN pnpm --filter ./apps/api build || true

# Jalankan API
WORKDIR /workspace/apps/api
EXPOSE 4000
CMD ["pnpm","start"]
# Jika belum ada "start", ganti ke:
# CMD ["pnpm","dev"]
