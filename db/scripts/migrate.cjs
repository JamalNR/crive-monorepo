#!/usr/bin/env node
/**
 * Crive DB Migration Runner (CommonJS)
 * - Supports: up, down <n>, status, dry-run
 * - Versioning table: schema_migrations (version, checksum, applied_at, applied_by, duration_ms, no_transaction)
 * - Advisory lock to prevent parallel runs
 * - Directive: -- @transaction off  (first line) to run migration without BEGIN..COMMIT
 */
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { Client } = require('pg');

const MIGRATIONS_DIR = process.env.MIGRATIONS_DIR || path.join(process.cwd(), 'db', 'migrations');
const DATABASE_URL = process.env.DATABASE_URL;
if (!DATABASE_URL) {
  console.error('✖ DATABASE_URL is required.');
  process.exit(2);
}

const args = process.argv.slice(2);
const cmd = args[0] || 'status';
const downSteps = parseInt(args[1] || '1', 10);

function listMigrationPairs() {
  const files = fs.readdirSync(MIGRATIONS_DIR).filter(f => f.endsWith('.sql'));
  // Group by version (timestamp) + desc
  const map = new Map();
  for (const f of files) {
    const m = /^(\d{14})__([a-z0-9_-]+)\.(up|down)\.sql$/i.exec(f);
    if (!m) continue;
    const [ , version, desc, kind ] = m;
    const key = `${version}__${desc}`;
    if (!map.has(key)) map.set(key, { version, desc, up: null, down: null });
    map.get(key)[kind] = f;
  }
  // Sort by version asc
  return Array.from(map.values()).sort((a,b) => a.version.localeCompare(b.version));
}

function readSqlFile(fp) {
  const raw = fs.readFileSync(fp, 'utf8');
  const lines = raw.split(/\r?\n/);
  const firstLine = (lines[0] || '').trim();
  const noTx = firstLine.toLowerCase().includes('-- @transaction off');
  const sql = noTx ? lines.slice(1).join('\n') : raw;
  const checksum = crypto.createHash('sha256').update(raw).digest('hex');
  return { raw, sql, noTx, checksum };
}

async function ensureMeta(client) {
  await client.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      version TEXT PRIMARY KEY,
      checksum TEXT NOT NULL,
      applied_at TIMESTAMPTZ DEFAULT now(),
      applied_by TEXT,
      duration_ms INTEGER,
      no_transaction BOOLEAN DEFAULT FALSE
    )
  `);
}

async function withAdvisoryLock(client, fn) {
  const res = await client.query(`SELECT pg_try_advisory_lock(hashtext('crive_schema_migration')) AS ok`);
  if (!res.rows[0].ok) throw new Error('Could not acquire advisory lock (another migration running).');
  try {
    return await fn();
  } finally {
    await client.query(`SELECT pg_advisory_unlock(hashtext('crive_schema_migration'))`);
  }
}

async function getApplied(client) {
  const res = await client.query(`SELECT version, checksum FROM schema_migrations ORDER BY version ASC`);
  const map = new Map();
  for (const r of res.rows) map.set(r.version, r.checksum);
  return map;
}

function author() {
  return process.env['GITHUB_ACTOR'] || process.env['USER'] || 'unknown';
}

async function migrateUp(client, dryRun=false) {
  const pairs = listMigrationPairs();
  const applied = await getApplied(client);
  const plan = [];
  for (const p of pairs) {
    if (!p.up) continue;
    if (!applied.has(p.version)) plan.push(p);
  }

  if (plan.length === 0) {
    console.log('✓ No pending migrations.');
    return;
  }

  console.log(`→ Pending: ${plan.length} migration(s)`);

  for (const p of plan) {
    const upPath = path.join(MIGRATIONS_DIR, p.up);
    const { sql, checksum, noTx } = readSqlFile(upPath);
    const start = Date.now();
    process.stdout.write(`   • ${p.version}__${p.desc} ${noTx ? '[no-tx]' : ''} ... `);

    if (dryRun) {
      console.log('DRY-RUN');
      continue;
    }

    try {
      if (!noTx) await client.query('BEGIN');
      await client.query(sql);
      if (!noTx) await client.query('COMMIT');
      const dur = Date.now() - start;
      await client.query(
        `INSERT INTO schema_migrations(version, checksum, applied_by, duration_ms, no_transaction) VALUES ($1,$2,$3,$4,$5)`,
        [p.version, checksum, author(), dur, noTx]
      );
      console.log(`OK (${dur} ms)`);
    } catch (e) {
      if (!dryRun) {
        try { await client.query('ROLLBACK'); } catch {}
      }
      console.error('\n✖ Error:', e.message);
      throw e;
    }
  }
}

async function migrateDown(client, steps=1, dryRun=false) {
  const pairs = listMigrationPairs();
  const applied = await getApplied(client);
  const appliedList = pairs.filter(p => applied.has(p.version));
  if (appliedList.length === 0) {
    console.log('Nothing to rollback.');
    return;
  }
  const toRollback = appliedList.slice(-steps);
  for (const p of toRollback.reverse()) {
    if (!p.down) {
      console.log(`(skip) ${p.version}__${p.desc} — no .down.sql found`);
      continue;
    }
    const downPath = path.join(MIGRATIONS_DIR, p.down);
    const { sql, noTx } = readSqlFile(downPath);
    const start = Date.now();
    process.stdout.write(`   • DOWN ${p.version}__${p.desc} ${noTx ? '[no-tx]' : ''} ... `);
    if (!dryRun) {
      try {
        if (!noTx) await client.query('BEGIN');
        await client.query(sql);
        if (!noTx) await client.query('COMMIT');
        await client.query(`DELETE FROM schema_migrations WHERE version = $1`, [p.version]);
        const dur = Date.now() - start;
        console.log(`OK (${dur} ms)`);
      } catch (e) {
        try { await client.query('ROLLBACK'); } catch {}
        console.error('\n✖ Error:', e.message);
        throw e;
      }
    } else {
      console.log('DRY-RUN');
    }
  }
}

async function showStatus(client) {
  const pairs = listMigrationPairs();
  await ensureMeta(client);
  const res = await client.query(`SELECT version, applied_at, applied_by FROM schema_migrations ORDER BY version ASC`);
  const applied = new Set(res.rows.map(r => r.version));
  const rows = pairs.map(p => ({
    version: p.version,
    desc: p.desc,
    applied: applied.has(p.version)
  }));
  console.log(JSON.stringify(rows, null, 2));
}

(async () => {
  const client = new Client({ connectionString: DATABASE_URL });
  await client.connect();
  await ensureMeta(client);
  try {
    await withAdvisoryLock(client, async () => {
      if (cmd === 'up')       return migrateUp(client, false);
      if (cmd === 'dry')      return migrateUp(client, true);
      if (cmd === 'down')     return migrateDown(client, isNaN(downSteps)?1:downSteps, false);
      if (cmd === 'status')   return showStatus(client);
      console.log('Usage: migrate.cjs [status|up|down <n>|dry]');
    });
  } finally {
    await client.end();
  }
})().catch(err => {
  console.error('Migration failed:', err?.message || err);
  process.exit(1);
});
