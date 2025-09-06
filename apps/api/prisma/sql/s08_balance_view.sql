-- View saldo per user (credit - debit)
CREATE OR REPLACE VIEW "v_user_balance" AS
SELECT
  u.id AS user_id,
  COALESCE(SUM(CASE WHEN wl.entry_type='credit' THEN wl.amount ELSE -wl.amount END), 0) AS balance
FROM users u
LEFT JOIN wallet_ledger wl ON wl.user_id = u.id
GROUP BY u.id;

-- Function helper untuk ambil saldo 1 user
CREATE OR REPLACE FUNCTION get_user_balance(p_user_id uuid)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(SUM(CASE WHEN wl.entry_type='credit' THEN wl.amount ELSE -wl.amount END), 0)::int
  FROM wallet_ledger wl
  WHERE wl.user_id = p_user_id;
$$;
