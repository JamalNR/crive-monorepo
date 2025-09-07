# MIGRATION_POLICY.md — Expand–Contract (LOCK)

> Tujuan: **Zero/Low-Downtime** untuk PostgreSQL.

1) **Tambah (Expand)**  
   - Kolom baru ⇒ `NULLABLE + DEFAULT` aman.  
   - Hindari `DROP` di rilis yang sama.
2) **Backfill**  
   - Jalankan batch ukuran kecil (mis. 1k/loop), dengan `LIMIT/OFFSET` atau kursor idempotent.  
   - Retri aman; catat watermark `last_id/updated_at`.
3) **Alihkan Aplikasi**  
   - Gunakan feature flag (lihat `featureFlags/schema.ts`) agar aplikasi baca/tulis ke kolom/struktur baru.
4) **Bersihkan (Contract)**  
   - Pastikan metrik error/latensi stabil ≥ 48 jam; baru lakukan `DROP` pada rilis berikutnya.
5) **Indeks**  
   - Gunakan `CREATE INDEX CONCURRENTLY` (di luar transaksi) untuk produksi.
6) **Constraint**  
   - Tambah `CHECK/UNIQUE/FK` setelah data bersih, atau gunakan validasi `NOT VALID` lalu `VALIDATE`.
7) **Rollback**  
   - Sediakan **.down.sql** yang nyata dan aman; lampirkan catatan risiko.
