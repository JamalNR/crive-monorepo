-- 001_drop_all_core.sql
BEGIN;

DROP TABLE IF EXISTS reward_history CASCADE;
DROP TABLE IF EXISTS wallet_ledger CASCADE;
DROP TABLE IF EXISTS contents CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS tiers CASCADE;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_type t WHERE t.typname = 'wallet_entry_type') THEN
    DROP TYPE wallet_entry_type;
  END IF;
END $$;

COMMIT;
