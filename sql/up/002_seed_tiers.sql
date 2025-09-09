BEGIN;

INSERT INTO tiers (id, name, point_multiplier)
VALUES
  ('free',    'Free',    1),
  ('premium', 'Premim',  2),
  ('expert',  'Expert',  3)
ON CONFLICT (id) DO UPDATE
SET
  name            = EXCLUDED.name,
  point_multiplier = EXCLUDED.point_multiplier;

COMMIT;


