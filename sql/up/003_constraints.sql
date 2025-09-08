-- 003_constraints.sql
BEGIN;

-- Jaga updated_at auto-update
CREATE OR REPLACE FUNCTION touch_updated_at() RETURNS trigger AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tg_users_touch') THEN
    CREATE TRIGGER tg_users_touch BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tg_contents_touch') THEN
    CREATE TRIGGER tg_contents_touch BEFORE UPDATE ON contents
    FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'tg_tiers_touch') THEN
    CREATE TRIGGER tg_tiers_touch BEFORE UPDATE ON tiers
    FOR EACH ROW EXECUTE PROCEDURE touch_updated_at();
  END IF;
END $$;

COMMIT;
