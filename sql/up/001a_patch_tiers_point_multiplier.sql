DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'tiers' AND column_name = 'point_multiplier'
  ) THEN
    EXECUTE 'ALTER TABLE tiers ALTER COLUMN point_multiplier SET DEFAULT 1';
    EXECUTE 'UPDATE tiers SET point_multiplier = 1 WHERE point_multiplier IS NULL';
  END IF;
END $$;