import { Page, expect } from '@playwright/test';
import path from 'path';

/** Click a Playwright locator through Flutter's canvas overlay. */
export async function flutterClick(locator: ReturnType<Page['locator']>): Promise<void> {
  await locator.evaluate((el) => (el as HTMLElement).click());
}

/** Wait until Flutter web has booted and rendered the first screen. */
export async function waitForFlutterReady(page: Page): Promise<void> {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await page.waitForSelector('flutter-view, flt-glass-pane, body', {
    state: 'attached',
    timeout: 60_000,
  });
  await page.waitForTimeout(3000);

  // Semantics auto-enabled in app; optional legacy a11y placeholder
  const a11yBtn = page.locator('[aria-label="Enable accessibility"]');
  if ((await a11yBtn.count()) > 0) {
    await a11yBtn.evaluate((el) => (el as HTMLElement).click());
    await page.waitForTimeout(800);
  }
}

/** Tap visible text (Flutter web semantics). */
export async function tapText(
  page: Page,
  text: string | RegExp,
  options?: { exactRole?: boolean },
): Promise<void> {
  const exactRole = options?.exactRole ?? false;
  const locators = [
    page.getByRole('button', { name: text, exact: exactRole }),
    page.getByRole('tab', { name: text, exact: exactRole }),
    page.getByRole('link', { name: text, exact: exactRole }),
    page.getByRole('menuitem', { name: text, exact: exactRole }),
  ];
  if (!exactRole) {
    locators.push(
      typeof text === 'string'
        ? page.getByText(text, { exact: false })
        : page.getByText(text),
    );
  }

  for (const loc of locators) {
    try {
      const target = loc.first();
      if (await target.isVisible({ timeout: 2000 }).catch(() => false)) {
        await flutterClick(target);
        await page.waitForTimeout(600);
        return;
      }
    } catch {
      /* try next */
    }
  }

  // Semantic tree fallback
  const clicked = await page.evaluate((label) => {
    const nodes = Array.from(
      document.querySelectorAll('[role="button"], flt-semantics[role="button"], [role="tab"], flt-semantics[role="tab"], [aria-label]'),
    );
    const match = nodes.find((n) => {
      const aria = (n.getAttribute('aria-label') ?? '').trim();
      const txt = (n.textContent ?? '').trim();
      // Exact match for "Music" tab — avoids "Create Music" hustle on dashboard
      if (label === 'Music') return aria === label || txt === label;
      return aria.includes(label) || txt.includes(label);
    });
    if (match instanceof HTMLElement) {
      match.click();
      return true;
    }
    return false;
  }, typeof text === 'string' ? text : '');

  if (!clicked && typeof text === 'string') {
    const vp = page.viewportSize();
    const wide = vp !== null && vp.width >= 1000;
    const mobileCoords: Record<string, [number, number]> = {
      'NEW GAME': [195, 380],
      'CONTINUE': [195, 450],
      'SETTINGS': [195, 520],
      'CREDITS': [195, 590],
      'EXIT': [195, 660],
      'START CAREER': [195, 780],
      Dashboard: [65, 820],
      Music: [195, 820],
      Activities: [325, 820],
      'Proceed Week': [340, 55],
      'CREATE NEW SONG': [195, 120],
      Perform: [195, 200],
      Artists: [195, 280],
      Career: [195, 360],
      Challenges: [195, 440],
      Charts: [195, 200],
      Lifestyle: [195, 440],
      'Record Labels': [195, 520],
      Settings: [195, 600],
      'Exit Game': [195, 750],
    };
    const wideCoords: Record<string, [number, number]> = {
      'NEW GAME': [512, 280],
      'CONTINUE': [512, 330],
      'SETTINGS': [512, 380],
      'CREDITS': [512, 430],
      'EXIT': [512, 480],
      'START CAREER': [512, 450],
      Dashboard: [170, 480],
      Music: [512, 480],
      Activities: [850, 480],
      'Proceed Week': [900, 40],
      'CREATE NEW SONG': [512, 100],
      Perform: [512, 160],
      Artists: [512, 220],
      Career: [512, 280],
      Challenges: [512, 340],
      Charts: [512, 160],
      Lifestyle: [512, 340],
      'Record Labels': [512, 400],
      Settings: [512, 450],
      'Exit Game': [512, 470],
    };
    const coords = wide ? wideCoords : mobileCoords;
    const pt = coords[text];
    if (pt) {
      await page.mouse.click(pt[0], pt[1]);
      await page.waitForTimeout(600);
      return;
    }
    throw new Error(`Could not tap "${text}"`);
  }
}

