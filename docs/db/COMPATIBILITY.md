# COMPATIBILITY.md — Kompatibilitas Aplikasi

- Pastikan versi aplikasi lama & baru **kompatibel** selama masa rollout:
  - **Dual-read/dual-write** bila ada perubahan kolom/esemantik.
  - `featureFlags/schema.ts` mengontrol peralihan perilaku.
- Hindari perubahan kontrak API yang memaksa downtime.
- Uji **read-only** mode sebelum kontraksi (drop).
# DB Compatibility Rules
- Expand first, contract later (min 1 rilis jeda).
- Larangan 1 rilis: DROP, SET NOT NULL, TYPE rewrite, VACUUM FULL.
- Indeks: gunakan `CONCURRENTLY`.
- FK: `NOT VALID` lalu `VALIDATE` di rilis berikutnya.
- Switch via `feature_flags`.
Bukti: linter `scripts/db/lint-migrations.sh` + contoh migrasi indeks/FK di `db/migrations/`.
