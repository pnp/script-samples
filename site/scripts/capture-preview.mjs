import { spawn } from "node:child_process";
import { once } from "node:events";
import { copyFile, mkdir } from "node:fs/promises";
import path from "node:path";
import { chromium } from "@playwright/test";
import { REPOSITORY_ROOT, SITE_ROOT } from "./config.mjs";

const server = spawn(process.execPath, ["scripts/serve-test.mjs"], { cwd: SITE_ROOT, stdio: ["ignore", "pipe", "inherit"] });
const output = path.join(SITE_ROOT, "test-results", "previews");
await mkdir(output, { recursive: true });
let browser;
try {
  await new Promise((resolve, reject) => {
    server.stdout.once("data", resolve);
    server.once("error", reject);
    server.once("exit", (code) => reject(new Error(`Preview server exited before readiness: ${code}`)));
  });
  const url = "http://127.0.0.1:4327/script-samples/";
  const response = await fetch(url);
  if (!response.ok) throw new Error(`Preview is not ready: HTTP ${response.status}`);
  browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 1220 } });
  async function capture(file) {
    await page.evaluate(() => document.fonts.ready);
    await page.waitForFunction(() => [...document.images].filter((image) => {
      const bounds = image.getBoundingClientRect();
      return image.checkVisibility() && bounds.width && bounds.height && bounds.top < innerHeight && bounds.bottom > 0;
    }).every((image) => image.complete));
    await page.screenshot({ path: file });
  }
  await page.goto(url);
  await page.locator('#sample-grid[data-ready="true"]').waitFor();
  await capture(path.join(REPOSITORY_ROOT, "docs", "assets", "gallery-preview.png"));
  await copyFile(path.join(REPOSITORY_ROOT, "docs", "assets", "gallery-preview.png"), path.join(SITE_ROOT, "public", "assets", "gallery-preview.png"));
  await copyFile(path.join(REPOSITORY_ROOT, "docs", "assets", "gallery-preview.png"), path.join(SITE_ROOT, "dist", "assets", "gallery-preview.png"));
  await capture(path.join(output, "gallery-light.png"));
  await page.locator("#theme-toggle").click();
  await capture(path.join(output, "gallery-dark.png"));
  await page.setViewportSize({ width: 390, height: 844 });
  await capture(path.join(output, "gallery-mobile-dark.png"));
  await page.locator("#theme-toggle").click();
  await capture(path.join(output, "gallery-mobile.png"));
  await page.setViewportSize({ width: 1440, height: 1220 });
  for (const [route, file] of [["contributors/", "contributors.png"], ["samples/aad-add-app-permission/", "sample-detail.png"], ["contributing/", "contributing.png"]]) {
    await page.goto(`${url}${route}`);
    await capture(path.join(output, file));
  }
  console.log("Captured the real Astro gallery for the README and desktop/mobile review previews.");
} finally {
  await browser?.close();
  server.kill();
  if (server.exitCode === null) await once(server, "exit");
}
