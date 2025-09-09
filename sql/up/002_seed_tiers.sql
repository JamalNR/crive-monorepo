BEGIN;

-- pastikan unique di code (aman bila sudah ada)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'tiers_code_key'
  ) THEN
    ALTER TABLE tiers ADD CONSTRAINT tiers_code_key UNIQUE (code);
  END IF;
END$$;

-- seed idempotent: gunakan code + upsert
INSERT INTO tiers (code, name, point_multiplier) VALUES
  ('free',    'Free',    1),
  ('premium', 'Premium', 2),
  ('expert',  'Expert',  3)
ON CONFLICT (code) DO UPDATE
  SET name = EXCLUDED.name,
      point_multiplier = EXCLUDED.point_multiplier;

COMMIT;
