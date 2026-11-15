import { readFileSync } from "node:fs";
import { expect, test } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";
import { marked, type Tokens } from "marked";
import type { Product, Sample, Contributor } from "../src/lib/types";

const pageErrors = new WeakMap<object, string[]>();
test.beforeEach(async ({ page }) => {
  const errors: string[] = [];
  pageErrors.set(page, errors);
  page.on("pageerror", (error) => errors.push(error.message));
});
test.afterEach(async ({ page }) => {
  expect(pageErrors.get(page)).toEqual([]);
});
async function openFilters(page: import("@playwright/test").Page) {
  if (!(await page.locator("#tool-filter").isVisible())) await page.locator("#advanced-filters summary").click();
}

test("uses the approved brand, Graph imagery, ordered filters, and Community-first navigation", async ({ page, request }) => {
  const catalog = await (await request.get("catalog.json")).json() as { samples: Sample[]; products: Product[]; contributors: Contributor[] };
  await page.goto("./");
  await expect(page.locator("#sample-grid")).toHaveAttribute("data-ready", "true");
  await expect(page.locator(".brand-name")).toHaveText(/Community\s+Script Samples/);
  await expect(page.locator(".hero-description")).toContainText("Real-world scripts for Copilot, Microsoft 365, Power Platform and more.");
  await expect(page.locator('#product-filters > [data-product="graph"] img')).toHaveAttribute("src", /images\/graph\.svg$/);
  const featured = await page.locator("#product-filters > [data-product]").evaluateAll((buttons) => buttons.slice(1).map((button) => button.getAttribute("data-product")));
  expect(featured).toEqual(catalog.products.filter((product) => product.featured).map((product) => product.id));
  const counts = catalog.products.filter((product) => product.featured).map((product) => product.count);
  expect(counts).toEqual([...counts].sort((a, b) => b - a));
  for (const route of ["./", "getting-started/", "contributors/", "contributing/", "samples/aad-add-app-permission/"]) {
    await page.goto(route);
    const mobile = await page.locator(".mobile-nav").isVisible();
    if (mobile) await page.locator(".mobile-nav summary").click();
    const nav = page.getByRole("navigation", { name: mobile ? "Mobile navigation" : "Primary navigation", exact: true });
    await expect(nav.getByRole("link").first()).toHaveAttribute("href", "https://aka.ms/community/home");
    await expect(nav.getByRole("link").first()).toHaveText("Community");
    await expect(nav.getByRole("link").first().locator("svg")).toHaveAttribute("aria-hidden", "true");
  }
});

test("combines filters, preserves deep links, sorts, and presents empty states", async ({ page, request }) => {
  const catalog = await (await request.get("catalog.json")).json() as { samples: Sample[]; products: Product[] };
  await page.goto("./");
  await page.locator('[data-product="teams"]').click();
  await openFilters(page);
  await page.locator("#tool-filter").selectOption("CLI-FOR-MICROSOFT365");
  const expected = catalog.samples.filter((sample) => sample.products.includes("teams") && sample.tools.some((tool) => tool.id === "CLI-FOR-MICROSOFT365"));
  await expect(page.locator("#result-count")).toHaveText(`${expected.length} matching samples of ${catalog.samples.length}`);
  await expect(page).toHaveURL(/product=teams.*tool=CLI-FOR-MICROSOFT365/);
  await page.reload();
  await expect(page.locator("#tool-filter")).toHaveValue("CLI-FOR-MICROSOFT365");
  await expect(page.locator('[data-product="teams"]')).toHaveAttribute("aria-pressed", "true");
  await page.locator("#sample-search").fill("no-such-command-xyz-42");
  await expect(page.locator("#empty-state")).toBeVisible();
  await page.locator("#empty-clear").click();
  await expect(page.locator("#sample-search")).toBeFocused();
  await expect(page.locator(".sample-card:visible")).toHaveCount(12);
  await page.locator("#sort-samples").selectOption("name");
  const titles = await page.locator(".sample-card:visible h3").allTextContents();
  expect(titles).toEqual([...titles].sort((a, b) => a.localeCompare(b)));
  await page.goto("./?product=entra&q=AzureAD");
  const oldNameCount = await page.locator("#result-count").innerText();
  await page.locator("#sample-search").fill("Microsoft Entra");
  await expect(page.locator("#result-count")).toHaveText(oldNameCount);
  await page.goto("./?product=invalid-product");
  await expect(page.locator("#filter-notice")).toBeVisible();
  await expect(page.locator("#result-count")).toHaveText(`Explore all ${catalog.samples.length} community samples`);
});

