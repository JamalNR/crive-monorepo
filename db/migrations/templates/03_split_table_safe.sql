-- @transaction on
-- Template: split table safe
-- 1) create new table
CREATE TABLE __NEW_TABLE__ (
  id BIGSERIAL PRIMARY KEY,
  __COLUMNS__
);
-- 2) backfill
-- INSERT INTO __NEW_TABLE__(...) SELECT ... FROM __OLD_TABLE__ ...;
-- 3) FK + index (concurrently if large)
-- 4) contract (hapus kolom/ganti relasi di rilis berikutnya)
