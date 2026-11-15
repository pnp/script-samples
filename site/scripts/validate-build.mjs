import assert from "node:assert/strict";
import { access, readFile, stat } from "node:fs/promises";
import path from "node:path";
import { BASE_PATH, SITE_ORIGIN, SITE_ROOT, sitePath, trackerIdentity } from "./config.mjs";

const dist = path.join(SITE_ROOT, "dist");
const routes = JSON.parse(await readFile(path.join(SITE_ROOT, "src", "generated", "routes.json"), "utf8"));
const views = ["", "contributors/", "reports/", "404.html", ...routes.guides, ...routes.samples.map((slug) => `samples/${slug}/`)];
const files = new Map();
async function htmlFile(relative) {
  const file = path.join(dist, ...relative.split("/").filter(Boolean), ...(relative.endsWith(".html") ? [] : ["index.html"]));
  if (!files.has(file)) files.set(file, await readFile(file, "utf8"));
  return files.get(file);
}
const checked = new Set();
const failures = [];
async function checkLink(source, href) {
  if (!href || /^(data:|mailto:|tel:)/i.test(href)) return;
  const url = new URL(href.replaceAll("&amp;", "&"), `${SITE_ORIGIN}${sitePath(source)}`);
  if (url.origin !== SITE_ORIGIN || !url.pathname.startsWith(`${BASE_PATH}/`)) return;
  const identity = `${url.pathname}${url.hash}`;
  if (checked.has(identity)) return;
  checked.add(identity);
  const relative = decodeURIComponent(url.pathname.slice(`${BASE_PATH}/`.length));
  const file = path.resolve(dist, ...relative.split("/").filter(Boolean), ...(url.pathname.endsWith("/") ? ["index.html"] : []));
  assert.ok(file.startsWith(`${dist}${path.sep}`), `Link escapes build directory: ${href}`);
  try { await access(file); }
  catch (error) {
    if (error.code !== "ENOENT") throw error;
    failures.push(`${source} -> missing ${url.pathname}`);
    return;
  }
  if (url.hash && path.extname(file) === ".html") {
    const html = await readFile(file, "utf8");
    if (!html.includes("data-legacy-redirect")) {
      const fragment = decodeURIComponent(url.hash.slice(1));
      const escaped = fragment.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      const tab = fragment.replace(/^tab\//, "");
      if (!new RegExp(`\\bid=["']${escaped}["']`).test(html) && !html.includes(`data-tab-id="${tab}"`)) {
        failures.push(`${source} -> missing fragment ${url.pathname}${url.hash}`);
      }
    }
  }
}
for (const view of views) {
  const html = await htmlFile(view);
  const identity = trackerIdentity(view === "404.html" ? "404" : view);
  const trackers = [...html.matchAll(/<img\b[^>]*\bdata-visitor-stats\b[^>]*>/g)];
  assert.equal(trackers.length, 1, `${view}: expected one view tracker`);
  assert.ok(trackers[0][0].includes(`data-tracker-src="${identity}"`), `${view}: wrong tracker identity`);
  assert.ok(trackers[0][0].includes('src="data:image/gif;'), `${view}: local previews must not eagerly request production analytics`);
  assert.equal((html.match(/<img\b[^>]*(?:src|data-tracker-src)="https:\/\/m365-visitor-stats\.azurewebsites\.net\/[^>]*>/g) ?? []).length, 1, `${view}: duplicate tracker image from source Markdown`);
  assert.match(html, /<title>[^<]+<\/title>/);
  assert.match(html, /<link rel="canonical" href="https:\/\/pnp\.github\.io\/script-samples\//);
  assert.ok(!/\[!INCLUDE\s*\[/.test(html.replace(/<pre\b[\s\S]*?<\/pre>/g, "")), `${view}: unresolved shared include`);
  for (const match of html.matchAll(/<(?:a|link|script|img)\b[^>]*?\b(?:href|src)="([^"]+)"[^>]*>/g)) await checkLink(view, match[1]);
}
for (const [legacy, target] of Object.entries(routes.redirects)) {
  const html = await htmlFile(legacy);
  assert.ok(html.includes("data-legacy-redirect"), `${legacy}: redirect missing`);
  assert.ok(html.includes(`href="${target.replaceAll("&", "&amp;")}"`), `${legacy}: wrong destination`);
  assert.ok(!html.includes("data-visitor-stats"), `${legacy}: redirect must not double-count views`);
  await checkLink(legacy, target);
}
for (const sample of routes.samples) await stat(path.join(dist, sample, "assets", "sample.json"));
const publicCatalog = JSON.parse(await readFile(path.join(dist, "catalog.json"), "utf8"));
assert.equal(publicCatalog.samples.length, routes.samples.length);
const legacyCatalog = JSON.parse(await readFile(path.join(dist, "samples.json"), "utf8"));
assert.equal(legacyCatalog.length, routes.samples.length);
for (const sample of legacyCatalog) {
  assert.ok(sample.metadata.length && sample.authors[0].gitHubAccount, `${sample.name}: legacy catalog shape changed`);
  assert.equal(sample.url, `${sample.name}/README.html`);
}
await access(path.join(dist, "sitemap-index.xml"));
await access(path.join(dist, "deployment.json"));
if (failures.length) throw new Error(`Built link validation failed (${failures.length}):\n${failures.join("\n")}`);
console.log(`[gallery] validated ${views.length} views, ${Object.keys(routes.redirects).length} redirects, ${checked.size} internal links/assets/fragments, catalog parity, canonical URLs, and exactly one tracker per view`);
