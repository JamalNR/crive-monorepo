# DB_MIGRATION_INCIDENT.md — Runbook Insiden

1. **Deteksi**: Build/CD gagal atau error saat `migrate:up` → catat versi terakhir & file yang gagal.
2. **Pause**: Nonaktifkan job migrasi lanjutan; pastikan tidak ada eksekusi paralel (advisory lock).
3. **Diagnosis Cepat**:
   - Periksa log: `duration_ms`, statement terakhir, error code.
   - Cek apakah ada transaction off (index concurrently) yang bentrok.
4. **Respon**:
   - Jika sebagian statement sudah jalan → jalankan **.down.sql** spesifik (atau patch forward) sesuai catatan risiko.
   - Kembalikan aplikasi ke state aman (feature flags).
5. **Komunikasi**: Update channel ops (ChatOps) dengan ringkas (versi, sebab, mitigasi).
6. **Pascainsiden**: RCA singkat + perbaikan template/test agar kejadian serupa tidak terulang.
