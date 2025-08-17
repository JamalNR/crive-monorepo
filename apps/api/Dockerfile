FROM node:20-alpine
WORKDIR /workspace
RUN corepack enable && corepack prepare pnpm@9 --activate
# install deps (workspace root)
RUN pnpm -w install --no-frozen-lockfile

# build lib shared (pastikan tsc dari workspace kebaca)
RUN pnpm -w --filter "@crive/shared" run build
