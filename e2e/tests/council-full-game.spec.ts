/**
 * PopMusic Council — full-game E2E validation.
 * Each describe block = one council engineer specialty.
 */
import { test, expect } from '@playwright/test';
import {
  waitForFlutterReady,
  tapText,
  tapBack,
  openDrawer,
  assertNoFatalError,
  startNewGame,
  visitDrawerScreen,
  dismissDialogs,
} from './helpers/flutter';

test.describe('Council: Navigation Engineer', () => {
  test('main menu renders and all menu buttons respond', async ({ page }) => {
    await waitForFlutterReady(page);
    await assertNoFatalError(page);
    await expect(page.getByRole('button', { name: 'NEW GAME' })).toBeVisible();

    for (const label of ['SETTINGS', 'CREDITS']) {
      await tapText(page, label);
      await page.waitForTimeout(800);
      await assertNoFatalError(page);
      await tapBack(page);
      await page.waitForTimeout(500);
    }
  });
});

test.describe('Council: Onboarding Engineer', () => {
  test('new game flow creates artist and reaches dashboard', async ({ page }) => {
    await startNewGame(page, 'Council QA');
    await expect(page.getByText(/Council QA|Dashboard|Proceed Week/i).first()).toBeVisible({
      timeout: 15_000,
    });
  });
});

test.describe('Council: Gameplay Engineer', () => {
  test.beforeEach(async ({ page }) => {
    await startNewGame(page, 'Gameplay Bot');
  });

  test('bottom tabs — Dashboard, Music, Activities', async ({ page }) => {
    for (const tab of ['Music', 'Activities', 'Dashboard']) {
      await tapText(page, tab);
      await page.waitForTimeout(700);
      await assertNoFatalError(page);
    }
  });

  test('create song screen opens and returns', async ({ page }) => {
    await tapText(page, 'Music');
    await tapText(page, 'CREATE NEW SONG');
    await page.waitForTimeout(800);
    await expect(page.getByText(/Create Song|Song Title|Genre/i).first()).toBeVisible({
      timeout: 10_000,
    });
    await tapBack(page);
    await assertNoFatalError(page);
  });

  test('proceed week advances calendar without crash', async ({ page }) => {
    await tapText(page, 'Proceed Week');
    await page.waitForTimeout(1200);
    await assertNoFatalError(page);
    await dismissDialogs(page);
    await assertNoFatalError(page);
  });

  test('activities shortcuts open sub-screens', async ({ page }) => {
    await tapText(page, 'Activities');
    for (const item of ['Perform', 'Artists', 'Career', 'Challenges']) {
      await tapText(page, item);
      await page.waitForTimeout(800);
      await assertNoFatalError(page);
      await tapBack(page);
      await page.waitForTimeout(400);
      await tapText(page, 'Activities');
    }
  });
});

test.describe('Council: World Systems Engineer', () => {
  test.beforeEach(async ({ page }) => {
    await startNewGame(page, 'World Bot');
  });

  test('drawer screens — Charts, Perform, Artists, Career, Challenges, Lifestyle, Labels, Settings', async ({
    page,
  }) => {
    const screens = [
      'Charts',
      'Perform',
      'Artists',
      'Career',
      'Challenges',
      'Lifestyle',
      'Record Labels',
      'Settings',
    ];
    for (const screen of screens) {
      await tapText(page, 'Dashboard');
      await page.waitForTimeout(400);
      await visitDrawerScreen(page, screen);
      await tapBack(page);
      await page.waitForTimeout(400);
    }
  });
});

test.describe('Council: Settings Engineer', () => {
  test('settings themes and toggles work from main menu', async ({ page }) => {
    await waitForFlutterReady(page);
    await tapText(page, 'SETTINGS');
    await page.waitForTimeout(800);
    await assertNoFatalError(page);

    const themeNames = ['Dark', 'Light', 'Midnight', 'Neon', 'Sunset', 'Ocean'];
    for (const theme of themeNames) {
      const chip = page.getByText(theme, { exact: true }).first();
      if (await chip.isVisible({ timeout: 1500 }).catch(() => false)) {
        await chip.click();
        await page.waitForTimeout(400);
        await assertNoFatalError(page);
      }
    }
    await tapBack(page);
  });
});

test.describe('Council: Stability Engineer', () => {
  test('rapid navigation stress — no fatal errors', async ({ page }) => {
    await startNewGame(page, 'Stress Bot');
    const actions = ['Music', 'Activities', 'Dashboard', 'Proceed Week', 'Music'];
    for (let i = 0; i < 3; i++) {
      for (const a of actions) {
        await tapText(page, a).catch(() => {});
        await page.waitForTimeout(300);
      }
    }
    await assertNoFatalError(page);
  });

  test('exit game returns to main menu', async ({ page }) => {
    await startNewGame(page, 'Exit Bot');
    await openDrawer(page);
    await tapText(page, 'Exit Game');
    await page.waitForTimeout(1000);
    await expect(page.getByText(/POPMUSIC|NEW GAME/i).first()).toBeVisible({ timeout: 10_000 });
  });
});
