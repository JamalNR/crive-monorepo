#!/usr/bin/env node
import { execFileSync, spawnSync } from 'node:child_process';
import { readdirSync, existsSync } from 'node:fs';
const DBURL = process.env.DATABASE_URL;
if (!DBURL) { console.error('DATABASE_URL required'); process.exit(1); }

function psqlArgs(extra=[]) { return ['-v','ON_ERROR_STOP=1','-X','-t','-A','-d', DBURL, ...extra]; }
function psql(sql) { execFileSync('psql', psqlArgs(['-c', sql]), { stdio:'inherit' }); }
function psqlFile(file) { spawnSync('psql', psqlArgs(['-f', file]), { stdio:'inherit' }); }

console.log('[seed] set session GUC from ENV (if any)');
if (process.env.APP_SEED_ADMIN_EMAIL) psql(`SELECT set_config('app.seed_admin_email','${process.env.APP_SEED_ADMIN_EMAIL}',false);`);
if (process.env.APP_SEED_ADMIN_PASS)  psql(`SELECT set_config('app.seed_admin_pass','${process.env.APP_SEED_ADMIN_PASS}',false);`);

const dir = 'db/seeds';
if (!existsSync(dir)) { console.log('[seed] no seeds'); process.exit(0); }
const files = readdirSync(dir).filter(f=>f.endsWith('.sql')).sort();
for (const f of files) { console.log('[seed] run', f); psqlFile(`${dir}/${f}`); }
console.log('[seed] done');
