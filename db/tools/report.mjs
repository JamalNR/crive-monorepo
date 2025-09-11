#!/usr/bin/env node
// Output ringkas status migrasi ke Job Summary
const { execSync } = require('node:child_process');

function sh(cmd){ return execSync(cmd, {stdio:'pipe'}).toString().trim(); }

const DB = process.env.DATABASE_URL || '';
if (!DB) {
  console.log('No DATABASE_URL; skip report');
  process.exit(0);
}

const psql = (sql) =>
  sh(`psql "${DB}" -X -qAt -c ${JSON.stringify(sql)}`);

const total = psql("select count(*) from schema_migrations;") || '0';
const last  = psql("select coalesce(max(version),'(none)') from schema_migrations;");

const md = [
  `### DB Migration Report`,
  ``,
  `- Total versi terpasang: **${total}**`,
  `- Versi terakhir: \`${last}\``,
  `- Host: \`${process.env.HOST || 'n/a'}\``,
  `- Target: \`${process.env.TARGET || 'n/a'}\``,
  ``,
].join('\n');

require('fs').appendFileSync(process.env.GITHUB_STEP_SUMMARY || '/dev/stdout', md);
console.log(md);
