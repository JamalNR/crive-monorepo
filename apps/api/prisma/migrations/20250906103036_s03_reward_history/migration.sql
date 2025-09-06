CREATE TABLE IF NOT EXISTS "reward_history" (
  "id"              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id"         UUID NOT NULL,
  "source"          TEXT NOT NULL,
  "points"          INT  NOT NULL,
  "claimed_at"      TIMESTAMP(3) NOT NULL DEFAULT NOW(),
  "idempotency_key" TEXT NOT NULL,
  "meta"            JSONB,
  "created_at"      TIMESTAMP(3) NOT NULL DEFAULT NOW(),
  "updated_at"      TIMESTAMP(3) NOT NULL DEFAULT NOW(),
  CONSTRAINT "reward_history_user_fk"
    FOREIGN KEY ("user_id") REFERENCES "users"("id")
    ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS "reward_history_user_claimed_idx"
  ON "reward_history" ("user_id","claimed_at" DESC);
CREATE INDEX IF NOT EXISTS "reward_history_source_idx"
  ON "reward_history" ("source");
CREATE UNIQUE INDEX IF NOT EXISTS "reward_history_idempotency_key_key"
  ON "reward_history" ("idempotency_key");
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='reward_history_points_ge0') THEN
    ALTER TABLE "reward_history"
      ADD CONSTRAINT reward_history_points_ge0 CHECK (points >= 0);
  END IF;
END $$;
