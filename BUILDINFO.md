# Reproducible Build
- Node: `cat .nvmrc`, pnpm: `packageManager` di package.json.
- Install: `pnpm install --frozen-lockfile --ignore-scripts`.
- Build: `pnpm -w run build`.
- Hasil harus deterministik (hash sama) bila input sama.
