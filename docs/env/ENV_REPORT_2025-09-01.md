# ENV Report – 2025-09-01

## apps/api

| Key | Type | Source | Notes |
|-----|------|--------|-------|
| API_JWT_SECRET | secret | Doppler(prd) | runtime injection |
| CORS_ORIGIN | secret | Doppler(prd) | runtime injection |
| DATABASE_URL | secret | Doppler(prd) | runtime injection |
| LOG_LEVEL | secret | Doppler(prd) | runtime injection |
| NODE_ENV | secret | Doppler(prd) | runtime injection |
| PORT | secret | Doppler(prd) | runtime injection |

## apps/admin

| Key | Type | Source | Notes |
|-----|------|--------|-------|
| NEXT_PUBLIC_API_URL | non-secret | repo(.env.example) | public var |

Sumber: docs/ENV_CATALOG.md, Doppler (project=crive, config=prd)
