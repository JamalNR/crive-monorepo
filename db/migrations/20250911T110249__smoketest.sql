-- @up
DO $$ BEGIN RAISE NOTICE 'ci smoketest up'; END $$;

-- @down
DO $$ BEGIN RAISE NOTICE 'ci smoketest down'; END $$;
