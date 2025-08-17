FROM node:20-alpine
WORKDIR /workspace
RUN corepack enable && corepack prepare pnpm@9 --activate
COPY . .
RUN pnpm install --no-frozen-lockfile
RUN pnpm -w --filter "@crive/shared" run build

WORKDIR /workspace/apps/api
EXPOSE 4000
CMD ["node","./src/index.mjs"]
