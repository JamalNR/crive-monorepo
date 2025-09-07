## DB Migration Checklist

- [ ] File mengikuti pola `{timestamp}__desc.up.sql` (+ optional `.down.sql`)
- [ ] **Non-destruktif** (expand–contract); tidak ada `DROP` pada rilis yang sama
- [ ] `CREATE INDEX CONCURRENTLY` menggunakan `-- @transaction off`
- [ ] Disertai **rollback plan** (.down.sql) + catatan risiko
- [ ] Sudah lulus `pnpm db:migrate:dry` di CI
- [ ] Bila butuh backfill → siapkan job `db/scripts/backfill.cjs`
