BEGIN;

-- Pastikan ada unique constraint di name (aman jika sudah ada)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'tiers_name_key'
  ) THEN
    ALTER TABLE tiers ADD CONSTRAINT tiers_name_key UNIQUE (name);
  END IF;
END$$;

-- Seed by name (tanpa kolom id), id akan auto-UUID
INSERT INTO tiers (name, point_multiplier) VALUES
  ('Free',    1),
  ('Premium', 2),
  ('Expert',  3)
ON CONFLICT (name) DO UPDATE
  SET point_multiplier = EXCLUDED.point_multiplier;

COMMIT;
