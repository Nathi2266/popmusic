import { defineConfig, devices } from '@playwright/test';
import path from 'path';

const BASE_URL = process.env.POPMUSIC_URL ?? 'http://127.0.0.1:7357';
const OUTPUT_DIR = path.join(__dirname, 'output');

/**
 * Navigate at mobile size (reliable Flutter semantics),
 * export screenshots resized to Uptodown 1024×500 feature graphics.
 */
export default defineConfig({
  testDir: './tests',
  testMatch: 'capture-assets.spec.ts',
  timeout: 180_000,
  expect: { timeout: 20_000 },
  fullyParallel: false,
  workers: 1,
  retries: 0,
  reporter: [['list']],
  use: {
    baseURL: BASE_URL,
    ...devices['Pixel 5'],
    video: {
      mode: 'on',
      size: { width: 393, height: 851 },
    },
  },
  projects: [{ name: 'uptodown-assets', use: { browserName: 'chromium' } }],
  outputDir: path.join(OUTPUT_DIR, 'test-results'),
});
