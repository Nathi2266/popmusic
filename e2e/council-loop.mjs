#!/usr/bin/env node
/**
 * AEOS Council Loop — test → report → cooldown (2 min) → repeat until 100% pass.
 * On success, captures Uptodown video + 10 screenshots.
 */
import { spawn, spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const COOLDOWN_MS = 2 * 60 * 1000;
const MAX_ITERATIONS = 20;
const PORT = 7357;
const BASE_URL = `http://127.0.0.1:${PORT}`;

let serverProc = null;

function log(msg) {
  const ts = new Date().toISOString();
  console.log(`[Council ${ts}] ${msg}`);
}

function startServer() {
  return spawn('npx', ['serve', '../build/web', '-l', String(PORT), '--no-clipboard'], {
    cwd: __dirname,
    shell: true,
    stdio: ['ignore', 'pipe', 'pipe'],
  });
}

async function waitForServer(retries = 30) {
  for (let i = 0; i < retries; i++) {
    try {
      const res = await fetch(BASE_URL);
      if (res.ok) return true;
    } catch {
      /* retry */
    }
    await sleep(1000);
  }
  return false;
}

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function runPlaywright(args = []) {
  return spawnSync('npx', ['playwright', 'test', ...args], {
    cwd: __dirname,
    shell: true,
    env: { ...process.env, POPMUSIC_URL: BASE_URL },
    encoding: 'utf-8',
    stdio: 'pipe',
  });
}

function parseCouncilReport() {
  const reportPath = path.join(__dirname, 'output', 'council-report.json');
  if (!fs.existsSync(reportPath)) return null;
  try {
    return JSON.parse(fs.readFileSync(reportPath, 'utf-8'));
  } catch {
    return null;
  }
}

function writeCouncilSummary(iteration, passed, report) {
  const outDir = path.join(__dirname, 'output');
  fs.mkdirSync(outDir, { recursive: true });
  const summary = {
    iteration,
    timestamp: new Date().toISOString(),
    passed,
    failedTests: [],
    engineers: {},
  };

  if (report?.suites) {
    for (const suite of report.suites) {
      const walk = (s, prefix = '') => {
        const name = prefix ? `${prefix} > ${s.title}` : s.title;
        if (s.specs) {
          for (const spec of s.specs) {
            for (const test of spec.tests ?? []) {
              const status = test.results?.[0]?.status ?? 'unknown';
              const engineer = name.split(' > ')[0] ?? 'Unknown';
              summary.engineers[engineer] = summary.engineers[engineer] ?? { pass: 0, fail: 0 };
              if (status === 'passed') summary.engineers[engineer].pass++;
              else {
                summary.engineers[engineer].fail++;
                summary.failedTests.push({ engineer, test: spec.title, status });
              }
            }
          }
        }
        for (const child of s.suites ?? []) walk(child, name);
      };
      walk(suite);
    }
  }

  fs.writeFileSync(
    path.join(outDir, `council-summary-iter-${iteration}.json`),
    JSON.stringify(summary, null, 2),
  );
  return summary;
}

async function main() {
  log('AEOS Council initiating PopMusic validation loop');
  log(`Cooldown between iterations: ${COOLDOWN_MS / 1000}s`);

  // Ensure web build exists
  const webBuild = path.join(__dirname, '..', 'build', 'web', 'index.html');
  if (!fs.existsSync(webBuild)) {
    log('Web build missing — run: flutter build web --release');
    process.exit(1);
  }

  serverProc = startServer();
  const ready = await waitForServer();
  if (!ready) {
    log('Server failed to start on port ' + PORT);
    process.exit(1);
  }
  log(`Game server live at ${BASE_URL}`);

  let iteration = 0;
  while (iteration < MAX_ITERATIONS) {
    iteration++;
    log(`═══ Council Iteration ${iteration} ═══`);

    const result = runPlaywright(['council-full-game.spec.ts']);
    process.stdout.write(result.stdout ?? '');
    process.stderr.write(result.stderr ?? '');

    const report = parseCouncilReport();
    const passed = result.status === 0;
    const summary = writeCouncilSummary(iteration, passed, report);

    if (passed) {
      log('✓ All council engineers report GREEN — 100% validation');
      log('Capturing Uptodown video + 10 screenshots...');
      const assetResult = runPlaywright(['-c', 'playwright.assets.config.ts']);
      process.stdout.write(assetResult.stdout ?? '');
      process.stderr.write(assetResult.stderr ?? '');

      if (assetResult.status === 0) {
        log('✓ Assets captured in e2e/output/uptodown-assets/');
        log('  - popmusic-gameplay-full.mp4');
        log('  - feature-01 through feature-10 (1024×500 PNG)');
      } else {
        log('Asset capture had issues — check output folder');
      }

      log('Council loop complete. Goal fulfilled.');
      break;
    }

    log(`✗ Failures detected — ${summary.failedTests.length} test(s) need engineer deployment`);
    for (const f of summary.failedTests) {
      log(`  [${f.engineer}] ${f.test} → ${f.status}`);
    }

    if (iteration >= MAX_ITERATIONS) {
      log('Max iterations reached without 100% pass.');
      process.exit(1);
    }

    log(`Cooldown ${COOLDOWN_MS / 1000}s before next council review...`);
    await sleep(COOLDOWN_MS);
    log('Re-testing after cooldown...');
  }

  if (serverProc) serverProc.kill();
}

main().catch((e) => {
  console.error(e);
  if (serverProc) serverProc.kill();
  process.exit(1);
});
