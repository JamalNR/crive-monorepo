# COMPATIBILITY.md — Kompatibilitas Aplikasi

- Pastikan versi aplikasi lama & baru **kompatibel** selama masa rollout:
  - **Dual-read/dual-write** bila ada perubahan kolom/esemantik.
  - `featureFlags/schema.ts` mengontrol peralihan perilaku.
- Hindari perubahan kontrak API yang memaksa downtime.
- Uji **read-only** mode sebelum kontraksi (drop).