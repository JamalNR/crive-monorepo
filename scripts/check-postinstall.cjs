#!/usr/bin/env node
const fs = require('fs'); const path=require('path');
function scan(dir,h=[]) {
  for (const e of fs.readdirSync(dir)) {
    if (e==='node_modules'||e==='.git') continue;
    const p=path.join(dir,e), s=fs.statSync(p);
    if (s.isDirectory()) scan(p,h);
    else if (e==='package.json') {
      const j=JSON.parse(fs.readFileSync(p,'utf8'));
      const sc=j.scripts||{};
      for (const k of ['preinstall','install','postinstall']) if (sc[k]) h.push(p);
    }
  } return h;
}
const hits=scan(process.cwd());
if (hits.length){ console.error('Found pre/install/postinstall scripts:\n'+hits.join('\n')); process.exit(1);}
console.log('OK: no pre/install/postinstall scripts.');
