# CRIVE — ENV CATALOG (Canonical)
Status: akan LOCK & FINAL setelah disetujui

## Format Kolom
NAME | PURPOSE | OWNER | ENV(dev/stg/prod) | DEFAULT | SECRET? | SOURCE | ROTATION | LAST_REVIEW | NOTES

## Layanan: API (Node.js)
NAME | PURPOSE | OWNER | ENV | DEFAULT | SECRET? | SOURCE | ROTATION | LAST_REVIEW | NOTES
API_PORT | Port service API | Backend | dev/stg/prod | 4000 | no | Compose/K8s | - | 2025-08-28 |
NODE_ENV | Mode runtime | Backend | dev/stg/prod | prod | no | Runtime | - | 2025-08-28 |
DATABASE_URL | Koneksi DB | Backend | dev/stg/prod |  | yes | SecretsMgr/GHA | 90d | 2025-08-28 | postgres://…
REDIS_URL | Koneksi Redis | Backend | dev/stg/prod |  | yes | SecretsMgr/GHA | 90d | 2025-08-28 |
JWT_SECRET | Secret JWT | Backend | dev/stg/prod |  | yes | SecretsMgr/GHA | 90d | 2025-08-28 | ≥32 chars
JWT_EXPIRES_IN | TTL token | Backend | dev/stg/prod | 15m | no | Runtime | - | 2025-08-28 |
RATE_LIMIT_WINDOW_MS | Window RL | Backend | dev/stg/prod | 60000 | no | Runtime | - | 2025-08-28 |
RATE_LIMIT_MAX | Max req/window | Backend | dev/stg/prod | 100 | no | Runtime | - | 2025-08-28 |
OPENAI_API_KEY | OpenAI key | Backend | dev/stg/prod |  | yes | SecretsMgr/GHA | 90d | 2025-08-28 |
TURNSTILE_SECRET_KEY | Turnstile secret | Backend | dev/stg/prod |  | yes | SecretsMgr/GHA | 90d | 2025-08-28 |
MIDTRANS_SERVER_KEY | Midtrans server | Backend | stg/prod |  | yes | SecretsMgr/GHA | 90d | 2025-08-28 |
MIDTRANS_CLIENT_KEY | Midtrans client | Backend | stg/prod |  | yes | SecretsMgr/GHA | 90d | 2025-08-28 |
S3_ENDPOINT | S3 endpoint | Backend | dev/stg/prod |  | no | Runtime | - | 2025-08-28 |
S3_BUCKET | Nama bucket | Backend | dev/stg/prod | crive | no | Runtime | - | 2025-08-28 |
S3_ACCESS_KEY_ID | Kunci S3 | Backend | dev/stg/prod |  | yes | SecretsMgr/GHA | 180d | 2025-08-28 |
S3_SECRET_ACCESS_KEY | Secret S3 | Backend | dev/stg/prod |  | yes | SecretsMgr/GHA | 180d | 2025-08-28 |
OTEL_EXPORTER_OTLP_ENDPOINT | OTLP endpoint | DevOps | stg/prod |  | no | Runtime | - | 2025-08-28 |
LOG_LEVEL | Level log | Backend | dev/stg/prod | info | no | Runtime | - | 2025-08-28 |

## Layanan: WEB (Next.js)
NAME | PURPOSE | OWNER | ENV | DEFAULT | SECRET? | SOURCE | ROTATION | LAST_REVIEW | NOTES
PORT | Port web | Frontend | dev/stg/prod | 3000 | no | Compose/K8s | - | 2025-08-28 |
NODE_ENV | Mode runtime | Frontend | dev/stg/prod | prod | no | Runtime | - | 2025-08-28 |
NEXT_PUBLIC_APP_URL | Base URL app | Frontend | dev/stg/prod |  | no | Runtime | - | 2025-08-28 | https://crive.app
NODE_ENV | Mode runtime | Backend/Frontend | dev/stg/prod | prod | no | Runtime | - | 2025-08-28 |
NEXT_PUBLIC_API_URL | Base URL API | Frontend | dev/stg/prod | https://api.crive.app | no | Runtime | - | 2025-08-28 |
NEXT_TELEMETRY_DISABLED | Matikan telemetry Next | Frontend | dev/stg/prod | 1 | no | Runtime | - | 2025-08-28 |
NEXT_PUBLIC_API_BASE_URL | Base URL API | Frontend | dev/stg/prod |  | no | Runtime | - | 2025-08-28 | https://api.crive.app
NEXT_TELEMETRY_DISABLED | Matikan telemetry | Frontend | dev/stg/prod | 1 | no | Runtime | - | 2025-08-28 |
TURNSTILE_SITE_KEY | Turnstile public | Frontend | dev/stg/prod |  | yes* | Build inject | 90d | 2025-08-28 |

## Layanan: DEPLOY/OPS
NAME | PURPOSE | OWNER | ENV | DEFAULT | SECRET? | SOURCE | ROTATION | LAST_REVIEW | NOTES
CERTBOT_EMAIL | Email ACME | DevOps | stg/prod |  | no | Host | - | 2025-08-28 |
DEPLOY_REGISTRY | Registry image | DevOps | stg/prod | ghcr.io | no | Host | - | 2025-08-28 |
DEPLOY_NAMESPACE | Namespace image | DevOps | stg/prod | jamalnr | no | Host | - | 2025-08-28 |

## Layanan: TOOLING / CI
COREPACK_ENABLE_DOWNLOAD_PROMPT | Kontrol prompt unduh Corepack | DevOps | dev | 0 | no | CI/Local Runtime | - | 2025-08-28 | set 0 agar non-interaktif

## Prosedur Update & Audit
1) Perubahan ENV → update tabel ini (wajib).  
2) Setiap rilis besar → audit + ubah LAST_REVIEW.  
3) Secret tidak pernah ditulis di repo.

## Change Log
- 2025-08-28: Draft awal ENV katalog.
