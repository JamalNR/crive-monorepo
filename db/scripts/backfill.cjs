#!/usr/bin/env node
/**
 * Crive Backfill Runner (CommonJS)
 * Example: node db/scripts/backfill.cjs contents.status_fill
 */
const { Client } = require('pg');

const DATABASE_URL = process.env.DATABASE_URL;
if (!DATABASE_URL) {
  console.error('✖ DATABASE_URL is required.');
  process.exit(2);
}

const job = (process.argv[2] || '').toLowerCase();
if (!job) {
  console.error('Usage: backfill.cjs <jobName>');
  process.exit(1);
}

async function run() {
  const client = new Client({ connectionString: DATABASE_URL });
  await client.connect();
  try {
    let lastId = 0;
    const batch = 1000;
    let total = 0;
    for (;;) {
      const res = await client.query(
        `SELECT id FROM contents WHERE id > $1 ORDER BY id ASC LIMIT $2`, [lastId, batch]
      );
      if (res.rows.length === 0) break;
      const ids = res.rows.map(r => r.id);
      lastId = ids[ids.length - 1];
      await client.query('BEGIN');
      // Example backfill: ensure status not null → set to "pending"
      await client.query(`UPDATE contents SET status = 'pending' WHERE id = ANY ($1) AND status IS NULL`, [ids]);
      await client.query('COMMIT');
      total += ids.length;
      process.stdout.write(`Processed ${total} rows\r`);
    }
    console.log(`\nDone. Total: ${total}`);
  } catch (e) {
    try { await client.query('ROLLBACK'); } catch {}
    console.error('Backfill error:', e.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}
run();
