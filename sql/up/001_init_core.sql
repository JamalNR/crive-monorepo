-- 001_init_core.sql
-- Idempoten + fail-fast
BEGIN;

-- Extension (aman jika sudah ada)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enum untuk wallet_ledger
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    WHERE t.typname = 'wallet_entry_type'
  ) THEN
    CREATE TYPE wallet_entry_type AS ENUM ('credit', 'debit');
  END IF;
END $$;

-- TABEL: tiers
CREATE TABLE IF NOT EXISTS tiers (
  id            SERIAL PRIMARY KEY,
  code          TEXT UNIQUE NOT NULL,         -- FREE / PREMIUM / EXPERT
  name          TEXT NOT NULL,
  point_rate    INTEGER NOT NULL DEFAULT 1,   -- rate points baseline
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- TABEL: users
CREATE TABLE IF NOT EXISTS users (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email         TEXT UNIQUE NOT NULL,
  username      TEXT UNIQUE,
  password_hash TEXT,
  tier_id       INTEGER REFERENCES tiers(id) ON UPDATE CASCADE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_email CHECK (position('@' in email) > 1)
);

-- TABEL: contents
CREATE TABLE IF NOT EXISTS contents (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title         TEXT NOT NULL,
  body          TEXT,
  is_published  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- TABEL: wallet_ledger
CREATE TABLE IF NOT EXISTS wallet_ledger (
  id            BIGSERIAL PRIMARY KEY,
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  entry_type    wallet_entry_type NOT NULL,
  amount_pts    BIGINT NOT NULL CHECK (amount_pts > 0),
  ref           TEXT,                              -- referensi (content id / event)
  note          TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- TABEL: reward_history
CREATE TABLE IF NOT EXISTS reward_history (
  id            BIGSERIAL PRIMARY KEY,
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content_id    UUID REFERENCES contents(id) ON DELETE SET NULL,
  points        BIGINT NOT NULL CHECK (points >= 0),
  reason        TEXT NOT NULL,                     -- contoh: "publish" / "poinmate"
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indeks penting
CREATE INDEX IF NOT EXISTS idx_users_tier_id ON users(tier_id);
CREATE INDEX IF NOT EXISTS idx_contents_user_id ON contents(user_id);
CREATE INDEX IF NOT EXISTS idx_wallet_user_created ON wallet_ledger(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reward_user_created ON reward_history(user_id, created_at DESC);

COMMIT;
