-- @transaction on
-- Template: rename safe (expand → dual write → switch → drop)
-- 1) expand
ALTER TABLE __TABLE__ ADD COLUMN __NEW__ __TYPE__;
-- 2) backfill
-- UPDATE __TABLE__ SET __NEW__ = __OLD__ WHERE __NEW__ IS NULL;
-- 3) app switch via feature flag (dual-read/write → read new only)
-- 4) contract
-- ALTER TABLE __TABLE__ DROP COLUMN __OLD__;