test("restores loaded results, list layout, filters, and scroll when returning from a sample", async ({ page }) => {
  await page.goto("./?product=sharepoint");
  await page.locator("#load-more").click();
  await expect(page.locator(".sample-card:visible")).toHaveCount(24);
  await page.locator('[data-layout="list"]').click();
  const link = page.locator(".sample-card:visible h3 a").nth(15);
  await link.scrollIntoViewIfNeeded();
  const before = await page.evaluate(() => scrollY);
  const title = await link.innerText();
  await link.click();
  await expect(page.locator("h1")).toHaveText(title);
  await page.goBack();
  await expect(page.locator('[data-product="sharepoint"]')).toHaveAttribute("aria-pressed", "true");
  await expect(page.locator("#sample-grid")).toHaveClass("sample-grid is-list");
  await expect(page.locator(".sample-card:visible")).toHaveCount(24);
  await expect.poll(async () => Math.abs((await page.evaluate(() => scrollY)) - before)).toBeLessThan(12);
});

test("shows full real tool implementations with keyboard tabs and exact code copying", async ({ page, context }) => {
  const readme = readFileSync(new URL("../../scripts/aad-add-app-permission/README.md", import.meta.url), "utf8");
  const blocks = marked.lexer(readme).filter((token): token is Tokens.Code => token.type === "code");
  await context.grantPermissions(["clipboard-read", "clipboard-write"]);
  await page.goto("samples/aad-add-app-permission/");
  const tabs = page.locator('.readme-tabs [role="tab"]');
  await expect(tabs).toHaveCount(2);
  const panel = page.locator('.readme-tabs [role="tabpanel"]:visible');
  expect((await panel.locator("pre code").innerText()).trim()).toBe(blocks[0].text.trim());
  await tabs.first().focus();
  await page.keyboard.press("ArrowRight");
  await expect(tabs.nth(1)).toHaveAttribute("aria-selected", "true");
  await expect(page).toHaveURL(/#tab\/graphps$/);
  expect((await panel.locator("pre code").innerText()).trim()).toBe(blocks[1].text.trim());
  await panel.getByRole("button", { name: /Copy powershell code/ }).click();
  await expect(panel.getByRole("button", { name: /Copy powershell code/ })).toHaveText("Copied");
  const copied = await page.evaluate(() => navigator.clipboard.readText());
  expect(copied.replace(/\r\n/g, "\n").trim()).toBe(blocks[1].text.trim());
  await expect(page.locator(".safety-note")).toBeVisible();
  await expect(page.locator(".readme-content")).not.toContainText("[!INCLUDE");
  await expect(page.locator(".readme-content")).not.toContainText("Design preview");
});

test("renders all contributor profiles, badge eligibility, and accurate author-filter links", async ({ page, request }) => {
  const catalog = await (await request.get("catalog.json")).json() as { contributors: Contributor[]; samples: Sample[] };
  await page.goto("contributors/");
  await expect(page.locator(".contributor-card")).toHaveCount(catalog.contributors.length);
  await expect(page.locator(".contributor-badge-link")).toHaveCount(catalog.contributors.length);
  await expect(page.locator(".recognition-badge")).toHaveAttribute("src", /assets\/credly-badge\.png$/);
  await page.locator("#contributor-search").fill("nelladath");
  await expect(page.locator(".contributor-card:visible")).toHaveCount(1);
  const author = catalog.contributors.find((candidate) => candidate.handle.toLowerCase() === "nelladath");
  expect(author).toBeDefined();
  await page.locator(".contributor-card:visible .text-link").click();
  await expect(page.locator("#author-filter")).toHaveValue("nelladath");
  await expect(page.locator("#result-count")).toHaveText(`${author!.count} matching samples of ${catalog.samples.length}`);
  await page.goto("contributing/");
  await expect(page.locator(".recognition-badge")).toBeVisible();
  await expect(page.locator(".guide-content")).toContainText("first accepted sample");
});

test("retains old sample, guide, filter, and report links without redirect tracking", async ({ page, request }) => {
  const legacy = await request.get("aad-add-app-permission/README.html");
  expect(legacy.status()).toBe(200);
  expect(await legacy.text()).not.toContain("data-visitor-stats");
  await page.goto("aad-add-app-permission/README.html#tab/graphps");
  await expect(page).toHaveURL(/samples\/aad-add-app-permission\/#tab\/graphps$/);
  await expect(page.locator('[data-tab-id="graphps"]')).toHaveAttribute("aria-selected", "true");
  await page.goto("by-tool.html?query=Get-PnPSite");
  await expect(page.locator("#sample-search")).toHaveValue("Get-PnPSite");
  await page.goto("compact-view.html");
  await expect(page.locator("#sample-grid")).toHaveClass("sample-grid is-list");
  await page.goto("contributing/preparing-a-submission.html");
  await expect(page).toHaveURL(/contributing\/preparing-a-submission\/$/);
  await expect(page.locator("h1")).toHaveText("Share your first script sample");
  await page.goto("matrix.html");
  await expect(page).toHaveURL(/reports\/#matrix$/);
});

test("keeps local previews free of production analytics and maps every page tracker correctly", async ({ page }) => {
  const requests: string[] = [];
  page.on("request", (request) => { if (request.url().includes("m365-visitor-stats")) requests.push(request.url()); });
  const paths = [
    ["./", "script-samples"],
    ["contributors/", "script-samples/contributors"],
    ["contributing/", "script-samples/contributing"],
    ["contributing/recognition/", "script-samples/contributing/recognition"],
    ["samples/aad-add-app-permission/", "script-samples/scripts/aad-add-app-permission"]
  ];
  for (const [url, identity] of paths) {
    await page.goto(url);
    await expect(page.locator("[data-visitor-stats]")).toHaveCount(1);
    await expect(page.locator("[data-visitor-stats]")).toHaveAttribute("data-tracker-src", `https://m365-visitor-stats.azurewebsites.net/${identity}`);
    await expect(page.locator("[data-visitor-stats]")).toHaveAttribute("src", /^data:image/);
  }
  const response = await page.goto("missing-example/");
  expect(response?.status()).toBe(404);
  await expect(page.locator("[data-visitor-stats]")).toHaveAttribute("data-tracker-src", "https://m365-visitor-stats.azurewebsites.net/script-samples/404");
  expect(requests).toEqual([]);
});

test("activates exactly one production tracker without counting filter or theme interactions", async ({ page, request, baseURL }) => {
  if (!baseURL) throw new Error("Browser tests require the local production server.");
  const origin = new URL(baseURL).origin;
  const tracked: string[] = [];
  await page.route("https://m365-visitor-stats.azurewebsites.net/**", async (route) => {
    tracked.push(route.request().url());
    await route.fulfill({ contentType: "image/gif", headers: { "Cache-Control": "no-store" }, body: Buffer.from("R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=", "base64") });
  });
  await page.route("https://pnp.github.io/script-samples/**", async (route) => {
    const url = new URL(route.request().url());
    const response = await request.get(`${origin}${url.pathname}${url.search}`);
    const headers = { ...response.headers() };
    delete headers["content-length"];
    const body = headers["content-type"]?.includes("text/html")
      ? (await response.text()).replace('data-tracking-enabled="false"', 'data-tracking-enabled="true"')
      : await response.body();
    await route.fulfill({ status: response.status(), headers, body });
  });
  await page.goto("https://pnp.github.io/script-samples/");
  await expect.poll(() => tracked.length).toBe(1);
  expect(tracked[0]).toBe("https://m365-visitor-stats.azurewebsites.net/script-samples");
  await page.locator('[data-product="graph"]').click();
  await page.locator("#sample-search").fill("permissions");
  await page.locator("#theme-toggle").click();
  await page.evaluate(() => new Promise(requestAnimationFrame));
  expect(tracked).toHaveLength(1);
});

test("persists themes and has no WCAG violations on key views in either theme", async ({ page }) => {
  test.setTimeout(120000);
  const routes = ["./", "contributors/", "contributing/", "contributing/preparing-a-submission/", "samples/aad-add-app-permission/"];
  for (const theme of ["light", "dark"]) {
    await page.goto("./");
    if ((await page.locator("html").getAttribute("data-theme")) !== theme) await page.locator("#theme-toggle").click();
    await page.reload();
    await expect(page.locator("html")).toHaveAttribute("data-theme", theme);
    for (const route of routes) {
      await page.goto(route);
      const result = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"]).analyze();
      expect(result.violations, `${theme}: ${route}`).toEqual([]);
      const dimensions = await page.evaluate(() => ({ viewport: document.documentElement.clientWidth, content: document.documentElement.scrollWidth }));
      expect(dimensions.content, `${theme}: ${route}`).toBeLessThanOrEqual(dimensions.viewport);
    }
  }
});

test("prioritizes search on mobile and renders the real local brand assets", async ({ page }, testInfo) => {
  await page.goto("./");
  await expect(page.locator(".brand img")).toHaveJSProperty("complete", true);
  await expect(page.locator(".brand img")).not.toHaveJSProperty("naturalWidth", 0);
  await expect(page.locator('[data-product="graph"] img')).not.toHaveJSProperty("naturalWidth", 0);
  if (testInfo.project.name === "mobile") {
    const search = await page.locator("#sample-search").boundingBox();
    expect(search).not.toBeNull();
    expect(search!.y + search!.height).toBeLessThan(page.viewportSize()!.height);
    await expect(page.locator("#advanced-filters")).not.toHaveAttribute("open");
  }
});

test.describe("without JavaScript", () => {
  test.use({ javaScriptEnabled: false });
  test("still exposes all samples and full implementations", async ({ page, request }) => {
    const catalog = await (await request.get("catalog.json")).json() as { samples: Sample[] };
    await page.goto("./");
    await expect(page.locator(".sample-card:visible")).toHaveCount(catalog.samples.length);
    await page.goto("samples/aad-add-app-permission/");
    await expect(page.locator('.readme-tabs [role="tabpanel"]:visible')).toHaveCount(2);
    await expect(page.locator("[data-visitor-stats]")).toHaveAttribute("src", /^data:image/);
  });
});
