/**
 * Uptodown asset capture — 10 unique screens at 1024×500 PNG + MP4 video.
 */
import { test, expect, Page } from '@playwright/test';
import path from 'path';
import fs from 'fs';
import sharp from 'sharp';
import {
  waitForFlutterReady,
  tapText,
  tapBack,
  tapTab,
  visitDrawerScreen,
  dismissDialogs,
  flutterClick,
} from './helpers/flutter';
import {
  FEATURE_WIDTH,
  FEATURE_HEIGHT,
  convertWebmToMp4,
  resizeToFeatureSize,
} from './helpers/media';

const ASSETS_DIR = path.resolve(__dirname, '..', 'output', 'uptodown-assets');
const TMP_DIR = path.resolve(ASSETS_DIR, '_tmp');

async function backToDashboard(page: Page): Promise<void> {
  if (await page.getByText(/Proceed Week|This week/i).first().isVisible().catch(() => false)) {
    return;
  }
  for (let i = 0; i < 3; i++) {
    const hasBack = await page.getByRole('button', { name: /back|navigate up/i }).first().isVisible().catch(() => false);
    if (!hasBack) break;
    await tapBack(page);
    await page.waitForTimeout(400);
    if (await page.getByText(/Proceed Week|This week/i).first().isVisible().catch(() => false)) {
      return;
    }
  }
  await tapTab(page, 'Dashboard');
  await page.waitForTimeout(500);
}

async function snap(page: Page, index: number, id: string, mustSee: RegExp): Promise<string> {
  await expect(page.getByText(mustSee).first()).toBeVisible({ timeout: 15_000 });
  await page.waitForTimeout(800);

  fs.mkdirSync(TMP_DIR, { recursive: true });
  const raw = path.join(TMP_DIR, `${id}-raw.png`);
  const final = path.join(ASSETS_DIR, `feature-${String(index).padStart(2, '0')}-${id}.png`);

  await page.screenshot({ path: raw, type: 'png' });
  await resizeToFeatureSize(raw, final);

  const meta = await sharp(final).metadata();
  expect(meta.width).toBe(FEATURE_WIDTH);
  expect(meta.height).toBe(FEATURE_HEIGHT);
  return final;
}

async function openDrawerScreen(page: Page, title: string): Promise<void> {
  await backToDashboard(page);
  await visitDrawerScreen(page, title);
}

test('capture 10 unique Uptodown feature screenshots + MP4 gameplay video', async ({ page }) => {
  fs.mkdirSync(ASSETS_DIR, { recursive: true });
  for (const f of fs.readdirSync(ASSETS_DIR)) {
    if (f.endsWith('.png') || f.endsWith('.webm') || f.endsWith('.mp4')) {
      fs.unlinkSync(path.join(ASSETS_DIR, f));
    }
  }

  await page.goto('/');
  await waitForFlutterReady(page);
  await snap(page, 1, 'main-menu', /NEW GAME/i);

  await tapText(page, 'NEW GAME');
  await snap(page, 2, 'create-artist', /Create Your Artist|Artist Name|Home Genre/i);

  const input = page.locator('input, textarea').first();
  if (await input.isVisible({ timeout: 2000 }).catch(() => false)) {
    await input.fill('Pop Star');
  } else {
    await page.mouse.click(195, 380);
    await page.keyboard.type('Pop Star');
  }
  await tapText(page, 'START CAREER');
  await page.waitForTimeout(1500);
  await snap(page, 3, 'dashboard', /Proceed Week|This week/i);

  await tapText(page, 'Music');
  await snap(page, 4, 'music-catalog', /CREATE NEW SONG|No songs yet|COMPILE ALBUM/i);

  await flutterClick(page.getByRole('button', { name: /CREATE NEW SONG/i }));
  await page.waitForTimeout(800);
  await snap(page, 5, 'create-song', /Create Song|Songwriting|Song Title|RELEASE SONG/i);

  await openDrawerScreen(page, 'Charts');
  await snap(page, 6, 'charts', /Top 30|Genre filter|Live snapshot/i);

  await tapBack(page);
  await openDrawerScreen(page, 'Perform');
  await snap(page, 7, 'perform', /Performances|Book a show|Tour|Venue/i);

  await tapBack(page);
  await openDrawerScreen(page, 'Artists');
  await snap(page, 8, 'artists', /Artists|Sign|Roster|Browse/i);

  await tapBack(page);
  await openDrawerScreen(page, 'Career');
  await snap(page, 9, 'career', /Career|Storyline|Chapter|Awards|Reputation|Milestones/i);

  await tapBack(page);
  await openDrawerScreen(page, 'Lifestyle');
  await snap(page, 10, 'lifestyle', /Lifestyle|Luxury|Investment|Assets|Upkeep/i);

  await backToDashboard(page);
  await tapText(page, 'Proceed Week');
  await page.waitForTimeout(2000);
  await dismissDialogs(page);
  await tapText(page, 'Music');
  await page.waitForTimeout(600);
  await tapTab(page, 'Activities');
  await page.waitForTimeout(600);

  const files = fs.readdirSync(ASSETS_DIR).filter((f) => f.startsWith('feature-') && f.endsWith('.png'));
  expect(files).toHaveLength(10);
});

test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status !== 'passed') return;
  if (!testInfo.title.includes('capture 10 unique')) return;

  await new Promise((r) => setTimeout(r, 800));
  const webmPath = await page.video()?.path();
  if (!webmPath || !fs.existsSync(webmPath)) return;

  const mp4Out = path.join(ASSETS_DIR, 'popmusic-gameplay-full.mp4');
  convertWebmToMp4(webmPath, mp4Out);
  expect(fs.existsSync(mp4Out)).toBeTruthy();
  expect(fs.statSync(mp4Out).size).toBeGreaterThan(10_000);

  if (fs.existsSync(TMP_DIR)) fs.rmSync(TMP_DIR, { recursive: true, force: true });
});