/** Tap bottom navigation bar by tab name (coordinate-safe — skips "Create Music" hustle). */
export async function tapBottomNav(page: Page, tab: 'Dashboard' | 'Music' | 'Activities'): Promise<void> {
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.waitForTimeout(200);
  const tabBtn = page.getByRole('tab', { name: tab, exact: true });
  if (await tabBtn.isVisible({ timeout: 2000 }).catch(() => false)) {
    await flutterClick(tabBtn);
    await page.waitForTimeout(600);
    return;
  }
  const coords: Record<string, [number, number]> = {
    Dashboard: [65, 820],
    Music: [195, 820],
    Activities: [325, 820],
  };
  await page.mouse.click(...coords[tab]);
  await page.waitForTimeout(600);
}

export async function tapTab(page: Page, tab: 'Dashboard' | 'Music' | 'Activities'): Promise<void> {
  await tapBottomNav(page, tab);
}

export async function tapBack(page: Page): Promise<void> {
  const back = page.getByRole('button', { name: /back|navigate up/i }).first();
  if (await back.isVisible({ timeout: 2000 }).catch(() => false)) {
    await flutterClick(back);
    await page.waitForTimeout(500);
    return;
  }
  await page.mouse.click(30, 55);
  await page.waitForTimeout(500);
}

export async function openDrawer(page: Page): Promise<void> {
  const menu = page.getByRole('button', { name: /open navigation menu|menu/i }).first();
  if (await menu.isVisible({ timeout: 3000 }).catch(() => false)) {
    await flutterClick(menu);
    await page.waitForTimeout(400);
    return;
  }
  await page.mouse.click(30, 55);
  await page.waitForTimeout(400);
}

export async function assertNoFatalError(page: Page): Promise<void> {
  const body = await page.locator('body').innerText();
  expect(body).not.toMatch(/Failed to start app|Exception|Stack trace/i);
}

export async function startNewGame(page: Page, artistName = 'Test Star'): Promise<void> {
  await waitForFlutterReady(page);
  await tapText(page, 'NEW GAME');
  await expect(page.getByText(/Create Your Artist|Artist Name/i).first()).toBeVisible({
    timeout: 10_000,
  });

  const input = page.locator('input, textarea, [contenteditable="true"]').first();
  if (await input.isVisible({ timeout: 3000 }).catch(() => false)) {
    await input.fill(artistName);
  } else {
    // Tap name field then type
    await page.mouse.click(195, 380);
    await page.keyboard.type(artistName);
  }

  await tapText(page, 'START CAREER');
  await page.waitForTimeout(1500);
  await assertNoFatalError(page);
}

export async function visitDrawerScreen(page: Page, title: string): Promise<void> {
  await openDrawer(page);
  // Scroll drawer list so lower items (Settings, Record Labels) are visible
  if (['Record Labels', 'Settings'].includes(title)) {
    await page.mouse.move(195, 500);
    await page.mouse.wheel(0, 200);
    await page.waitForTimeout(400);
  }
  await tapText(page, title);
  await page.waitForTimeout(800);
  await assertNoFatalError(page);
}

export async function screenshotNamed(page: Page, dir: string, name: string, index: number): Promise<string> {
  const fs = await import('fs');
  fs.mkdirSync(dir, { recursive: true });
  const file = path.resolve(dir, `screenshot-${String(index).padStart(2, '0')}-${name}.png`);
  await page.screenshot({ path: file, fullPage: false });
  return file;
}

export async function dismissDialogs(page: Page): Promise<void> {
  for (const pattern of [/close/i, /^ok$/i, /continue/i, /done/i, /got it/i]) {
    const btn = page.getByRole('button', { name: pattern }).first();
    if (await btn.isVisible({ timeout: 800 }).catch(() => false)) {
      await flutterClick(btn);
      await page.waitForTimeout(400);
    }
  }
}
