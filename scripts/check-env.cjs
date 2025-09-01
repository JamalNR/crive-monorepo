// scripts/check-env.js — validator sederhana .env.example & .env
const fs = require("fs"), path = require("path");
const EXAMPLE = path.resolve(".env.example");
const LOCAL   = path.resolve(".env");
const IS_CI   = process.argv.includes("--ci") || process.env.CI === "true";

function parseEnv(file){
  if(!fs.existsSync(file)) return { map:new Map(), order:[] };
  const lines = fs.readFileSync(file,"utf8").split(/\r?\n/);
  const map=new Map(), order=[];
  for(const raw of lines){
    const line = raw.trim();
    if(!line || line.startsWith("#")) continue;
    const eq=line.indexOf("="); if(eq===-1) continue;
    const key=line.slice(0,eq).trim(); const val=line.slice(eq+1).trim();
    map.set(key,val); order.push({key,line:raw});
  }
  return { map, order };
}

function requiredFromExample(exampleLines){
  const req=new Set();
  for(const {key,line} of exampleLines){
    if (/#\s*REQUIRED\b/i.test(line)) req.add(key);
  }
  return req;
}

function hasSecretLikeValue(exampleMap){
  const suspicious=/(sk_live_|AKIA[0-9A-Z]{16}|AIzaSy|xoxb-|-----BEGIN (EC|RSA|OPENSSH) PRIVATE KEY-----)/i;
  for(const [k,v] of exampleMap.entries()){ if(suspicious.test(v)) return {k,v}; }
  return null;
}

const ex=parseEnv(EXAMPLE);
if(ex.order.length===0){ console.error("❌ .env.example tidak ditemukan/kosong."); process.exit(1); }

const bad=hasSecretLikeValue(ex.map);
if(bad){ console.error(`❌ Sanitasi gagal: nilai .env.example terlihat seperti rahasia nyata (key=${bad.k}).`); process.exit(1); }

const required=requiredFromExample(ex.order);

if(IS_CI){
  console.log(`✅ CI: .env.example valid. REQUIRED: ${[...required].join(", ")||"(none)"}`);
  process.exit(0);
}

const lc=parseEnv(LOCAL);
const missing=[]; for(const k of required){ if(!lc.map.has(k) || !String(lc.map.get(k))) missing.push(k); }
const unused=[]; for(const k of lc.map.keys()){ if(!ex.map.has(k)) unused.push(k); }

if(missing.length){ console.error("❌ ENV wajib yang hilang di .env:", missing.join(", ")); process.exit(1); }
if(unused.length){ console.warn("⚠️  Peringatan: variabel di .env tidak ada di .env.example:", unused.join(", ")); }

console.log("✅ ENV lokal lengkap & konsisten.");
