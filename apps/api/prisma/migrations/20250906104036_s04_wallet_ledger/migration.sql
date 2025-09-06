-- Enums (idempoten)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname='EntryType') THEN
    CREATE TYPE "EntryType" AS ENUM ('credit','debit');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname='LedgerReason') THEN
    CREATE TYPE "LedgerReason" AS ENUM ('poinmate_claim','content_reward','adjustment','withdrawal');
  END IF;
END $$;

-- Tabel
CREATE TABLE IF NOT EXISTS "wallet_ledger" (
  "id"           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id"      UUID NOT NULL,
  "entry_type"   "EntryType" NOT NULL,
  "amount"       INT NOT NULL,
  "reason"       "LedgerReason" NOT NULL,
  "reference_id" TEXT,
  "created_at"   TIMESTAMP(3) NOT NULL DEFAULT NOW(),
  "updated_at"   TIMESTAMP(3) NOT NULL DEFAULT NOW(),
  CONSTRAINT "wallet_ledger_user_fk"
    FOREIGN KEY ("user_id") REFERENCES "users"("id")
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS "wallet_ledger_user_created_idx"
  ON "wallet_ledger" ("user_id","created_at" DESC);
CREATE INDEX IF NOT EXISTS "wallet_ledger_reason_idx"
  ON "wallet_ledger" ("reason");
CREATE INDEX IF NOT EXISTS "wallet_ledger_reference_idx"
  ON "wallet_ledger" ("reference_id");

-- CHECK: amount >= 0
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='wallet_ledger_amount_ge0') THEN
    ALTER TABLE "wallet_ledger"
      ADD CONSTRAINT wallet_ledger_amount_ge0 CHECK (amount >= 0);
  END IF;
END $$;
