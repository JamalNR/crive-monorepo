-- 002_seed_tiers.sql
BEGIN;

INSERT INTO tiers (code, name, point_rate) VALUES
  ('FREE', 'Free', 1),
  ('PREMIUM', 'Premium', 2),
  ('EXPERT', 'Expert', 3)
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  point_rate = EXCLUDED.point_rate,
  updated_at = NOW();

COMMIT;
