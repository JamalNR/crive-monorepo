# Crive — Schema Migration System (LOCK-ready)

Status: **Starter — Full Native**

## Nama & Struktur
- Direktori: `db/migrations/`
- Pola nama: `{timestamp}__{desc}.up.sql` dan `{timestamp}__{desc}.down.sql`
- Timestamp: `YYYYMMDDHHMMSS` (UTC)
- Template berada di `db/migrations/templates/`

## Versi & Locking
- Tabel kontrol: `schema_migrations(version TEXT PRIMARY KEY, checksum TEXT NOT NULL, applied_at TIMESTAMPTZ DEFAULT now(), applied_by TEXT, duration_ms INTEGER, no_transaction BOOLEAN DEFAULT FALSE)`
- Lock concurrency: `pg_advisory_lock(hashtext('crive_schema_migration'))`

## Aturan Expand–Contract (Ringkas)
1. **Expand**: tambah kolom/tabel baru dengan default/nullable yang aman.
2. **Backfill**: isi data bertahap via job batch.
3. **Contract**: ganti pembacaan aplikasi → kolom/struktur baru (feature-flagged), lalu baru drop kolom lama pada rilis berikutnya.

## Direktif Khusus di File SQL
Tambahkan di baris pertama bila diperlukan:
- `-- @transaction off` → migrasi dijalankan di luar transaksi (wajib untuk `CREATE INDEX CONCURRENTLY`, dll).

## Perintah NPM (disarankan di root repo)
- `pnpm db:migrate:status` → tampilkan status migrasi
- `pnpm db:migrate:dry` → simulasi (tidak menulis apa pun)
- `pnpm db:migrate:up` → jalankan semua `.up.sql` yang belum terpasang
- `pnpm db:migrate:down -- <n>` → rollback `<n>` langkah

## ENV yang dipakai
- `DATABASE_URL` (wajib) — via **Doppler** config `prd`/`stg`/`dev`
- `MIGRATIONS_DIR` (opsional) default: `db/migrations`

## DoD (Schema Migration System — 20 butir)
- Tool & konvensi terkunci, versi & locking, kebijakan expand–contract, non-destruktif, backfill batch, validasi lokal, gate CI (dry-run), autopilot staging, manual gate produksi, rollback plan, observability (log/durasi), review DBA/Dev, indeks & FK terukur, kompatibilitas versi (docs), feature-flag skema (stub), audit checksum, runbook insiden, template migrasi, review berkala.
