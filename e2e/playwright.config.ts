import { defineConfig, devices } from '@playwright/test';
import path from 'path';

const BASE_URL = process.env.POPMUSIC_URL ?? 'http://127.0.0.1:7357';
const OUTPUT_DIR = path.join(__dirname, 'output');

export default defineConfig({
  testDir: './tests',
  timeout: 120_000,
  expect: { timeout: 15_000 },
  fullyParallel: false,
  workers: 1,
  retries: 0,
  reporter: [
    ['list'],
    ['html', { outputFolder: path.join(OUTPUT_DIR, 'report'), open: 'never' }],
    ['json', { outputFile: path.join(OUTPUT_DIR, 'council-report.json') }],
  ],
  use: {
    baseURL: BASE_URL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
    video: 'on',
  },
  projects: [
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  outputDir: path.join(OUTPUT_DIR, 'test-results'),
});
