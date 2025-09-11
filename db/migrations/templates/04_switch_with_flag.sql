-- Contoh “switch” bergantung fitur flag
-- ganti my_feature_flag dgn nama flag anda
do $$
begin
  if exists (select 1 from feature_flags where key = 'my_feature_flag' and enabled)
  then
    -- switch e.g. update default, rename view, swap column read path, dll.
    raise notice 'switch executed under feature flag';
  else
    raise notice 'flag disabled; no-op';
  end if;
end$$;
-- @down
-- no-op (switch biasanya reversible via flag off)
