import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import Ajv2020 from "ajv/dist/2020.js";
import addFormats from "ajv-formats";
import { loadSources, localThumbnail, validateTracker } from "../scripts/source.mjs";
import { BASE_PATH, REPOSITORY_ROOT, productIds, sitePath, trackerIdentity } from "../scripts/config.mjs";

const records = await loadSources();
test("publishes every source sample without silently excluding records", () => {
  assert.ok(records.length >= 419);
  assert.equal(new Set(records.map((record) => record.slug.toLowerCase())).size, records.length);
});
test("normalizes deliberate product aliases and rejects unknown products", () => {
  assert.deepEqual(productIds(["AzureAD", "Entra ID", "Microsoft Entra"]), ["entra"]);
  assert.deepEqual(productIds(["Teams", "Microsoft Teams", "Microsoft Copilot"]), ["teams", "copilot"]);
  assert.deepEqual(productIds(["Graph"]), ["graph"]);
  assert.throws(() => productIds(["Unregistered product"]), /Unknown product/);
});
test("keeps historical tracker identities and canonical sample paths", () => {
  assert.equal(sitePath("samples/example/"), `${BASE_PATH}/samples/example/`);
  assert.equal(trackerIdentity(""), "https://m365-visitor-stats.azurewebsites.net/script-samples");
  assert.equal(trackerIdentity("samples/example/"), "https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/example");
  assert.equal(trackerIdentity("contributing/how-can-i-contribute/"), "https://m365-visitor-stats.azurewebsites.net/script-samples/how-can-i-contribute");
  assert.equal(trackerIdentity("404"), "https://m365-visitor-stats.azurewebsites.net/script-samples/404");
});
test("requires exactly one final-line README tracker while preserving accessibility attributes", () => {
  const image = '<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/example" aria-hidden="true" width="1" height="1" />';
  assert.doesNotThrow(() => validateTracker("example", `# Sample\n${image}\n`));
  assert.throws(() => validateTracker("other", image), /final line/);
  assert.throws(() => validateTracker("example", `${image}\nMore text`), /final line/);
  assert.throws(() => validateTracker("example", `${image}\n${image}`), /exactly one/);
});
test("schema rejects incomplete metadata, impossible dates, unknown tools, and duplicate categories", async () => {
  const ajv = new Ajv2020({ allErrors: true });
  addFormats(ajv);
  const validate = ajv.compile(JSON.parse(await readFile(path.join(REPOSITORY_ROOT, ".github", "schemas", "sample.schema.json"), "utf8")));
  const source = records[0].metadata;
  assert.equal(validate([source]), true);
  for (const edit of [
    (record) => { record.title = ""; },
    (record) => { record.shortDescription = ""; },
    (record) => { record.creationDateTime = "2026-02-31"; },
    (record) => { record.metadata[0].key = "UNREGISTERED"; },
    (record) => { record.categories.push(record.categories[0]); },
    (record) => { record.authors[0].gitHubAccount = "Not an account"; }
  ]) {
    const record = structuredClone(source);
    edit(record);
    assert.equal(validate([record]), false, JSON.stringify(record));
  }
});
test("previews must belong to their sample and cannot traverse outside it", async () => {
  const { slug, metadata } = records[0];
  assert.ok(await localThumbnail(slug, metadata.thumbnails[0].url));
  await assert.rejects(() => localThumbnail("other", metadata.thumbnails[0].url), /this sample/);
  await assert.rejects(() => localThumbnail(slug, `https://raw.githubusercontent.com/pnp/script-samples/main/scripts/${slug}/../../secret.png`), /this sample/);
});
