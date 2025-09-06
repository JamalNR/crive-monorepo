-- S02: create contents (with enums & indexes)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'Visibility') THEN
    CREATE TYPE "Visibility" AS ENUM ('public','private');
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ModerationStatus') THEN
    CREATE TYPE "ModerationStatus" AS ENUM ('pending','ok','flagged');
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS "contents" (
  "id"                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id"           UUID NOT NULL,
  "title"             TEXT NOT NULL,
  "body"              TEXT NOT NULL,
  "visibility"        "Visibility" NOT NULL,
  "moderation_status" "ModerationStatus" NOT NULL,
  "deleted_at"        TIMESTAMP(3),
  "created_at"        TIMESTAMP(3) NOT NULL DEFAULT NOW(),
  "updated_at"        TIMESTAMP(3) NOT NULL DEFAULT NOW(),
  CONSTRAINT "contents_user_fk"
    FOREIGN KEY ("user_id") REFERENCES "users"("id")
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS "contents_user_created_idx"
  ON "contents" ("user_id","created_at" DESC);
CREATE INDEX IF NOT EXISTS "contents_moderation_idx"
  ON "contents" ("moderation_status");
CREATE INDEX IF NOT EXISTS "contents_deleted_idx"
  ON "contents" ("deleted_at");
