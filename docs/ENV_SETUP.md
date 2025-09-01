# ENV Setup (Dev Onboarding)
1) Salin `.env.example` menjadi `.env`.
2) Isi semua baris bertanda `# REQUIRED`.
3) Jangan commit `.env`; rahasia prd/stg diatur via Doppler.
4) Jalankan `pnpm -w run check:env:local` untuk memverifikasi.
