#!/usr/bin/env node
import { spawnSync } from 'node:child_process'

const [,,cmd,key,val] = process.argv
const url = process.env.DATABASE_URL
if (!url) { console.error('DATABASE_URL required'); process.exit(1) }

const sql = {
  get: `select key, enabled from feature_flags where key = '${key}'`,
  on:  `insert into feature_flags(key, enabled, updated_at) values('${key}', true, now())
        on conflict(key) do update set enabled=true, updated_at=now()`,
  off: `insert into feature_flags(key, enabled, updated_at) values('${key}', false, now())
        on conflict(key) do update set enabled=false, updated_at=now()`,
}[cmd]

if (!sql) { console.error('Usage: flag.cjs <get|on|off> <key>'); process.exit(2) }

const r = spawnSync('psql', [url, '-v', 'ON_ERROR_STOP=1', '-c', sql], { stdio: 'inherit' })
process.exit(r.status ?? 0)
