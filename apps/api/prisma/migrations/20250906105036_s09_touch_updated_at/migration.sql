-- function pemutakhiran kolom updated_at
CREATE OR REPLACE FUNCTION touch_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$;

-- helper: buat trigger jika kolom updated_at ada
DO $$
BEGIN
  -- users
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='users' AND column_name='updated_at') THEN
    DROP TRIGGER IF EXISTS trg_users_touch_updated_at ON "users";
    CREATE TRIGGER trg_users_touch_updated_at
      BEFORE UPDATE ON "users"
      FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
  END IF;

  -- tiers
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='tiers' AND column_name='updated_at') THEN
    DROP TRIGGER IF EXISTS trg_tiers_touch_updated_at ON "tiers";
    CREATE TRIGGER trg_tiers_touch_updated_at
      BEFORE UPDATE ON "tiers"
      FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
  END IF;

  -- contents
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='contents' AND column_name='updated_at') THEN
    DROP TRIGGER IF EXISTS trg_contents_touch_updated_at ON "contents";
    CREATE TRIGGER trg_contents_touch_updated_at
      BEFORE UPDATE ON "contents"
      FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
  END IF;

  -- reward_history
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='reward_history' AND column_name='updated_at') THEN
    DROP TRIGGER IF EXISTS trg_reward_history_touch_updated_at ON "reward_history";
    CREATE TRIGGER trg_reward_history_touch_updated_at
      BEFORE UPDATE ON "reward_history"
      FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
  END IF;

  -- wallet_ledger
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='wallet_ledger' AND column_name='updated_at') THEN
    DROP TRIGGER IF EXISTS trg_wallet_ledger_touch_updated_at ON "wallet_ledger";
    CREATE TRIGGER trg_wallet_ledger_touch_updated_at
      BEFORE UPDATE ON "wallet_ledger"
      FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
  END IF;
END $$;
