import { promises as fs } from 'fs';
import path from 'path';

const outDir = 'artifacts/combined';
await fs.mkdir(outDir, { recursive: true });

function safeReadJSON(p){ return fs.readFile(p,'utf8').then(JSON.parse).catch(()=>null); }
function list(dir, pat){ return fs.readdir(dir).then(xs=>xs.filter(x=>pat.test(x))).catch(()=>[]); }

let sbomCount = 0;
let osvCount = 0;
let trivy = { HIGH:0, CRITICAL:0, MEDIUM:0, LOW:0, UNKNOWN:0 };

const files = await list(outDir, /\.(json)$/);

for (const f of files) {
  const p = path.join(outDir,f);
  if (f.startsWith('sbom-')) {
    const j = await safeReadJSON(p);
    if (j?.components) sbomCount += j.components.length;
  } else if (f === 'osv.json') {
    const j = await safeReadJSON(p);
    // OSV formats vary; count advisories if possible
    if (Array.isArray(j?.results)) {
      osvCount += j.results.reduce((a,r)=>a + (r?.packages?.length||0), 0);
    } else if (Array.isArray(j?.vulnerabilities)) {
      osvCount += j.vulnerabilities.length;
    } else if (j?.status === 'error') {
      // keep visible but don't fail
    }
  } else if (f === 'trivy-fs.json') {
    const j = await safeReadJSON(p);
    const vulns = (j?.Results||[]).flatMap(r=>r.Vulnerabilities||[]);
    for (const v of vulns) trivy[v.Severity] = (trivy[v.Severity]||0)+1;
  }
}

const md = `### 🔎 PR Security & SBOM Summary
- SBOM components: **${sbomCount}**
- OSV findings (count): **${osvCount}**  *(from osv.json)*
- Trivy findings: **CRITICAL ${trivy.CRITICAL||0} | HIGH ${trivy.HIGH||0} | MEDIUM ${trivy.MEDIUM||0} | LOW ${trivy.LOW||0}*

_Artifacts parsed from current workflow run._
`;
await fs.writeFile(path.join(outDir,'PR_SUMMARY.md'), md);
console.log(md);
