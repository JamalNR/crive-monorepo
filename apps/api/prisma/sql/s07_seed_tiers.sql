INSERT INTO "tiers" ("code","name","point_multiplier","limits","active_users_estimate")
VALUES
  ('FREE',  'Free',  1.00, '{}'::jsonb, 0),
  ('PRO',   'Pro',   1.50, '{}'::jsonb, 0),
  ('ELITE', 'Elite', 2.00, '{}'::jsonb, 0)
ON CONFLICT ("code") DO UPDATE
SET
  "name"             = EXCLUDED."name",
  "point_multiplier" = EXCLUDED."point_multiplier",
  "limits"           = EXCLUDED."limits";
