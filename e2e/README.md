# PopMusic AEOS Council — E2E Testing

Automated Playwright test suite for full-game validation, Uptodown asset capture, and council loop.

## Quick start

```bash
# 1. Build web (required for Playwright)
cd popmusic
flutter build web --release

# 2. Install & run council loop (2 min cooldown between retries)
cd e2e
npm install
npx playwright install chromium
npm run test:council
```

## Manual commands

```bash
# Serve game locally
npm run serve

# Run all council tests
npm run test

# Capture video + 10 screenshots for Uptodown
npm run test:assets
```

## Council engineers

| Engineer | Scope |
|---|---|
| Navigation | Main menu, settings, credits |
| Onboarding | New game → dashboard |
| Gameplay | Tabs, create song, proceed week, activities |
| World Systems | Drawer: charts, perform, artists, career, etc. |
| Settings | Theme switching |
| Stability | Stress navigation, exit game |

## Output assets

After successful run, find Uptodown assets at:

- `e2e/output/uptodown-assets/popmusic-gameplay-full.mp4` — full gameplay video (H.264)
- `e2e/output/uptodown-assets/feature-01-main-menu.png` … `feature-10-lifestyle.png` — **1024×500 PNG** feature graphics (unique screens)

## Council reports

- `e2e/output/council-report.json` — latest Playwright JSON report
- `e2e/output/council-summary-iter-N.json` — per-iteration council summary
