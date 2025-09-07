-- @transaction on
-- Template: add column safe (expand → backfill → enforce)
-- 1) expand
ALTER TABLE __TABLE__ ADD COLUMN __COLUMN__ __TYPE__ DEFAULT __DEFAULT__;
-- 2) backfill (opsional di job terpisah untuk skala besar)
-- UPDATE __TABLE__ SET __COLUMN__ = __DEFAULT__ WHERE __COLUMN__ IS NULL;
-- 3) enforce (rilis berikutnya)
-- ALTER TABLE __TABLE__ ALTER COLUMN __COLUMN__ SET NOT NULL;
