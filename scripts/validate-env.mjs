#!/usr/bin/env node
import fs from 'fs'; import path from 'path';

const apps = process.argv.slice(2).filter(a => !a.startsWith('--'));
if (apps.length === 0) {
  console.error('Usage: node scripts/validate-env.mjs apps/api [apps/admin]');
  process.exit(2);
}

function parseExample(file) {
  const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
  const out = [];
  for (const line of lines) {
    if (!line || line.trim().startsWith('#')) continue;
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=/);
    if (!m) continue;
    const key = m[1];
    const optional = /#\s*optional/i.test(line);
    const defm = line.match(/#\s*default\s*=\s*([^\s#]+)/i);
    out.push({ key, optional, def: defm ? defm[1] : undefined });
  }
  return out;
}

function loadDotenv(appDir) {
  const f = path.join(appDir, '.env');
  if (!fs.existsSync(f)) return;
  for (const line of fs.readFileSync(f, 'utf8').split(/\r?\n/)) {
    if (!line || line.trim().startsWith('#')) continue;
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
    if (!m) continue;
    const [, k, raw] = m;
    if (process.env[k] == null || process.env[k] === '') {
      process.env[k] = raw.replace(/^['"]|['"]$/g, '');
    }
  }
}

let errors = 0;
for (const app of apps) {
  const ex = path.join(app, '.env.example');
  if (!fs.existsSync(ex)) {
    console.error(`[SKIP] ${app}: .env.example not found`);
    continue;
  }
  loadDotenv(path.resolve(app));
  const vars = parseExample(ex);
  const missing = [];
  for (const v of vars) {
    let val = process.env[v.key];
    if ((val == null || val === '') && v.def != null) val = v.def;
    if ((val == null || val === '') && !v.optional) missing.push(v.key);
  }
  if (missing.length) {
    console.error(`[FAIL] ${app}: missing ${missing.length} keys:\n  - ${missing.join('\n  - ')}`);
    errors++;
  } else {
    console.log(`[OK] ${app}: all required ENV present`);
  }
}
process.exit(errors ? 1 : 0);
