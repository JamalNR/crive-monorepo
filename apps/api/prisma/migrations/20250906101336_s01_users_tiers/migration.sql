-- S01: create tiers & users (idempotent-ish)
-- extension (untuk gen_random_uuid)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tabel tiers
CREATE TABLE IF NOT EXISTS "tiers" (
  "id"                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "code"                  TEXT NOT NULL UNIQUE,
  "name"                  TEXT NOT NULL,
  "point_multiplier"      NUMERIC(10,2) NOT NULL,
  "limits"                JSONB,
  "active_users_estimate" INTEGER NOT NULL DEFAULT 0,
  "created_at"            TIMESTAMP(3) NOT NULL DEFAULT NOW(),
  "updated_at"            TIMESTAMP(3) NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS "tiers_code_idx" ON "tiers" ("code");

-- Tabel users
CREATE TABLE IF NOT EXISTS "users" (
  "id"             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "username"       TEXT NOT NULL UNIQUE,
  "email"          TEXT NOT NULL UNIQUE,
  "password_hash"  TEXT NOT NULL,
  "referral_code"  TEXT,
  "bio"            TEXT,
  "avatar_url"     TEXT,
  "tier_id"        UUID,
  "created_at"     TIMESTAMP(3) NOT NULL DEFAULT NOW(),
  "updated_at"     TIMESTAMP(3) NOT NULL DEFAULT NOW(),
  "last_login_at"  TIMESTAMP(3),
  CONSTRAINT "users_tier_fk"
    FOREIGN KEY ("tier_id") REFERENCES "tiers"("id")
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS "users_tier_id_idx" ON "users" ("tier_id");
