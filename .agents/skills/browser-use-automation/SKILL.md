---
name: browser-use-automation
description: >-
  Automated browser navigation, scraping, web interaction, and end-to-end testing
  using browser subagent, Chrome DevTools Protocol, Puppeteer, Playwright, or browser-use workflows.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# Browser Use & Web Automation

This skill guides headless and interactive web automation, DOM inspection, data extraction, and automated browser tasks.

---

## 1. Operating Principles

1. **Inspect Before Clicking**: Wait for key selectors or network idle state before attempting clicks, form fills, or screenshots.
2. **Handle Dynamic Content**: Modern single-page applications (SPAs) load data asynchronously. Prefer explicit wait conditions (`waitForSelector`, `waitForResponse`) over fixed arbitrary delays.
3. **Resilient Selectors**: Prefer accessible roles and labels (`getByRole`, `getByLabel`, `data-testid`) over brittle CSS class chains (`div > span:nth-child(2)`).

---

## 2. Browser Subagent & DevTools MCP Workflows

When using the Antigravity `browser_subagent` or `chrome-devtools-mcp`:
- **Navigation**: Always supply full valid URLs including scheme (`https://`).
- **Target Verification**: After each major action (click, form submit), capture a screenshot or check DOM state to confirm navigation/state mutation.
- **Recording Artifacts**: Ensure task recordings are named descriptively (e.g. `login_flow_demo`, `checkout_test`).

---

## 3. Playwright & Puppeteer Script Patterns

```javascript
import { chromium } from 'playwright';

async function runBrowserTask(url) {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 800 },
    userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  });
  const page = await context.newPage();

  try {
    await page.goto(url, { waitUntil: 'networkidle' });

    // Extract structured information
    const data = await page.evaluate(() => {
      return Array.from(document.querySelectorAll('article')).map(el => ({
        title: el.querySelector('h2')?.innerText.trim(),
        link: el.querySelector('a')?.href,
      }));
    });

    return data;
  } finally {
    await browser.close();
  }
}
```

---

## 4. Error Recovery & Anti-Bot Awareness
- If encountering rate limits or Cloudflare challenges, do not retry in an aggressive tight loop.
- Use realistic viewport dimensions and avoid headless fingerprint leaks when testing public endpoints.
